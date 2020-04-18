# frozen_string_literal: true

guard :rspec, cmd: 'bundle exec rspec' do
  require 'guard/rspec/dsl'
  dsl = Guard::RSpec::Dsl.new(self)

  # RSpec files
  rspec = dsl.rspec
  watch(rspec.spec_helper) { rspec.spec_dir }
  watch(rspec.spec_support) { rspec.spec_dir }
  watch(rspec.spec_files)

  # Ruby files
  ruby = dsl.ruby
  dsl.watch_spec_files_for(ruby.lib_files)

  # Rails files
  rails = dsl.rails
  dsl.watch_spec_files_for(%r{^spec/dummy/app/(.+)\.rb$})

  # Rails config changes
  watch(rails.spec_helper) { rspec.spec_dir }
  watch('spec/dummy/app/controllers/application_controller.rb') { "#{rspec.spec_dir}/controllers" }
end

guard :rubocop, cli: %w[--display-cop-names --safe-auto-correct] do
  watch(/.+\.rb$/)
  watch(%r{(?:.+/)?\.rubocop(?:_todo)?\.yml$}) { |m| File.dirname(m[0]) }
end
