require 'rake'
require 'rake/clean'
CLEAN.include %w(**/*.{log,rbc})

require 'spec/rake/spectask'

task :default => :spec

Spec::Rake::SpecTask.new do |t|
  t.ruby_opts = ['-rtest/unit']
  t.spec_files = FileList['spec/**/*_spec.rb']
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "socky"
    gemspec.summary = "Socky is a WebSocket server and client for Ruby on Rails"
    gemspec.description = "Socky is a WebSocket server and client for Ruby on Rails"
    gemspec.email = "b.potocki@imanel.org"
    gemspec.homepage = "http://github.com/imanel/socky_gem"
    gemspec.authors = ["Bernard Potocki"]
    gemspec.add_dependency('em-websocket', '>= 0.1.4')
    gemspec.add_dependency('em-http-request')
    gemspec.add_dependency('json')
    gemspec.files.exclude ".gitignore"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end
