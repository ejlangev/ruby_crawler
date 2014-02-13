require 'spec_helper'

describe RubyCrawler do

  context 'parsing a simple page' do

    it 'adds the proper static assets' do
      page = %Q{
        <html>
          <head>
            <link href='http://abc.net' />
            <script src='http://def.net'></script>
          </head>
          <body>
            <img src='http://ghi.net' />
          </body>
        </html>
      }

      RestClient.expects(:get)
        .with('http://joingrouper.com')
        .returns(page)

      RubyCrawler::PageManager.any_instance
        .expects(:add_assets_to_page)
        .with(
          'http://joingrouper.com',
          'http://def.net',
          'http://abc.net',
          'http://ghi.net'
        ).returns(true)

      RubyCrawler.crawl(
        'http://joingrouper.com',
        File.open(File::NULL, 'w')
      )
    end

    it 'adds the proper links and parses the new pages' do
      blank_page = %Q{
        <html><body></body></html>
      }
      page = %Q{
        <html>
          <body>
            <a href='/press'>Press</a>
            <a href='http://joingrouper.com/jobs'>Jobs</a>
          </body>
        </html
      }
      # Make sure the proper requests get made
      RestClient.expects(:get)
        .with('http://joingrouper.com')
        .returns(page)
      RestClient.expects(:get)
        .with('http://joingrouper.com/press')
        .returns(blank_page)
      RestClient.expects(:get)
        .with('http://joingrouper.com/jobs')
        .returns(blank_page)

      RubyCrawler::PageManager.any_instance
        .expects(:add_links_to_page)
        .with(
          'http://joingrouper.com',
          'http://joingrouper.com/press',
          'http://joingrouper.com/jobs'
        ).returns(true)

      RubyCrawler::PageManager.any_instance
        .expects(:add_links_to_page)
        .with(instance_of(String))
        .times(2)
        .returns(true)

      RubyCrawler.crawl(
        'http://joingrouper.com',
        File.open(File::NULL, 'w')
      )
    end

  end

end