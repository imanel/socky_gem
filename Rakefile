begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "socky"
    gemspec.summary = "Socky is a WebSocket server and client for Ruby on Rails"
    gemspec.description = "Socky is a WebSocket server and client for Ruby on Rails"
    gemspec.email = "b.potocki@imanel.org"
    gemspec.homepage = "http://github.com/imanel/socky_gem"
    gemspec.authors = ["Bernard Potocki"]
    gemspec.add_dependency('em-websocket', '>= 0.0.6')
    gemspec.add_dependency('em-http-request')
    gemspec.files.exclude ".gitignore"
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end