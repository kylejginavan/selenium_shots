# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{selenium_shots}
  s.version = "0.0.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Kyle J. Ginavan", "Mauro Torres"]
  s.date = %q{2010-04-06}
  s.default_executable = %q{selenium_shots}
  s.description = %q{longer description of selenium_shots}
  s.email = %q{kyle@4rockets.com}
  s.executables = ["selenium_shots"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README",
     "README.rdoc"
  ]
  s.files = [
    "lib/selenium_shots.rb",
     "lib/selenium_shots/cli/client.rb",
     "lib/selenium_shots/cli/command.rb",
     "lib/selenium_shots/cli/commands/app.rb",
     "lib/selenium_shots/cli/commands/auth.rb",
     "lib/selenium_shots/cli/commands/base.rb",
     "lib/selenium_shots/cli/commands/help.rb",
     "lib/selenium_shots/cli/init.rb",
     "lib/selenium_shots/test_selenium_shots.rb"
  ]
  s.homepage = %q{http://github.com/kylejginavan/selenium_shots}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{test your applications}
  s.test_files = [
    "test/helper.rb",
     "test/test_selenium_shots.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
      s.add_development_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_runtime_dependency(%q<rest-client>, [">= 0.8.2"])
      s.add_runtime_dependency(%q<launchy>, [">= 0.3.2"])
      s.add_runtime_dependency(%q<selenium-client>, [">= 1.2.18"])
    else
      s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
      s.add_dependency(%q<rest-client>, [">= 0.8.2"])
      s.add_dependency(%q<launchy>, [">= 0.3.2"])
      s.add_dependency(%q<selenium-client>, [">= 1.2.18"])
    end
  else
    s.add_dependency(%q<thoughtbot-shoulda>, [">= 0"])
    s.add_dependency(%q<rest-client>, [">= 0.8.2"])
    s.add_dependency(%q<launchy>, [">= 0.3.2"])
    s.add_dependency(%q<selenium-client>, [">= 1.2.18"])
  end
end

