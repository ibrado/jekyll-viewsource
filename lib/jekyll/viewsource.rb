require 'jekyll/viewsource/renderer'

module Jekyll
  module ViewSource
    # Temp compatibility

    # We have to run this after the site is written 
    # so we can read HTML output
    Jekyll::Hooks.register :site, :post_write do |site|
      Renderer.render_source_files(site)
    end

    TINYTOOLS = 'tinytools'.freeze
    VIEWSOURCE = 'viewsource'.freeze
    VIEWSOURCE_LOG = 'ViewSource:'.freeze

    PRETTY_PROP = 'viewsource-pretty'.freeze
    LINKBACK_PROP = 'viewsource-linkback'.freeze

    DEFAULT_CSS = 'github'.freeze
    CSS_SCOPE = '.highlight'.freeze

    INFIX = '-src'.freeze
    HTML = 'html'.freeze
    TXT = 'txt'.freeze
    MD = 'md'.freeze

    INFIXED_HTML = "#{INFIX}.#{HTML}".freeze
    INFIXED_TXT = "#{INFIX}.#{TXT}".freeze

    SOURCE_URL = 'source_url'.freeze
    HTML_SOURCE_URL = 'html_source_url'.freeze

    def self.debug_state(debug)
      @debug ||= debug
    end

    def self.warn(msg)
      Jekyll.logger.warn VIEWSOURCE_LOG, msg
    end

    def self.debug(item, msg, facet = nil)
      if @debug
        info = (item.respond_to?(:path) ? File.basename(item.path) : item) || 'liquid'
        if facet
          msg = "[#{facet}] [#{info}] #{msg}"
        else
          msg = "[#{info}] #{msg}"
        end

        Jekyll.logger.warn VIEWSOURCE_LOG, msg
      end
    end

    def self.site(s = nil)
      @site ||= s
    end

    class Generator < Jekyll::Generator
      def generate(site)
        start_time = Time.now
        
        ViewSource.site(site)

        config = site.config[VIEWSOURCE] || {}
        return unless config["enabled"].nil? || config["enabled"]

        @debug = config["debug"]
        ViewSource.debug_state @debug
        Cache.setup(site, config['cache'].nil? || config['cache'])

        config['collection'] = config['collection'].split(/,\s*/) if config['collection'].is_a?(String)

        collections = [ config['collection'], config["collections"] ].flatten.compact.uniq;
        collections = [ "posts", "pages" ] if collections.empty?

        collections.each do |collection|
          if collection == "pages"
            items = site.pages
          else
            next if !site.collections.has_key?(collection)
            items = site.collections[collection].docs
          end

          process = items.select { |item| item.data[TINYTOOLS] || item.data[VIEWSOURCE]}

          process.each do |item|
            vs_opts = item.data[TINYTOOLS] || item.data[VIEWSOURCE]
            if m = /pretty\s*=?\s*(['"](.*?)['"]|)/.match(vs_opts)
              pretty = m[2] || DEFAULT_CSS
              ViewSource.debug item, "Set CSS to #{pretty}" if pretty
            end

            if m = /linkback\s*=?\s*(['"](.*?)['"]|)/.match(vs_opts)
              linkback = m[2] || 'Back'
              ViewSource.debug item, "Set linkback text to #{pretty}" if linkback
            end

            view_md = (vs_opts =~ /md|markdown/)
            view_html = (vs_opts =~ /html/)

            if !view_md && !view_html
              view_md = true
            end

            if view_md
              dest_folder = Pathname(item.url).dirname
              dest_folder = '' if dest_folder.to_s == '/'

              filename = File.basename(item.path)
              item.data[SOURCE_URL] = "#{dest_folder}/#{filename}" +
                (pretty ? INFIXED_HTML : INFIXED_TXT)
            end

            if view_html
              html_source_file = "#{item.destination('')}".sub!(site.dest, '')
              item.data[HTML_SOURCE_URL] = html_source_file +
                (pretty ? INFIXED_HTML : INFIXED_TXT)
            end

            item.data[PRETTY_PROP] = pretty
            item.data[LINKBACK_PROP] = "#{item.url}|$|#{linkback}" if linkback

            ViewSource::Renderer.render_items << item

            elapsed = "%.3f" % (Time.now - start_time)
            ViewSource.debug item, "Rendered in #{elapsed}s"
          end

        end

      end
    end
  end
end
