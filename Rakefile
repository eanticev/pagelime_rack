# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  # gem is a Gem::Specification... see http://docs.rubygems.org/read/chapter/20 for more options
  gem.name = "pagelime-rack"
  gem.homepage = "http://github.com/eanticev/pagelime-rack"
  gem.license = "MIT"
  gem.summary = "Rack Middleware for integrating Pagelime into ruby frameworks"
  gem.description = "The Pagelime Rack Middleware will process outgoing HTML, look for editable areas, and replace the content with the appropriate HTML from the Pagelime CDN and cache it in memory if possible."
  gem.email = "emil@pagelime.com"
  gem.authors = ["Emil Anticevic", "Joel Van Horn"]
  # dependencies defined in Gemfile
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/testtask'
Rake::TestTask.new(:test) do |test|
  test.libs << 'lib' << 'test'
  test.pattern = 'test/**/test_*.rb'
  test.verbose = true
end

task :default => :test

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "pagelime-rack #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
