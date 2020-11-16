# frozen_string_literal: true

module Lexicon
  module Common
    module Package
      class Package
        SPEC_FILE_NAME = 'lexicon.json'
        CHECKSUM_FILE_NAME = 'lexicon.sum'

        # @return [Pathname]
        attr_reader :checksum_file, :spec_file
        # @return [Pathname]
        attr_reader :dir
        # @return [Array<SourceFileSet>]
        attr_reader :file_sets
        # @return [Semantic::Version]
        attr_reader :version

        # @param [Array<SourceFileSet>] file_sets
        # @param [Pathname] dir
        # @param [Pathname] checksum_file
        # @param [Semantic::Version] version
        def initialize(file_sets:, version:, dir:, checksum_file:, spec_file:)
          @checksum_file = checksum_file
          @dir = dir
          @file_sets = file_sets
          @spec_file = spec_file
          @version = version
        end

        # @return [Boolean]
        def valid?
          checksum_file.exist? && dir.directory? && data_dir.directory? && all_sets_valid?
        end

        # @return [Array<Pathname>]
        def structure_files
          file_sets.map { |fs| dir.join(relative_structure_path(fs)) }
        end

        # @param [SourceFileSet] file_set
        # @return [Pathname]
        def data_path(file_set)
          dir.join(relative_data_path(file_set))
        end

        # @return [Pathname]
        def data_dir
          dir.join('data')
        end

        # @return [Pathname, nil]
        def relative_data_path(file_set)
          if file_set.data_path.nil?
            nil
          else
            data_dir.basename.join(file_set.data_path)
          end
        end

        # @return [Pathname]
        def relative_structure_path(file_set)
          data_dir.basename.join(file_set.structure_path)
        end

        private

          def all_sets_valid?
            file_sets.all? do |set|
              data_dir.join(set.structure_path).exist? && !set.data_path.nil? && data_dir.join(set.data_path).exist?
            end
          end
      end
    end
  end
end
