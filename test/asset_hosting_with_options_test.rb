require 'test/unit'
require 'rubygems'
require 'mocha'

$LOAD_PATH << File.dirname(__FILE__) + "/../lib"
require 'asset_hosting_with_minimum_ssl'


class AssetHostingWithOptionsTest < Test::Unit::TestCase
  def setup
    @asset_host = AssetHostingWithMinimumSsl.new("http://assets%d.example.com/", "https://assets1.example.com/", :only=>/^\/images\//, :except=>/^\/images\/local/)
  end
  
  def test_ssl_request_for_matching_path
    assert_match \
      ssl_host, 
      @asset_host.call("/images/image.jpg", ssl_request_from('IE'))
  end

  def test_no_asset_path_for_non_matching_path
    assert_equal \
      '', 
      @asset_host.call("/images/local/blank.gif", ssl_request_from("Safari"))

    assert_equal \
      '', 
      @asset_host.call("/stylesheets/application.css", ssl_request_from("Safari"))
  end

  private
    def non_ssl_host
      %r|http://assets\d.example.com/|
    end
  
    def ssl_host
      "https://assets1.example.com/"
    end
  
  
    def ssl_request_from(user_agent)
      stub(:headers => { "USER_AGENT" => user_agent }, :ssl? => true)
    end
end
