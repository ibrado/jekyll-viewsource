require 'jekyll-viewsource/renderer'

module Jekyll
  module ViewSource

    class Cache
      DEFAULT_CACHE = File.join(Dir.home, '.jekyll-plugins', 'jekyll-viewsource', 'cache').freeze

      def self.setup(site, cache)
        @site = site

        if cache
          @cache_dir = (cache.is_a?(String) ? cache : DEFAULT_CACHE)

          ViewSource.debug 'startup', "Setting up cache at #{@cache_dir}" if Renderer.first_run

          FileUtils.mkdir_p File.join(@cache_dir)
        end
      end

      def self.location(uri, dest)
        return if !@cache_dir

        subdir = Digest::SHA256.hexdigest(uri)

        filename = File.basename(dest)
        #filepath = Pathname(uri).dirname

        #File.join(cache_path, subdir, filepath, filename)
        File.join(@cache_dir, subdir, filename)
      end

      def self.contents(uri, dest, content = nil)
        filepath = self.location(uri, dest)
        return if !filepath

        if content
          FileUtils.mkdir_p Pathname(filepath).dirname
          File.write(filepath, content)
        else
          if File.exist?(filepath)
            content = File.read filepath
          end
        end

        content
      end

      def self.modified?(source, dest, expiry = nil)
        cache_path = self.location(source, dest)
        if source =~ %r[://]
          mod = Utils.modified?(nil, cache_path, expiry)
        else
          mod = Utils.modified?(source, cache_path, expiry)
        end
        mod
      end

      def self.valid?(source, dest, expiry = nil)
        ! self.modified?(source, dest, expiry)
      end

    end

  end
end
