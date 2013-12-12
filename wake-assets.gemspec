Gem::Specification.new do |s|
  s.name              = 'wake-assets'
  s.version           = '0.3.0'
  s.summary           = 'Renders links to assets managed by wake'
  s.author            = 'James Coglan'
  s.email             = 'jcoglan@gmail.com'
  s.homepage          = 'http://github.com/jcoglan/wake-assets'
  s.license           = 'MIT'

  s.extra_rdoc_files  = %w[README.md]
  s.rdoc_options      = %w[--main README.md --markup markdown]
  s.require_paths     = %w[lib]

  s.files = %w[README.md] +
            Dir.glob('lib/**/*.rb')

  s.add_dependency 'mime-types'
  s.add_development_dependency 'sinatra'
end

