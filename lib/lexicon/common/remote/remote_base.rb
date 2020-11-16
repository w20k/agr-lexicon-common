# frozen_string_literal: true

module Lexicon
  module Common
    module Remote
      class RemoteBase
        # @param [S3Client] s3
        def initialize(s3:)
          @s3 = s3
        end

        private

          # @return [Aws::S3::Client]
          attr_reader :s3
      end
    end
  end
end
