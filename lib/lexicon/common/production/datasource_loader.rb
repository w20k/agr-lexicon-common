# frozen_string_literal: true

module Lexicon
  module Common
    module Production
      class DatasourceLoader
        include Mixin::SchemaNamer
        # @param [ShellExecutor] shell
        # @param [Database::Factory] database_factory
        # @param [FileLoader] file_loader
        # @param [String] database_url
        def initialize(shell:, database_factory:, file_loader:, database_url:)
          @shell = shell
          @database_factory = database_factory
          @file_loader = file_loader
          @database_url = database_url
        end

        # @param [Package::Package] package
        # @param [Array<String>, nil] only
        # @param [Array<String>] without
        #   If nil, all datasets are loaded.
        #   If present, only listed datasets are loaded.
        #   Structures are ALWAYS loaded
        def load_package(package, only: nil, without: [])
          file_sets = if only.nil?
                        package.file_sets.select(&:data_path)
                      else
                        sets_by_name = package.file_sets.map { |fs| [fs.name, fs] }.to_h

                        missing, present = only.map { |name| [name, sets_by_name.fetch(name, nil)] }
                                               .partition { |(_name, value)| value.nil? }

                        if missing.any?
                          puts "[ NOK ] Datasources #{missing.map(&:first).join(', ')} don't exist!"
                          return
                        end

                        present.map(&:second)
                               .select(&:data_path)
                      end

          file_sets = file_sets.reject { |fs| without.include?(fs.name) }

          load_structure_files(package.structure_files, schema: version_to_schema(package.version))

          file_sets.map do |fs|
            Thread.new do
              puts "Loading #{fs.name}"
              file_loader.load_file(package.data_path(fs))
              puts '[  OK ] '.green + fs.name.yellow
            end
          end.each(&:join)

          lock_tables(package)
        end

        private

          # @return [Database::Factory]
          attr_reader :database_factory
          # @return [ShellExecutor]
          attr_reader :shell
          # @return [FileLoader]
          attr_reader :file_loader
          # @return [String]
          attr_reader :database_url

          def load_structure_files(files, schema:)
            database = database_factory.new_instance(url: database_url)
            database.prepend_search_path(schema) do
              files.each do |file|
                database.query(file.read)
              end
            end
          end

          # @param [Package::Package] package
          def lock_tables(package)
            database = database_factory.new_instance(url: database_url)

            schema = version_to_schema(package.version)

            database.prepend_search_path schema do
              database.query <<~SQL
                CREATE OR REPLACE FUNCTION #{schema}.deny_changes()
                  RETURNS TRIGGER
                AS $$
                  BEGIN
                    RAISE EXCEPTION '% denied on % (master data)', TG_OP, TG_RELNAME;
                  END;
                $$
                LANGUAGE plpgsql;
              SQL
              package.file_sets.flat_map(&:tables).each do |table_name|
                database.query <<~SQL
                  CREATE TRIGGER deny_changes
                    BEFORE INSERT
                        OR UPDATE
                        OR DELETE
                        OR TRUNCATE
                    ON #{schema}.#{table_name}
                    FOR EACH STATEMENT
                      EXECUTE PROCEDURE #{schema}.deny_changes()
                SQL
              end
            end
          end
      end
    end
  end
end
