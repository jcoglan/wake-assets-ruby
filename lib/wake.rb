module Wake
  root = File.expand_path('../wake', __FILE__)
  autoload :Assets, root + '/assets'
  autoload :Renderer, root + '/renderer'
end

