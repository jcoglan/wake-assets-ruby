require 'sinatra'
require 'wake/assets'

dev = (ENV['RACK_ENV'] == 'development')

wake_assets = Wake::Assets.new(
  :wake  => File.expand_path('../node_modules/.bin/wake', __FILE__),
  :root  => File.expand_path('../public', __FILE__),
  :mode  => dev ? :sources : :targets,
  :cache => !dev
)

get '/' do
  mobile = (env['HTTP_USER_AGENT'] =~ /iPhone/)

  @assets = wake_assets.renderer(
    :builds => {
      'css' => mobile ? 'mobile' : 'min'
    },
    :inline => mobile
  )

  erb :index
end

