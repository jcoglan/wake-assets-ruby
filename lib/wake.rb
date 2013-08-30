require 'base64'
require 'erb'
require 'json'
require 'listen'
require 'mime/types'
require 'pathname'
require 'set'

module Wake
  DEFAULT_BUILD = 'min'
  DEFAULT_MODE  = :targets
  DEFAULT_WAKE  = './node_modules/wake/bin/wake'
  CACHE_FILE    = '.wake.json'
  MANIFEST      = '.manifest.json'
  PACKAGE_FILE  = 'package.json'
  WAKE_FILE     = 'wake.json'
  CONFIG_FILES  = Set.new([CACHE_FILE, MANIFEST, PACKAGE_FILE, WAKE_FILE])

  CSS = 'css'
  JS  = 'javascript'
  IMG = 'binary'

  class InvalidReference < StandardError
  end

  root = File.expand_path('../wake', __FILE__)
  autoload :Assets, root + '/assets'
  autoload :Renderer, root + '/renderer'
end

