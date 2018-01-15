require 'rouge'

module Rouge
  module Lexers
    class ViewSource < Markdown
      tag 'viewsource'

      def liquid 
        @liquid ||= Liquid.new(options)
      end

      def javascript
        @javascript ||= Javascript.new(options)
      end

      def html 
        @html ||= HTML.new(options)
      end

      prepend :root do
        rule(%r[\s*(?<!:)//.*?$]) { delegate javascript }
        rule(%r(\s*/[*].*?[*]/\s*)m) { delegate javascript }

        rule(%r(.*?%}.?)) { delegate liquid }
        rule(%r(.*{{.*?}}.?)) { delegate liquid }

        rule(%r(\s*<!--.*?-->\s*)m) { delegate html }
      end


    end
  end
end
