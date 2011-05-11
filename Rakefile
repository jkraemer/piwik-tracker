require "bundler"
Bundler.setup

require 'rake/testtask'

desc 'Test the library.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib' << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

gemspec = eval(File.read("piwik-tracker.gemspec"))

task :build => "#{gemspec.full_name}.gem"

file "#{gemspec.full_name}.gem" => gemspec.files + ["piwik-tracker.gemspec"] do
  system "gem build piwik-tracker.gemspec"
  system "gem install piwik-tracker-#{PiwikTracker::VERSION}.gem"
end
