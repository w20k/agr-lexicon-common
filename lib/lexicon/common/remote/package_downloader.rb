# frozen_string_literal: true

module Lexicon
  module Common
    module Remote
      class PackageDownloader < RemoteBase
        # @param [S3Client] s3
        # @param [Pathname] out_dir
        # @param [DirectoryPackageLoader] package_loader
        def initialize(s3:, out_dir:, package_loader:)
          super(s3: s3)
          @out_dir = out_dir
          @package_loader = package_loader
        end

        # @param [Semantic::Version] version
        # @return [Boolean]
        def download(version)
          bucket = version.to_s

          if s3.bucket_exist?(bucket)
            Dir.mktmpdir(nil, out_dir) do |tmp_dir|
              tmp_dir = Pathname.new(tmp_dir)

              s3.raw.get_object(
                bucket: bucket,
                key: Package::Package::SPEC_FILE_NAME,
                response_target: tmp_dir.join(Package::Package::SPEC_FILE_NAME).to_s
              )
              s3.raw.get_object(
                bucket: bucket,
                key: Package::Package::CHECKSUM_FILE_NAME,
                response_target: tmp_dir.join(Package::Package::CHECKSUM_FILE_NAME).to_s
              )

              package = package_loader.load_package(tmp_dir.basename.to_s)
              if !package.nil?
                puts "[  OK ] Found package with key #{version}, version is #{package.version}".green

                FileUtils.mkdir_p package.data_dir

                package.structure_files.map do |file|
                  Thread.new do
                    s3.raw.get_object(bucket: bucket, key: "data/#{file.basename.to_s}", response_target: file.to_s)
                    puts "[  OK ] Downloaded #{file.basename}".green
                  end
                end.each(&:join)

                package.file_sets.map do |fs|
                  Thread.new do
                    path = package.data_path(fs)
                    s3.raw.get_object(bucket: bucket, key: "data/#{path.basename.to_s}", response_target: path.to_s)
                    puts "[  OK ] Downloaded #{path.basename}".green
                  end
                end.each(&:join)

                dest_dir = out_dir.join(version.to_s)
                FileUtils.mkdir_p(dest_dir)
                tmp_dir.children.each do |child|
                  FileUtils.mv(child.to_s, dest_dir.join(child.basename).to_s)
                end

                true
              else
                puts "[ NOK ] The remote contains a bucket '#{version}' but it does not contains a valid package.".red

                false
              end
            end
          else
            false
          end
        end

        private

          # @return [DirectoryPackageLoader]
          attr_reader :package_loader
          # @return [Pathname]
          attr_reader :out_dir
      end
    end
  end
end
