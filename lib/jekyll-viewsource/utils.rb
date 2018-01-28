require 'net/http'

module Jekyll
  module ViewSource

   module Utils
      @touched = {}
      @cache = {}

      CACHE_EXPIRY = 600 # seconds

      def self.source_file(item)
        source_prefix = item.is_a?(Jekyll::Page) ? ViewSource.site.source : ''
        File.join(source_prefix, item.path)
      end

      def self.modified?(source, dest, expiry = nil)
        dest && !dest.empty? &&
          (!File.exist?(dest) ||
            (source && (File.mtime(source) > File.mtime(dest))) ||
            (expiry && ((File.mtime(dest) + expiry) <= Time.now ))
          )
      end

    end
  end
end

