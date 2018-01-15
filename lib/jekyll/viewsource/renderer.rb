require 'htmlbeautifier'
require 'rouge'
require 'jekyll/viewsource/utils'
require 'jekyll/viewsource/cache'
require 'jekyll/viewsource/lexer'

module Jekyll
  module ViewSource
    module Renderer

      def self.render_items
        @render_items ||= []
      end

      def self.render_source_files(site)
        render_items.each do |item|
          pretty = item.data[PRETTY_PROP]
          item.data.delete(PRETTY_PROP)

          linkback = item.data[LINKBACK_PROP]
          item.data.delete(LINKBACK_PROP)

          ext = pretty ? HTML : TXT

          source_md = Utils.source_file(item)

          source_url = item.data[SOURCE_URL]
          html_source_url = item.data[HTML_SOURCE_URL]

          next unless source_url || html_source_url

          if source_url
            source_file = source_md.chomp(
              pretty ? INFIXED_HTML : INFIXED_TXT
            )

            dest_file = File.join(site.dest, source_url)

            if Cache.modified?(source_md, dest_file)
              FileUtils.mkdir_p Pathname(dest_file).dirname

              if pretty
                ViewSource.debug item, "Pretty MD: #{source_url}"
                File.write(dest_file, prettify(source_file, 'md', pretty, linkback))
              else
                ViewSource.debug item, "Plain MD: #{source_url}"
                FileUtils.cp source_file, dest_file
              end

              Cache.contents(source_md, dest_file, File.read(dest_file))

            else
              File.write(dest_file, Cache.contents(source_md, dest_file))
              if pretty
                ViewSource.debug item, "Pretty MD: #{source_url} (cached)"
              else
                ViewSource.debug item, "Plain MD: #{source_url} (cached)"
              end

            end
          end

          if html_source_url
            dest_file = File.join(site.dest, html_source_url)
            source_file = dest_file.chomp(pretty ? INFIXED_HTML : INFIXED_TXT)

            if Cache.modified?(source_md, dest_file)
              FileUtils.mkdir_p Pathname(dest_file).dirname

              if pretty
                ViewSource.debug item, "Pretty HTML: #{html_source_url}"
                File.write(dest_file, prettify(source_file, HTML, pretty, linkback))
              else
                # Prettify it as text a bit, anyway
                source_code = HtmlBeautifier.beautify File.read(source_file)
                ViewSource.debug item, "Plain HTML: #{html_source_url}"
                File.write(dest_file, source_code)
              end

              Cache.contents(source_md, dest_file, File.read(dest_file))

            else
              File.write(dest_file, Cache.contents(source_md, dest_file))
              if pretty
                ViewSource.debug item, "Pretty HTML: #{html_source_url} (cached)"
              else
                ViewSource.debug item, "Plain HTML: #{html_source_url} (cached)"
              end

            end

          end
        end
        render_items.clear

      end

      def self.prettify(source_file, type, user_css, linkback = nil)
        source_code = File.read(source_file)
        title = File.basename(source_file)

        if type == 'html'
          source_code = HtmlBeautifier.beautify source_code
        end

        formatter = Rouge::Formatters::HTML.new
        if type == 'md'
          lexer = Rouge::Lexers::ViewSource.new
        else
          lexer = Rouge::Lexers::HTML.new
        end

        formatted = formatter.format(lexer.lex(source_code))

        body = "<pre>#{formatted}</pre>"

        if user_css
          if user_css =~ /^\//
            css = File.read(File.join(site.dest, user_css))
          else
            theme = Rouge::Theme.find(user_css)
            if theme
              css = theme.render(scope: CSS_SCOPE)
            else
              css = Rouge::Theme.find(DEFAULT_CSS).render(scope: CSS_SCOPE)
            end
          end
        end

        if m = css.match(/^\.highlight {.*?background-color:\s*(.*?);/m)
          body_bg = m[1];
        else
          body_bg = '#808080'
        end

        if linkback
          (lb_url, lb_text) = linkback.split('|$|', 2)
          linkback = %Q(<div style="background-color: #fff; color: #000; padding: 5px;" class="viewsource-linkback">&laquo; <a href="#{lb_url}">#{lb_text}</a></div>)

        end

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
