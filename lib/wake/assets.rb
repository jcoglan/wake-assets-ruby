require 'base64'
require 'erb'
require 'json'
require 'mime/types'
require 'pathname'
require 'set'

module Wake
  class Assets

    DEFAULT_BUILD = 'min'
    DEFAULT_CACHE = true
    DEFAULT_MODE  = :targets
    DEFAULT_WAKE  = './node_modules/wake/bin/wake'
    CACHE_FILE    = '.wake.json'
    MANIFEST      = '.manifest.json'
    PACKAGE_FILE  = 'package.json'
    WAKE_FILE     = 'wake.json'

    CSS = 'css'
    JS  = 'javascript'
    IMG = 'binary'

    class InvalidReference < StandardError
    end

    autoload :Renderer, File.expand_path('../assets/renderer', __FILE__)

    def initialize(options = {})
      @pwd   = File.expand_path(options.fetch(:pwd, Dir.pwd))
      @cache = options.fetch(:cache, DEFAULT_CACHE)
      @wake  = options.fetch(:wake, File.expand_path(DEFAULT_WAKE, @pwd))
      @root  = Pathname.new(File.expand_path(options.fetch(:root, @pwd)))
      @mode  = options.fetch(:mode, DEFAULT_MODE)

      clear_cache
    end

    def clear_cache
      system(@wake, '--cache') unless @cache

      @config   = nil
      @index    = nil
      @manifest = {}
      @paths    = {}
    end

    def generated_file_paths
      index = read_index
      paths = Set.new([CACHE_FILE])
      index.each do |group_name, group|
        group.each do |bundle_name, bundles|
          bundles['targets'].each_value do |path|
            paths.add(path)
            manifest   = File.join(File.dirname(path), MANIFEST)
            source_map = path + '.map'
            [manifest, source_map].each do |file|
              paths.add(file) if File.file?(file)
            end
          end
        end
      end
      paths.map(&method(:resolve))
    end

    def paths_for(group, names, options = {})
      config = read_config

      build = options.fetch(:build, DEFAULT_BUILD)
      unless config.fetch(group).fetch('builds', {}).has_key?(build)
        build = DEFAULT_BUILD
      end
      names.map { |name| read_paths(group, name, build) }.flatten
    end

    def relative(path)
      '/' + Pathname.new(path).relative_path_from(@root).to_s
    end

    def renderer(options = {})
      clear_cache unless @cache
      Renderer.new(self, options)
    end

  private

    def find_paths_for(key)
      group, name, build = *key

      begin
        index = read_index.fetch(group).fetch(name)
        if @mode.to_s == 'sources'
          absolute_paths = index.fetch('sources')
        else
          absolute_paths = [index.fetch('targets').fetch(build)]
        end
      rescue KeyError
        raise InvalidReference, "Could not find assets: group: '#{group}', name: '#{name}', build: '#{build}'"
      end

      absolute_paths.map(&method(:resolve))
    end

    def read_config
      return @config if @config

      wake    = File.join(@pwd, WAKE_FILE)
      package = File.join(@pwd, PACKAGE_FILE)

      if File.file?(wake)
        config = JSON.parse(File.read(wake))
      elsif File.file?(package)
        config = JSON.parse(File.read(package))['wake']
      else
        config = {}
      end

      @config = config if @cache
      config
    end

    def read_index
      return @index if @index
      path = File.join(@pwd, CACHE_FILE)
      index = JSON.parse(File.read(path))
      @index = index if @cache
      index
    end

    def read_manifest(path)
      return @manifest[path] if @manifest.has_key?(path)
      mapping = File.file?(path) ? JSON.parse(File.read(path)) : {}
      @manifest[path] = mapping if @cache
      mapping
    end

    def read_paths(group, name, build)
      key = [group, name, build]
      return @paths[key] if @paths.has_key?(key)
      paths = find_paths_for(key)
      @paths[key] = paths if @cache
      paths
    end

    def resolve(path)
      path     = File.expand_path(path, @pwd)
      basename = File.basename(path)
      dirname  = File.dirname(path)
      manifest = File.join(dirname, MANIFEST)
      File.join(dirname, read_manifest(manifest).fetch(basename, basename))
    end

  end
end

