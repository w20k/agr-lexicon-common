# frozen_string_literal: true

module Lexicon
  module Common
    module Remote
      class PackageUploader < RemoteBase
        include Mixin::LoggerAware

        # @param [Package] package
        # @return [Boolean]
        def upload(package)
          bucket_name = package.version.to_s
          if !s3.bucket_exist?(bucket_name)
            s3.create_bucket(bucket: bucket_name)
            puts 'Uploading structures...'

            upload_files(*package.structure_files, bucket: bucket_name, prefix: 'data')
            puts '[  OK ] Structure uploaded.'.green

            data_files = package.file_sets
                                .select(&:data_path)
                                .map { |fs| package.data_path(fs) }

            upload_files(*data_files, bucket: bucket_name, prefix: 'data') do |path|
              puts "[  OK ] #{path.basename}".green
            end

            upload_files(package.checksum_file, package.spec_file, bucket: bucket_name) do |path|
              puts "[  OK ] #{path.basename}".green
            end

            true
          else
            false
          end
        rescue StandardError => e
          log_error(e)

          false
        end

        private

        # @param [Array<Pathname>] files
        #
        # @yieldparam [Pathname] path
        def upload_files(*files, bucket:, prefix: nil)
          files.each do |path|
            path.open do |f|
              s3.put_object(bucket: bucket, key: [prefix, path.basename.to_s].compact.join('/'), body: f)
            end
            yield path if block_given?
          end
        end
      end
    end
  end
end
