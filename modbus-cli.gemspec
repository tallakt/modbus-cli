# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "modbus-cli/version"

Gem::Specification.new do |s|
  s.name        = "modbus-cli"
  s.version     = Modbus::Cli::VERSION
  s.authors     = ["Tallak Tveide"]
  s.email       = ["tallak@tveide.net"]
  s.homepage    = "http://www.github.com/tallakt/modbus-cli"
  s.summary     = %q{Modbus command line}
  s.description = %q{Command line interface to communicate over Modbus TCP}

  s.rubyforge_project = "modbus-cli"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  s.add_runtime_dependency "rmodbus", '~> 1.2'
  s.add_runtime_dependency "clamp", '~> 0.6.5'
  s.add_development_dependency "rspec", '~> 3.2'
  s.add_development_dependency "rake", '~> 0.9'
end
