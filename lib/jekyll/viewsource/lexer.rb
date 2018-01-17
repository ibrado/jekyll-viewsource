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

        rule(%r(\s*<!--.*?-->\s*)m) { delegate html }

        rule %r(({%)(\s*)(macro)(\s+)(/.*?/\S*)(\s*)({)) do
          groups Punctuation, Text::Whitespace, Name::Tag, Text::Whitespace, Str::Double, Text::Whitespace, Punctuation
        end

        rule %r((})(\s*)(%})) do
          groups Punctuation, Text::Whitespace, Punctuation
        end

        rule %r(({%)(\s*)(constant)(\s+)(\S+)(\s*)(=?)(\s*)(['"]?)(.*?)(['"]?)(\s*)(%})) do
          groups Punctuation, Text::Whitespace, Name::Tag, Text::Whitespace, 
            Name::Attribute, Text::Whitespace, Punctuation, Text::Whitespace,
            Punctuation, Str::Double, Punctuation, Text::Whitespace, Punctuation
        end

        rule %r((\s*)({%)(\s*)(hashkeys)(\s+)(\S+)(\s*)(%})) do
          groups Text::Whitespace, Punctuation, Text::Whitespace, Name::Tag,
          Text::Whitespace, Name::Attribute, Text::Whitespace, Punctuation
        end

        rule %r((\s*)({%)(\s*)(hashkeys)(\s+)(\S+)(\s*)({)(.*?)(})(\s*)(%})) do
          groups Text::Whitespace, Punctuation, Text::Whitespace,
          Name::Tag, Text::Whitespace, Name::Attribute, Text::Whitespace,
          Punctuation, Text, Punctuation, Text::Whitespace, Punctuation
        end

        rule %r(({%)(\s*)(project)(\s*)(.*?)(\s*)(%})) do
          groups Punctuation, Text::Whitespace, Name::Tag, Text::Whitespace, Text,
            Text::Whitespace, Punctuation
        end

        rule(%r(.*?{%.*?%}.?)) { delegate liquid }
        rule(%r(.*{{.*?}}.?)) { delegate liquid }
      end

    end
  end
end
