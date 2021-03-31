# frozen_string_literal: true

require 'test_helper'

module Lexicon
  module Common
    module Schema
      describe 'Lexicon schema validation' do
        before do
          @validator = ValidatorFactory.new(LEXICON_SCHEMA_ABSOLUTE_PATH).build
        end

        it 'validates a valid V1 schema' do
          values = JSON.parse(Lexicon::Testing::Helper.fixtures_dir.join('packages', 'valid_v1', 'lexicon.json').read)

          assert(@validator.valid?(values))
        end

        it 'should not validate an ivalid V1 schema' do
          values = JSON.parse(Lexicon::Testing::Helper.fixtures_dir.join('packages', 'invalid_v1', 'lexicon.json').read)

          refute(@validator.valid?(values))
        end
      end
    end
  end
end
