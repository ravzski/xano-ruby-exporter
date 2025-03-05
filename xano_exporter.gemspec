# frozen_string_literal: true

require_relative "lib/xano_exporter/version"

Gem::Specification.new do |spec|
  spec.name = "xano_exporter"
  spec.version = XanoExporter::VERSION
  spec.authors = ["rav"]
  spec.email = ["ravzski@gmail.com"]

  spec.summary = "Exports data from Xano API to CSV files and generates Rails schema"
  spec.description = "A Ruby gem that exports data from Xano API to CSV files, generates a Rails-compatible schema.rb, and optionally creates ActiveRecord model files."
  spec.homepage = "https://github.com/ravzski/xano_exporter"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6.0"

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = spec.homepage
  spec.metadata["changelog_uri"] = "#{spec.homepage}/blob/main/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  spec.files = Dir["lib/**/*", "bin/*", "LICENSE.txt", "README.md"]
  spec.bindir = "bin"
  spec.executables = ["xano_exporter"]
  spec.require_paths = ["lib"]

  # Dependencies
  spec.add_dependency "thor", "~> 1.2"
  spec.add_dependency "activesupport", "~> 7.0"

  spec.add_development_dependency "bundler", "~> 2.0"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end