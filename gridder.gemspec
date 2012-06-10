$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
require "gridder/version"

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "gridder"
  s.version     = Gridder::VERSION
  s.authors     = ["Pablo Targa"]
  s.email       = ["pablo.targa@gmail.com"]
  s.homepage    = "https://rubygems.org/gems/gridder"
  s.summary     = "Gridder build Grids for rails apps"
  s.description = "Gridder generates a html table."

  s.files = Dir["{app,config,db,lib}/**/*"] + ["MIT-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files = Dir["test/**/*"]

  s.add_dependency("nokogiri", ">= 1.5.3")

  s.add_development_dependency("sqlite3")
  s.add_development_dependency("rails", "~> 3.2.5")
end
