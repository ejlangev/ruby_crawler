require 'spec_helper'

describe RubyCrawler::UrlManager do

  subject {
    RubyCrawler::UrlManager.new(
      'http://joingrouper.com'
    )
  }

  context '#mark_crawled' do

    it 'should be able to detect variations of the root domain' do
      subject.mark_crawled('http://joingrouper.com')

      expect(
        subject.is_crawled?('http://joingrouper.com')
      )
      expect(
        subject.is_crawled?('http://joingrouper.com/')
      ).to be_true
    end

    it 'should ignore url parameters' do
      subject.mark_crawled('http://joingrouper.com')

      expect(
        subject.is_crawled?('http://joingrouper.com?abc=true')
      ).to be_true
    end

    it 'should ignore fragments' do
      subject.mark_crawled('/')

      expect(
        subject.is_crawled?('http://joingrouper.com/#')
      ).to be_true
    end

    it 'should respect relative paths' do
      subject.mark_crawled('http://joingrouper.com')

      expect(
        subject.is_crawled?('/')
      ).to be_true
    end

    it 'works for paths other than the root' do
      subject.mark_crawled('http://joingrouper.com/press')

      expect(
        subject.is_crawled?('http://joingrouper.com/press')
      ).to be_true

      expect(
        subject.is_crawled?('/press')
      ).to be_true

      expect(
        subject.is_crawled?('/press?abc=true')
      ).to be_true

      expect(
        subject.is_crawled?('/')
      ).to be_false

      expect(
        subject.is_crawled?('http://joingrouper.com/press/abc')
      ).to be_false
    end

  end

  context '#is_crawlable?' do
    it 'allows full paths to be crawled' do
      expect(
        subject.is_crawlable?('http://joingrouper.com/press')
      ).to be_true
    end

    it 'allows absolute paths to be crawled' do
      expect(
        subject.is_crawlable?('/join')
      ).to be_true
    end

    it 'does not allow wrong domains to be crawlable' do
      expect(
        subject.is_crawlable?('http://google.com')
      ).to be_false
    end
  end

end