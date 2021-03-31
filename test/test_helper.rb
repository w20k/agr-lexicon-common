# frozen_string_literal: true

require_relative '../lib/lexicon-common'

require 'minitest/autorun'

module Lexicon
  module Testing

    module Helper
      class << self
        # @return [Pathname]
        def fixtures_dir
          Pathname.new(__dir__).join('fixtures')
        end
      end
    end
  end
end
