$:.push File.expand_path("lib", __dir__)

# Maintain your gem's version:
require "filterameter/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |spec|
  spec.name        = "filterameter"
  spec.version     = Filterameter::VERSION
  spec.authors     = ["Todd Kummer"]
  spec.email       = ["todd@rockridgesolutions.com"]
  spec.summary     = "Declarative Filter Parameters"
  spec.description = "Enable filter parameters to be declared in query classes or controllers."
  spec.homepage    = "https://github.com/RockSolt/filterameter"
  spec.license     = "MIT"

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", '>= 6.1'

  spec.add_development_dependency "appraisal", "~> 2.5.0"
  spec.add_development_dependency "guard", "~> 2.16"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "guard-rubocop", "~> 1.5.0"
  spec.add_development_dependency "pg", "~> 1.5.4"
  spec.add_development_dependency "rspec-rails", "~> 3.9"
  spec.add_development_dependency "rubocop", "~> 1.31.1"
  spec.add_development_dependency "rubocop-rails", "~> 2.15.1"
  spec.add_development_dependency "simplecov", "~> 0.18"
end
