
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "validate_suffixed_number/version"

Gem::Specification.new do |spec|
  spec.name          = "validate_suffixed_number"
  spec.version       = ValidateSuffixedNumber::VERSION
  spec.authors       = ["Alan Stebbens"]
  spec.email         = ["aks@stebbens.org"]

  spec.summary       = %q{Parse numbers suffixed with magnitude abbreivations, eg "10K"}
  spec.description   = %q{Parse numbers suffixed with mangitude specifiers and/or abbreivations.}
  spec.homepage      = "https://github.com/aks/validate_suffixed_number"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata["allowed_push_host"] = "https://rubygems.org"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^spec/})
  end
  spec.bindir        = "bin"
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", ">= 3.7.0"
  spec.add_development_dependency "fuubar", ">= 2.3.1"
  spec.add_development_dependency "rubocop"
end
