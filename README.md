# Jekyll::ViewSource

[![Gem Version](https://badge.fury.io/rb/jekyll-viewsource.svg)](https://badge.fury.io/rb/jekyll-viewsource)

*Jekyll:ViewSource* is a plugin for [Jekyll](https://jekyllrb.com/) that generates plain or pretty Markdown and HTML source code pages from your content.

## Installation

Add the gem to your application's Gemfile:

```ruby
group :jekyll_plugins do
  # other plugins here
  gem 'jekyll-viewsource'
end
```

And then execute:

    $ bundle

Or install it yourself:

    $ gem install jekyll-viewsource

## Configuration

No configuration is required to run *Jekyll::ViewSource*. If you want to tweak its behavior, you may set the following options in `_config.yml`:

```yaml
viewsource:
  #enabled: false                    # Default: true
  debug: true                        # Show additional messages during run; default: false
  #collection: pages, "articles"     # Which collections to paginate; default: pages and posts
  collections:                       # Ditto, just a different way of writing it
    - pages                          # Quotes are optional if collection names are obviously strings
    - posts
    - articles
  options: pretty                    # Options that normally go in a doc's front matter
```

## Usage

Just add a `viewsource: true` entry to the front-matter of the content for you want to create source files:

### Plain Markdown

```yaml
---
viewsource: true
---
```

(or `viewsource: md` or `viewsource: markdown`)

### Plain HTML

```yaml
viewsource: html
```

### Plain Markdown and HTML

```yaml
viewsource: markdown, html
```

### Prettified

Add <code>pretty[="<rouge_template|css_path>"]</code>, e.g.

```yaml
viewsource: markdown, html, pretty
```

```yaml
viewsource: markdown, html, pretty="thankful_eyes"
```

```yaml
viewsource: markdown, html, pretty="/url/path/to/syntax.css"
```

You may show the themes currently supported by Rouge via the command line:

    $ rougify help style

As of this writing, these are:

  * base16, base16.dark, base16.light
  * base16.monokai, base16.monokai.dark, base16.monokai.light
  * base16.solarized, base16.solarized.dark, base16.solarized.light
  * colorful
  * github
  * gruvbox, gruvbox.dark, gruvbox.light
  * igorpro
  * molokai
  * monokai, monokai.sublime
  * thankful_eyes
  * tulip

The default is `github`

### Source file links

To link to your source files, use the following:

`{{ page.source_url }}`
: The plain or pretty Markdown source URL

`{{ page.html_source_url }}`
: The plain or pretty HTML source URL

e.g. 

```liquid
[View Markdown source]({{ page.source_url }})
[View HTML source]({{ page.html_source_url }})
```

### Demo

[View Markdown source](https://ibrado.org/jvs.md-src.html)

[View HTML source](https://ibrado.org/jvs/index.html-src.html)

## Cache

*ViewSource* has a cache at `*site_source*/.plugins/jekyll-viewsource`. If you encounter problems that you think may be related to the cache, you may remove this.

## Contributing

1. Fork this project: [https://github.com/ibrado/jekyll-viewsource/fork](https://github.com/ibrado/jekyll-viewsource/fork)
1. Clone it (`git clone git://github.com/your_user_name/jekyll-viewsource.git`)
1. `cd jekyll-viewsource`
1. Create a new branch (e.g. `git checkout -b my-bug-fix`)
1. Make your changes
1. Commit your changes (`git commit -m "Bug fix"`)
1. Build it (`gem build jekyll-viewsource.gemspec`)
1. Install and test it (`gem install ./jekyll-viewsource-*.gem`)
1. Repeat from step 5 as necessary
1. Push the branch (`git push -u origin my-bug-fix`)
1. Create a Pull Request, making sure to select the proper branch, e.g. `my-bug-fix` (via https://github.com/your_user_name/jekyll-viewsource)

Bug reports and pull requests are welcome on GitHub at [https://github.com/ibrado/jekyll-viewsource](https://github.com/ibrado/jekyll-viewsource). This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Jekyll::ViewSource project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/jekyll-viewsource/blob/master/CODE_OF_CONDUCT.md).

## Also by the Author

[Jekyll Stickyposts Plugin](https://github.com/ibrado/jekyll-stickyposts) - Move/pin posts tagged `sticky: true` before all others. Sorting on custom fields supported; collection and paginator friendly.

[Jekyll Tweetsert Plugin](https://github.com/ibrado/jekyll-tweetsert) - Turn tweets into Jekyll posts. Multiple timelines, filters, hashtags, automatic category/tags, and more!

[Jekyll::Paginate::Content](https://github.com/ibrado/jekyll-tweetsert) - Split your Jekyll pages, posts, etc. into multiple pages automatically. Single-page view, pager, SEO support, self-adjusting links, multipage-aware Table Of Contents.

