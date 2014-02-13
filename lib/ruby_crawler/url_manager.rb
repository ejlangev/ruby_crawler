require 'uri'
require 'byebug'

module RubyCrawler

  #
  # Class to manager which urls have already been
  # crawled
  #
  # @author [ejlangev]
  #
  class UrlManager

    # @!attribute crawled_map
    # @return [Hash] Hash from URL to boolean
    attr_reader :crawled_map

    # @!attribute root_uri
    # @return [URI] The uri for the root domain, used
    # to standardize relative paths
    attr_reader :root_uri

    #
    # @param  root [String] Url for the root domain
    def initialize(root)
      @crawled_map = Hash.new
      @root_uri = URI(root)
    end

    #
    # Takes a string url and sets it as having
    # been crawled.  Afterwards all is_crawled? queries
    # regarding that page should return true
    #
    # @param  url [String] The url to set as crawled
    #
    # @return [Boolean] Always true
    def mark_crawled(url)
      crawled_map[self.standardize_url(url).to_s] = true
    end

    #
    # Checks if a given url is on the same domain
    # as the root_uri
    #
    # @param  url [String] Unformatted url
    #
    # @return [Boolean] True if this is on the same domain
    def is_crawlable?(url)
      self.standardize_url(url).host == self.root_uri.host
    end

    #
    # Checks whether a given string url has already
    # been crawled
    #
    # @param  url [String] The url to check
    #
    # @return [Boolean] True if crawled, false otherwise
    def is_crawled?(url)
      # coerce into a boolean in a simple way
      !!crawled_map[self.standardize_url(url).to_s]
    end

    #
    # Takes a string url and standardizes
    # it for checking against the crawled_map
    #
    # @param  url [String] The unstandardized url
    #
    # @return [URL] A standardized URL object
    def standardize_url(url)
      uri = URI(url)
      # Short circuit for mailto links since
      # the rest of this code won't work for them
      if uri.scheme == 'mailto'
        return uri
      end
      # If there is no path, set it to /
      if uri.path.empty?
        uri.path = '/'
      end
      # Set the query string to be nil
      uri.query = nil
      uri.fragment = nil
      # Fill in any unset variables
      uri.scheme ||= @root_uri.scheme
      uri.host ||= @root_uri.host
      uri
    end

  end

end