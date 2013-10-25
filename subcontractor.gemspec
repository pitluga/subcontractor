# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "subcontractor/version"

Gem::Specification.new do |s|
  s.name        = "subcontractor"
  s.version     = Subcontractor::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Tony Pitluga"]
  s.email       = ["tony.pitluga@gmail.com"]
  s.homepage    = "https://github.com/pitluga/subcontractor"
  s.summary     = %q{rvm aware process launcher for foreman}
  s.description = %q{rvm aware process launcher for foreman}

  s.rubyforge_project = "subcontractor"

  s.add_development_dependency("rspec")

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
