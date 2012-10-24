# -*- encoding: utf-8 -*-
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'capistrano/fast_deploy/version'

Gem::Specification.new do |gem|
  gem.name          = "capistrano-fast_deploy"
  gem.version       = Capistrano::FastDeploy::VERSION
  gem.authors       = ["Aaron Jensen"]
  gem.email         = ["aaronjensen@gmail.com"]

  gem.summary       = %q{Enable git style deploys in capistrano}
  gem.description   = %q{A couple Capistrano tweaks to speed up deploys using git style deploys and a few optimizations}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency "capistrano", "~>2.13"
end
