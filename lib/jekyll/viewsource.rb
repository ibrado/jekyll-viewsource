require 'jekyll/viewsource/constants'
require 'jekyll/viewsource/cache'
require 'jekyll/viewsource/renderer'

module Jekyll
  module ViewSource

    # We have to run this after the site is written 
    # i.e. the HTML files exist
    Jekyll::Hooks.register :site, :post_write do |site|
      Renderer.render_html(site)
    end

    def self.debug_state(debug)
      @debug ||= debug
    end

    def self.warn(msg)
      Jekyll.logger.warn VIEWSOURCE_LOG, msg
    end

    def self.debug(item, msg)
      if @debug 
        info = item ? 
          (item.respond_to?(:path) ? File.basename(item.path) :
            item)
          : 'main'.freeze
         
        msg = "[#{info}] #{msg}"

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

            view_md = (vs_opts =~ /\b(md|markdown)\b/i)
            view_html = (vs_opts =~ /\bhtml\b/i)

            view_md ||= !view_html

            if view_md
              dest_folder = Pathname(item.url).dirname
              dest_folder = '' if dest_folder.to_s == '/'
              filename = File.basename(item.path)

              # Render now
              linkback = "#{item.url}|$|#{linkback}" if linkback
              puts "RENDERING MD FROM #{dest_folder}/#{filename}"
              Renderer.render_item(site, item, 
                "#{dest_folder}/#{filename}", MD, pretty, linkback
              )
            end

            if view_html
              # Enqueue for post site render
              item.data[SOURCE_FILE] = "#{item.destination('')}".sub!(site.dest, '')
              item.data[PRETTY_PROP] = pretty
              item.data[LINKBACK_PROP] = "#{item.url}|$|#{linkback}" if linkback

              Renderer.enqueue_html(item)
            end
          end

          elapsed = "%.3f" % (Time.now - start_time)
          ViewSource.debug nil, "Runtime: #{elapsed}s"
 
        end

      end
    end
  end
end
