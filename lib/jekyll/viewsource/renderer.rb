require 'htmlbeautifier'

module Jekyll
  module ViewSource
    module Renderer
      require_relative 'constants'
      require_relative 'utils'
      require_relative 'lexer'

      @render_items = []

      INFIX = '-src'.freeze

      INFIXED_HTML = "#{INFIX}.#{HTML}".freeze
      INFIXED_TXT = "#{INFIX}.#{TXT}".freeze

      PRETTY = 'Pretty'.freeze
      PLAIN = 'Plain'.freeze

      DEFAULT_BG = '#808080'.freeze

      CACHED = ' (cached)'.freeze

      def self.enqueue_html(item)
        @render_items << item
      end

      def self.render_item(site, item, file_url, ext, pretty = nil, linkback = nil)
        return unless file_url

        source_link = file_url +
          ( pretty ? INFIXED_HTML : INFIXED_TXT)

        puts "SITE.DEST #{site.dest} SOURCE_LINK: #{source_link}"

        dest_file = File.join(site.dest, source_link)
        source_md = Utils.source_file(item)

        source_file = (ext == MD ? source_md :
          site.source + '/' + file_url)

        if Cache.modified?(source_md, dest_file)
          cached = ''.freeze
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

          Cache.contents(source_file, dest_file, File.read(dest_file))

        else
          cached = CACHED
          File.write(dest_file, Cache.contents(source_file, dest_file))
        end

        ViewSource.debug item, (pretty ? PRETTY : PLAIN) +
          " #{ext}: #{source_link}#{cached}"

      end

      def self.render_html(site)
        @render_items.each do |item|
          source_file = item.data[SOURCE_FILE]
          next unless source_file

          pretty = item.data[PRETTY_PROP]
          linkback = item.data[LINKBACK_PROP]

          item.data.delete(SOURCE_FILE)
          item.data.delete(PRETTY_PROP)
          item.data.delete(LINKBACK_PROP)

          render_item(site, item, source_file, HTML, pretty, linkback)
        end

        @render_items.clear

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
