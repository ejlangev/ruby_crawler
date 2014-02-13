# RubyCrawler

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'ruby_crawler'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install ruby_crawler

## Usage

```ruby
require 'ruby_crawler'

RubyCrawler.crawl('http://url.com')
```

By default the crawler prints the resulting sitemap to stdout but
crawl takes an optional second argument for a file to write the
results to.

```ruby
file = File.new('sitemap', 'w')

RubyCrawler.crawl('http://url.com', file)
```

For debugging purposes:

Set RubyCrawler::DEBUG to be something that responds to puts in
order to see debug output

e.g
```ruby
RubyCrawler::DEBUG = $stdout
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
