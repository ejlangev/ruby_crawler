require "ruby_crawler/version"
require 'ruby_crawler/url_manager'
require 'ruby_crawler/page_manager'
require 'nokogiri'
require 'rest-client'

module RubyCrawler
  # Debug flag set to nil by default, set to some
  # object that responds to puts for debug output
  DEBUG = nil

  #
  # Root method for crawling a domain, give it a
  # starting url and an output location which defaults
  # to stdout
  #
  # @param  url [String] The string representing the
  # domain to start crawling at
  #
  # @param  output = $stdout [Output] [description]
  #
  # @return [Boolean] Always true
  def self.crawl(url, output = $stdout)
    # create a new UrlManager object to keep track of
    # places that have already been crawled
    urlManager = UrlManager.new(url)
    # create a new PageManager object to deal with
    # finding or creating pages of the site that will
    # be included in the sitemap
    pageManager = PageManager.new
    # a list of pages to crawl, we are done when
    # this list becomes empty.  It starts as just the
    # root url
    pagesRemaining = [ urlManager.root_uri.to_s ]
    # Start crawling, one of the only times it seems
    # to make sense to use a while loop
    while !pagesRemaining.empty?
      # Shift the url off the top of the queue and crawl it
      currentUrl = pagesRemaining.shift
      # Mark this url as having already been loaded in the
      # UrlManager
      urlManager.mark_crawled(currentUrl)
      document = self.load_page(currentUrl)
      # Returns nil if loading that page encountered
      # some kind of error
      next if document.nil?
      # First extract all the urls we need to crawl while
      # setting up the links on this page
      to_crawl = self.parse_links(
        currentUrl,
        document,
        urlManager,
        pageManager
      )
      # Add any new uncrawled pages into our list of pages
      # to crawl, can't allow duplicates because everything
      # in this list has not already been crawled and we make
      # sure the list is unique
      pagesRemaining += to_crawl
      pagesRemaining.uniq!
      # Then deal with any assets on this page
      self.parse_assets(currentUrl, document, pageManager)
      DEBUG.puts "Pages remaining: #{pagesRemaining.size}" if DEBUG
    end
    # Once we get here there are no more known pages to crawl
    # so we can just iterate over the pageManager and write everything
    # out into output
    self.print_output(pageManager, output)
    true
  end

  protected

    #
    # Very simple error handling function for when things
    # go wrong with the http requests, definitely eats errors
    # it shouldn't but has the advantage of being simple
    #
    # @param  &block [Block]
    #
    # @return [Object] Nil after an error, otherwise the
    # result of the block
    def self.handle_http_errors(&block)
      begin
        yield
      rescue RestClient::Unauthorized
        DEBUG.puts "Unauthorized error loading page, skipping" if DEBUG
        nil
      rescue RestClient::ResourceNotFound
        DEBUG.puts "Page not found, skipping" if DEBUG
        nil
      rescue
        DEBUG.puts "Unknown error, continuing" if DEBUG
        nil
      end
    end
    #
    # Loads the page with a rest-client get request and parses
    # it with nokogiri
    #
    # @param  url [String] A formatted url to request
    #
    # @return [Nokogiri::HTML::Document]
    def self.load_page(url)
      DEBUG.puts "Crawling #{url}" if DEBUG
      handle_http_errors do
        Nokogiri::HTML(
          RestClient.get(url)
        )
      end
    end

    #
    # Parses the assets from a given page
    #
    # @param  url [String] The url of the page
    # @param  document [Nokogiri::HTML::Document] The parse html response
    # @param  pageManager [PageManager] Object for storing data about pages
    # that have been loaded
    #
    # @return [Boolean] Always true
    def self.parse_assets(url, document, pageManager)
      DEBUG.puts "Processing assets from #{url}" if DEBUG
      # Variable to hold all the assets to add in
      # a single shot
      assets = []
      # First deal with JS assets
      document.css('script').each do |script|
        src = script.attr('src')

        unless src.nil? || src.empty?
          assets << src
        end
      end
      # Then deal with linked assets (link tags)
      document.css('link').each do |link|
        href = link.attr('href')

        unless href.nil? || href.empty?
          assets << href
        end
      end
      # Then deal with image assets
      document.css('img').each do |img|
        src = img.attr('src')

        unless src.nil? || src.empty?
          assets << src
        end
      end
      # Finally we've gotten all the assets out so add
      # them in bulk to the page
      pageManager.add_assets_to_page(url, *assets)
      true
    end

    #
    # Parses the links out of the html document
    #
    # @param  url [String] The url of the page that was just
    # loaded
    # @param  document [Nokogiri::HTML::Document] The parse html response
    # @param  urlManager [UrlManager] Object for helping determine which
    # urls to crawl and which have been crawled
    # @param  pageManager [PageManager] Object responsible for storing
    # data about different pages in an easy to use format
    #
    # @return [Array<String>] Array of links on this page
    # left to crawl
    def self.parse_links(url, document, urlManager, pageManager)
      DEBUG.puts "Processing links from #{url}" if DEBUG
      # Local variables for what to return and what
      # to add to the page's list of links
      to_crawl = []
      to_add = []
      # Find all the links on the page
      document.css('a').each do |link|
        # Get the href of the link
        href = link.attr('href')
        # Skip it if it is blank
        next if href.nil? || href.empty?
        href = urlManager.standardize_url(href)
        # If the link is crawlable
        if urlManager.is_crawlable?(href)
          to_add << href.to_s
          # If it is crawlable and has not been crawled
          # add it to the list of urls to crawl
          unless urlManager.is_crawled?(href)
            to_crawl << href.to_s
          end
        end
      end

      # Once we're finished add the to_add list to the pages
      # set of links and return the to_crawl
      pageManager.add_links_to_page(url, *to_add)
      # return what's left to crawl
      return to_crawl
    end

    #
    # Formats and prints out the result of the crawl to the given
    # output (stdout by default)
    # @param  pageManager [PageManager] Store for page data
    # @param  output [Output]
    #
    # @return [Boolean] Always true
    def self.print_output(pageManager, output)
      pageManager.each do |page|
        output.puts "URL: #{page.url}"
        output.puts "Links:"
        page.links.each do |link|
          output.puts "\t- #{link}"
        end
        output.puts "Assets:"
        page.static_assets.each do |asset|
          output.puts "\t- #{asset}"
        end
        puts "\n"
      end

      true
    end


end
