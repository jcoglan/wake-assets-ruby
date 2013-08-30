module Wake
  class Assets

    def initialize(options)
      @pwd   = File.expand_path(options.fetch(:pwd, Dir.pwd))
      @wake  = options.fetch(:wake, File.expand_path(DEFAULT_WAKE, @pwd))
      @root  = Pathname.new(File.expand_path(options.fetch(:root, @pwd)))
      @mode  = options.fetch(:mode, DEFAULT_MODE)
      @paths = new_path_cache

      system(@wake, '--cache')
      read_config

      return unless options[:monitor]

      listener = Listen.to(@pwd).change do |modified, added, removed|
        all = (modified + added + removed).map &File.method(:basename)
        system(@wake, '--cache') if (added.any? or removed.any?) and not all.include?(CACHE_FILE)
        update! if (CONFIG_FILES & all).any?
      end
      listener.force_polling(true)
      listener.start
    end

    def deployment?
      @mode == :targets
    end

    def paths_for(group, names, options = {})
      build = options.fetch(:build, DEFAULT_BUILD)
      unless @config[group].fetch('builds', {}).has_key?(build)
        build = DEFAULT_BUILD
      end
      names.map { |name| @paths[group][name][build] }.flatten
    end

    def relative(path)
      '/' + Pathname.new(path).relative_path_from(@root).to_s
    end

    def renderer(options = {})
      Renderer.new(self, options)
    end

  private

    def find_paths_for(group, name, build)
      absolute_paths = begin
        cache = @cache[group][name]
        if @mode.to_s == 'sources'
          cache.fetch('sources')
        else
          [cache.fetch('targets').fetch(build)]
        end
      rescue
        nil
      end

      if absolute_paths.nil?
        raise InvalidReference, "Could not find assets, group: #{group}, name: #{name}, build: #{build}"
      end

      absolute_paths.map do |path|
        dirname  = File.dirname(path)
        manifest = File.join(dirname, MANIFEST)
        next path unless File.file?(manifest)

        basename = File.basename(path)
        mapping  = JSON.parse(File.read(manifest))
        File.join(dirname, mapping[basename] || basename)
      end
    end

    def new_path_cache
      Hash.new do |h, group|
        h[group] = Hash.new do |i, name|
          i[name] = Hash.new do |j, build|
            j[build] = find_paths_for(group, name, build)
          end
        end
      end
    end

    def read_config
      cache   = File.join(@pwd, CACHE_FILE)
      wake    = File.join(@pwd, WAKE_FILE)
      package = File.join(@pwd, PACKAGE_FILE)

      @config = if File.file?(wake)
                  JSON.parse(File.read(wake))
                elsif File.file?(package)
                  JSON.parse(File.read(package))['wake']
                else
                  {}
                end

      @cache = JSON.parse(File.read(cache))
    end

    def update!
      paths = new_path_cache
      read_config

      @paths.each do |group, a|
        a.each do |name, b|
          b.each do |build, files|
            paths[group][name][build]
          end
        end
      end
      @paths = paths
    end

  end
end
