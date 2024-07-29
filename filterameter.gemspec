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
  spec.description = "Declare filters in Rails controllers to increase readability and reduce boilerplate code."
  spec.homepage    = "https://github.com/RockSolt/filterameter"
  spec.license     = "MIT"
  spec.required_ruby_version = '>= 3.1.0'

  spec.files = Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]

  spec.add_dependency "rails", '>= 6.1'

  spec.add_development_dependency "appraisal", "~> 2.5.0"
  spec.add_development_dependency "guard", "~> 2.16"
  spec.add_development_dependency "guard-rspec", "~> 4.7"
  spec.add_development_dependency "guard-rubocop", "~> 1.5.0"
  spec.add_development_dependency "pg", "~> 1.5.4"
  spec.add_development_dependency "rspec-rails", "~> 6.1"
  spec.add_development_dependency "rubocop", "~> 1.64"
  spec.add_development_dependency "rubocop-packaging", "~> 0.5.2"
  spec.add_development_dependency "rubocop-rails", "~> 2.25"
  spec.add_development_dependency "rubocop-rspec", "~> 3.0.3"
  spec.add_development_dependency "rubocop-rspec_rails", "~> 2.30.0"
  spec.add_development_dependency "simplecov", "~> 0.18"
end
