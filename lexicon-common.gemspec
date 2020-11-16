require_relative 'lib/lexicon/common/version'

Gem::Specification.new do |spec|
  spec.name = "lexicon-common"
  spec.version = Lexicon::Common::VERSION
  spec.authors = ["Ekylibre developers"]
  spec.email = ["dev@ekylibre.com"]

  spec.summary = "Common classes and services for the Lexicon"
  spec.required_ruby_version = ">= 2.6.0"
  spec.homepage = "https://www.ekylibre.com"
  spec.license = "AGPL-3.0-only"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://gems.ekylibre.dev"

    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://www.gitlab.com/ekylibre/lexicon/lexicon-common"
  else
    raise StandardError.new("RubyGems 2.0 or newer is required to protect against public gem pushes.")
  end

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.glob(%w[lib/**/*.rb bin/**/* *.gemspec Gemfile Rakefile *.md])

  spec.require_paths = ["lib"]

  spec.add_dependency 'aws-sdk-s3', '~> 1.84'
  spec.add_dependency 'colored', '~> 1.2'
  spec.add_dependency 'json_schemer', '~> 0.2.16'
  spec.add_dependency 'pg', '~> 1.2'
  spec.add_dependency 'semantic', '~> 1.6'
  spec.add_dependency 'zeitwerk', '~> 2.4'

  spec.add_development_dependency "bundler", "> 1.17"
  spec.add_development_dependency "minitest", "~> 5.14"
  spec.add_development_dependency "rake", "~> 13.0"
end
