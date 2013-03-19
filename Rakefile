require 'rake'
require 'rake/testtask'
require 'rubygems/package_task'

task :default => [:test]
task :test => ['test:units']

namespace :test do
	Rake::TestTask.new(:units) do |test|
		test.libs << 'test'
		test.ruby_opts << '-rubygems'
		test.pattern = 'test/*.rb'
		test.verbose = true
	end
end

eval("$specification = begin; #{IO.read('alchemist.gemspec')}; end")
Gem::PackageTask.new($specification) do |package|
  package.need_zip = true
  package.need_tar = true
end
