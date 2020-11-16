# frozen_string_literal: true

# require 'lexicon/common'
require 'aws-sdk-s3'
require 'colored'
require 'logger'
require 'pg'
require 'semantic'
require 'zeitwerk'

# Make sure the Lexicon module already exists so that Zeitwerk does not manage it
module Lexicon
end

loader = Zeitwerk::Loader.for_gem
loader.ignore(__FILE__)
loader.setup
