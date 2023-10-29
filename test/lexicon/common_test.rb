require 'test_helper'

module Lexicon
  class CommonTest < Minitest::Test
    def test_that_it_has_a_version_number
      refute_nil ::Lexicon::Common::Version
    end
  end
end
