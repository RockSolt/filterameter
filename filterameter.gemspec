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
  spec.homepage    = "https://github.com/RockSolt/filterameter"
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", ">= 5.2.2"

  spec.add_development_dependency "pg"
  spec.add_development_dependency "rspec-rails", "~> 3.9"
  spec.add_development_dependency "rubocop", "~> 0.77"
  spec.add_development_dependency "simplecov"
end
