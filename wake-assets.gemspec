Gem::Specification.new do |s|
  s.name              = 'wake-assets'
  s.version           = '0.2.0'
  s.summary           = 'Renders links to assets managed by wake'
  s.author            = 'James Coglan'
  s.email             = 'jcoglan@gmail.com'
  s.homepage          = 'http://github.com/jcoglan/wake-assets'

  s.extra_rdoc_files  = %w[README.md]
  s.rdoc_options      = %w[--main README.md --markup markdown]
  s.require_paths     = %w[lib]

  s.files = %w[README.md] +
            Dir.glob('lib/**/*.rb')

  s.add_dependency 'listen'
  s.add_dependency 'mime-types'
end

