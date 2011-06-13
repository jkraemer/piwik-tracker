require File.expand_path("../lib/piwik_tracker/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "piwik-tracker"
  s.version     = PiwikTracker::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Jens Krämer"]
  s.email       = ["jk@jkraemer.net"]
  s.homepage    = "http://github.com/jkraemer/piwik-tracker"
  s.summary     = "Record visits, page views, Goals, in a Piwik server"
  s.description = ""

  s.required_rubygems_version = ">= 1.3.6"

  # lol - required for validation
  s.rubyforge_project         = "piwik-tracker"

  # If you have other dependencies, add them here
  # s.add_dependency "another", "~> 1.2"
  s.add_dependency 'patron'

  # If you need to check in files that aren't .rb files, add them here
  s.files        = Dir["{lib}/**/*.rb", "bin/*", "LICENSE", "*.md"]
  s.require_path = 'lib'

  # If you need an executable, add it here
  # s.executables = ["newgem"]

  # If you have C extensions, uncomment this line
  # s.extensions = "ext/extconf.rb"
end
