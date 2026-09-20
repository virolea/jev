# frozen_string_literal: true

require_relative "lib/jev/version"

Gem::Specification.new do |spec|
  spec.name = "jev"
  spec.version = Jev::VERSION
  spec.authors = ["Vincent Rolea"]
  spec.email = ["3525369+virolea@users.noreply.github.com"]

  spec.summary = "Ruby client for the Typesafe Jev model API."
  spec.description = "A Ruby client for the Jev model API from Typesafe (https://typesafe.ai)."
  spec.homepage = "https://github.com/virolea/jev"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 3.2.0"
  spec.metadata["allowed_push_host"] = "https://rubygems.org"
  spec.metadata["homepage_uri"] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == gemspec) ||
        f.start_with?(*%w[bin/ Gemfile .gitignore test/ .github/ .rubocop.yml])
    end
  end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency "zeitwerk", "~> 2.6"

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
