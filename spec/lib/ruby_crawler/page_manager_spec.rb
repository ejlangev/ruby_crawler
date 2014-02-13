require 'spec_helper'

describe RubyCrawler::PageManager do

  context 'Adding attributes to a page' do

    it 'reuses the same page when adding multiple link sets' do
      subject.add_links_to_page('abc', '1', '2', '3')
      subject.add_links_to_page('abc', '4', '5')

      expect(
        subject.page_map.keys
      ).to eql(['abc'])

      expect(
        subject.page_map['abc'].links.size
      ).to eql(5)
    end

    it 'keeps the links on a page unique' do
      subject.add_links_to_page('abc', '1', '2', '3')
      subject.add_links_to_page('abc', '4', '3')

      expect(
        subject.page_map['abc'].links.size
      ).to eql(4)
    end

    it 'does not create a new page when adding static assets to a
        page that already exists' do
      subject.add_links_to_page('abc', '1', '2')
      subject.add_assets_to_page('abc', '4', '5')

      expect(
        subject.page_map.keys
      ).to eql(['abc'])

      expect(
        subject.page_map['abc'].static_assets.size
      ).to eql(2)
    end

  end

  context 'Iterating over pages' do
    it 'allows iterating over all the pages' do
      page_count = 0
      subject.add_links_to_page('abc', '1', '2')
      subject.add_links_to_page('def', '3', '4')
      subject.each do |page|
        page_count += 1
      end

      expect(page_count).to eql(2)
    end
  end

end