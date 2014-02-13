module RubyCrawler

  #
  # Class to manage the collection of pages we have loaded
  # from the site we are crawling
  #
  # @author [ejlangev]
  #
  class PageManager

    # @!attribute page_map
    # @return [Hash] A map from string to Page object
    attr_reader :page_map

    # include enumerable so that we can simply iterate
    # over this as a collection of pages later on
    include Enumerable

    def initialize
      # Set up the page map
      @page_map = Hash.new
    end

    #
    # Delegates to the Page class to add assets
    #
    # @param  url [String] A standardized url
    # @param  *assets [Array<String>] List of assets to add
    #
    # @return [Boolean] Always true
    def add_assets_to_page(url, *assets)
      self.fetch_page(url).add_static_assets(assets)
      true
    end

    #
    # Delegates to the Page class to add links
    #
    # @param  url [String] A standardized url
    # @param  *links [Array<String>] List of links to add
    #
    # @return [Boolean] Always true
    def add_links_to_page(url, *links)
      self.fetch_page(url).add_links(links)
      true
    end

    #
    # Implementation of each so that we are enumerable
    # just delegate to the values of the page map
    #
    # @param  &block [Block]
    #
    # @return [Iterator]
    def each(&block)
      self.page_map.values.each(&block)
    end

    protected

      #
      # Fetches the page for the given url, creating a new
      # one if none exists
      #
      # @param  url [String] Assumed to be a standardized url
      # from the url manager
      #
      # @return [Page]
      def fetch_page(url)
        self.page_map[url] ||= Page.new(url)
      end

    #
    # Interior class to handle representing pages and the information
    # we need to store about them
    #
    # @author [ejlangev]
    #
    class Page

      # @!attribute links
      # @return [Array<String>] An array of formatted standardized
      # url links that represent other pages this page links to
      attr_reader :links

      # @!attribute static_assets
      # @return [Array<String>] An array of formatted standardized
      # url links to static assets that this page uses
      attr_reader :static_assets

      # @!attribute url
      # @return [String] A formatted standardized url that
      # this page represents
      attr_reader :url

      #
      # @param  url [String] Formatted url for this page
      def initialize(url)
        @url = url
        @links = []
        @static_assets = []
      end

      #
      # Adds a list of links to the set that this page
      # already points to
      #
      # @param  urls [Array<String>] New formatted urls to add
      #
      # @return [Boolean] Always true
      def add_links(urls)
        @links.push(*urls)
        @links.uniq!
        true
      end

      #
      # Adds a list of links to static assets to this page
      # @param  assets [Array<String>]
      #
      # @return [Boolean] Always true
      def add_static_assets(assets)
        @static_assets.push(*assets)
        @static_assets.uniq!
        true
      end

    end

  end

end