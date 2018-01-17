module Jekyll
  module ViewSource
    VIEWSOURCE = 'viewsource'.freeze
    VIEWSOURCE_LOG = 'ViewSource:'.freeze

    HTML = 'html'.freeze
    TXT = 'txt'.freeze
    MARKDOWN = 'markdown'.freeze
    MD = 'md'.freeze

    PR = 'pr'.freeze

    INFIX = '-src'.freeze
    INFIXED_HTML = "#{INFIX}.#{HTML}".freeze
    INFIXED_TXT = "#{INFIX}.#{TXT}".freeze

    MD_SOURCE_URL = 'source_url'.freeze
    PR_SOURCE_URL = 'prerender_source_url'.freeze
    HTML_SOURCE_URL = 'html_source_url'.freeze

    MD_FILE_PROP = "#{VIEWSOURCE}_file_md".freeze
    HTML_FILE_PROP = "#{VIEWSOURCE}_file_html".freeze

    PRETTY_PROP = "#{VIEWSOURCE}_pretty".freeze
    LINKBACK_PROP = "#{VIEWSOURCE}_linkback".freeze

    DEFAULT_CSS = 'github'.freeze
    CSS_SCOPE = '.highlight'.freeze

  end
end
