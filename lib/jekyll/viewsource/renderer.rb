require 'htmlbeautifier'

module Jekyll
  module ViewSource

    module Renderer
      require_relative 'constants'
      require_relative 'utils'
      require_relative 'lexer'

      # We have to run this after the site is written 
      # i.e. the HTML files exist
      Jekyll::Hooks.register :site, :post_write do |site|
        render_items(site)
      end

      @render_queue  = []
      @first_run = true

      PRETTY = 'Pretty'.freeze
      PLAIN = 'Plain'.freeze

      DEFAULT_BG = '#808080'.freeze

      CACHED = ' (cached)'.freeze

      def self.first_run
        @first_run
      end

      def self.enqueue(item)
        @render_queue << item
      end

      def self.render_items(site)
        @render_queue.each do |item|
          pretty = item.data.delete(PRETTY_PROP)
          linkback = item.data.delete(LINKBACK_PROP)

          if md_file = item.data.delete(MD_FILE_PROP)
            render_source(site, item, md_file, MD, pretty, linkback)
          end

          if html_file = item.data.delete(HTML_FILE_PROP)
            render_source(site, item, html_file, HTML, pretty, linkback)
          end

          if @first_run
            ViewSource.debug item, "Set CSS to #{pretty}" if pretty
            ViewSource.debug item, "Set linkback text to #{linkback}" if linkback
          end
        end

        @render_queue.clear
        @first_run = false
      end

      def self.render_source(site, item, file_url, ext, pretty = nil, linkback = nil)
        return unless file_url

        source_link = file_url +
          ( pretty ? INFIXED_HTML : INFIXED_TXT)

        dest_file = File.join(site.dest, source_link)
        source_md = Utils.source_file(item)

        source_file = (ext == MD ? source_md :
          File.join(site.dest, file_url))

        if Cache.modified?(source_md, dest_file)
          FileUtils.mkdir_p Pathname(dest_file).dirname

          if pretty
            File.write(dest_file, prettify(source_file, ext, pretty, linkback))
          else
            if ext == MD
              FileUtils.cp source_file, dest_file
            else
              # Prettify it as text a bit, anyway
              source_code = HtmlBeautifier.beautify File.read(source_file)
              File.write(dest_file, source_code)
            end
          end

          Cache.contents(source_md, dest_file, File.read(dest_file))

        else
          cached = CACHED
          File.write(dest_file, Cache.contents(source_md, dest_file))
        end

        if @first_run || !cached
          ViewSource.debug item, (pretty ? PRETTY : PLAIN) +
            " #{ext}: #{source_link}#{cached}"
       end

      end

      def self.prettify(source_file, type, user_css, linkback = nil)
        source_code = File.read(source_file)
        title = File.basename(source_file)

        if type == HTML
          source_code = HtmlBeautifier.beautify source_code
        end

        formatter = Rouge::Formatters::HTML.new
        if type == MD
          lexer = Rouge::Lexers::ViewSource.new
        else
          lexer = Rouge::Lexers::HTML.new
        end

        formatted = formatter.format(lexer.lex(source_code))

        body = "<pre>#{formatted}</pre>"

        if user_css
          if user_css =~ /^\//
            source_css = File.join(site.dest, user_css)
            css = File.read(source_css) if File.exist?(source_css)
          else
            unless theme = Rouge::Theme.find(user_css)
              theme = Rouge::Theme.find(DEFAULT_CSS)
            end
            css = theme.render(scope: CSS_SCOPE)
          end
        end

        if m = css.match(/^\.highlight {.*?background-color:\s*(.*?);/m)
          body_bg = m[1];
        else
          body_bg = DEFAULT_BG
        end

        if linkback
          (lb_url, lb_text) = linkback.split('|$|', 2)
          linkback = %Q(<div style="background-color: #fff; color: #000; padding: 5px;" class="viewsource-linkback">&laquo; <a href=").freeze + %Q(#{lb_url}">#{lb_text}) + '</a></div>'.freeze

        end

        # TODO: External template file
        <<-HTML
<!DOCTYPE html>
<html>
  <head>
    <title>#{title}</title>
    <style>
    #{css}
    </style>
  </head>
  <body style="background-color: #{body_bg};" class="viewsource-body">
   <div class="highlight">
#{body}
#{linkback}
   </div>
  </body>
</html>
HTML

      end

    end
  end
end
