module Wake
  class Assets
    class Renderer

      def initialize(assets, options)
        @assets = assets
        @builds = options.fetch(:builds, {})
        @hosts  = options.fetch(:hosts, [])
        @inline = options[:inline]
      end

      def include_css(*names)
        names, options = extract_options(names)

        tags = if options.fetch(:inline, @inline)
                 paths_for(CSS, names, options).map do |path|
                   %Q{#{tag :style, options, :type => 'text/css'}#{File.read path}</style>}
                 end
               else
                 urls_for(CSS, names, options).map do |url|
                   tag :link, options, :rel => 'stylesheet', :type => 'text/css', :href => url
                 end
               end

        html_safe(tags * '')
      end

      def include_image(*names)
        names, options = extract_options(names)

        tags = if options.fetch(:inline, @inline)
                 paths_for(IMG, names, options).map do |path|
                   base64 = Base64.strict_encode64(File.read(path))
                   mime   = MIME::Types.type_for(path).first
                   tag :img, options, :src => "data:#{mime};base64,#{base64}"
                 end
               else
                 urls_for(IMG, names, options).map { |url| tag :img, options, :src => url }
               end

        html_safe(tags * '')
      end

      def include_js(*names)
        names, options = extract_options(names)

        tags = if options.fetch(:inline, @inline)
                 paths_for(JS, names, options).map do |path|
                   %Q{#{tag :script, options, :type => 'text/javascript'}#{File.read path}</script>}
                 end
               else
                 urls_for(JS, names, options).map do |url|
                   %Q{#{tag :script, options, :type => 'text/javascript', :src => url}</script>}
                 end
               end

        html_safe(tags * '')
      end

      def paths_for(type, names, options = {})
        @assets.paths_for(type, names, {:build => @builds[type]}.merge(options))
      end

      def urls_for(type, names, options = {})
        paths = paths_for(type, names, options).map { |p| @assets.relative(p) }

        return paths unless @hosts.any?

        paths.map do |path|
          @hosts[path.hash % @hosts.size].gsub(/\/*$/, '') + path
        end
      end

    private

      def extract_options(names)
        [names.grep(String), names.grep(Hash).first || {}]
      end

      def h(string)
        ERB::Util.html_escape(string)
      end

      def html_safe(string)
        if defined? ActiveSupport
          ActiveSupport::SafeBuffer.new(string)
        else
          string
        end
      end

      def tag(name, options, attrs)
        attrs = attrs.merge(options.fetch(:html, {}))
        "<#{name} #{ attrs.map { |k,v| %Q{#{k}="#{h v.to_s}"} }.join(' ') }>"
      end

    end
  end
end

