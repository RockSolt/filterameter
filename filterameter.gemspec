$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "filterameter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "filterameter"
  spec.version     = Filterameter::VERSION
  spec.authors     = ["Todd Kummer"]
  spec.email       = ["todd@rockridgesolutions.com"]
  spec.summary     = "Declarative Filter Parameters for Rails Controllers"
  spec.description = "Enable filter parameters to be declared in controllers."
  spec.license     = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 5.2.2"

  spec.add_development_dependency "pg"
  spec.add_development_dependency "rspec-rails", "~> 3.9"
  spec.add_development_dependency "rubocop", "~> 0.77"
  spec.add_development_dependency "simplecov"
end
