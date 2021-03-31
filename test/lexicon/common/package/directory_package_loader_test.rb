# frozen_string_literal: true

require 'test_helper'

module Lexicon
  module Common
    module Package
      describe DirectoryPackageLoader do
        before do
          @sv = Schema::ValidatorFactory.new(Lexicon::Common::LEXICON_SCHEMA_ABSOLUTE_PATH).build

          @pl = DirectoryPackageLoader.new(
            Lexicon::Testing::Helper.fixtures_dir.join('packages'),
            schema_validator: @sv,
          )
        end

        it 'should return a Package when loading valid V1 files' do
          package = @pl.load_package('valid_v1')

          refute_nil(package)
          assert_equal(1, package.schema_version)
        end

        it 'should return nil as version 1 should not have a schema_version property' do
          assert_nil(@pl.load_package('invalid_v1'))
        end
      end
    end
  end
end
