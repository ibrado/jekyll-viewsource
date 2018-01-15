module Jekyll
  module ViewSource

    # Temp compatibility
    TINYTOOLS = 'tinytools'.freeze

    VIEWSOURCE = 'viewsource'.freeze
    VIEWSOURCE_LOG = 'ViewSource:'.freeze

    SOURCE_FILE = "#{VIEWSOURCE}_file".freeze
    PRETTY_PROP = "#{VIEWSOURCE}_pretty".freeze
    LINKBACK_PROP = "#{VIEWSOURCE}_linkback".freeze

    DEFAULT_CSS = 'github'.freeze
    CSS_SCOPE = '.highlight'.freeze

    HTML = 'html'.freeze
    TXT = 'txt'.freeze
    MD = 'md'.freeze

  end
end
