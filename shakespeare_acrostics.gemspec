# Encoding: UTF-8

lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'shakespeare_acrostics/version.rb'

Gem::Specification.new do |s|
  s.name          = 'shakespeare_acrostics'
  s.authors       = ['Paul Thompson']
  s.email         = ['nossidge@gmail.com']

  s.summary       = %q{Acrostic sonnets on Shakespeare's sonnets}
  s.description   = %q{Procedurally generate a set of Shakespearean sonnets that are acrostics using every one of the letters of every sonnet to start each line.}
  s.homepage      = 'https://github.com/nossidge/shakespeare_acrostics'

  s.version       = ShakespeareAcrostics.version_number
  s.date          = ShakespeareAcrostics.version_date
  s.license       = 'GPL-3.0'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  s.bindir        = 'bin'

  s.add_runtime_dependency('poefy',          '~> 1.1', '>= 1.1.0')
  s.add_runtime_dependency('poefy-pg',       '~> 1.1', '>= 1.1.0')
  s.add_runtime_dependency('roman-numerals', '~> 0.3', '>= 0.3.0')
end
