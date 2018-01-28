
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "jekyll-viewsource/version"

Gem::Specification.new do |spec|
  spec.name          = "jekyll-viewsource"
  spec.version       = Jekyll::ViewSource::VERSION
  spec.required_ruby_version = '>= 2.1.0'
  spec.authors       = ["Alex Ibrado"]
  spec.email         = ["alex@ibrado.org"]

  spec.summary       = %q{View plain or pretty Markdown and/or HTML source code}
  spec.description   = %q{This Jekyll plugin generates pretty or plain Markdown and/or HTML source code pages for your Markdown docs, which you can easily link to for viewing.}
  spec.homepage      = "https://github.com/ibrado/jekyll-viewsource"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "jekyll", "~> 3.0"
  spec.add_runtime_dependency "htmlbeautifier", "~> 1.3"
  rouge_versions = ENV["ROUGE_VERSION"] ? ["~> #{ENV["ROUGE_VERSION"]}"] : [">= 1.7", "< 3"]
  spec.add_runtime_dependency("rouge", *rouge_versions)
  spec.add_development_dependency "bundler", "~> 2.16"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec", "~> 3.0"
end
