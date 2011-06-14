require 'test_helper'
require 'piwik_tracker/piwik'

module PiwikTracker
  class PiwikTest < Test::Unit::TestCase
    
    # piwik = Piwik.new('http://yoursite.com/piwik', 6)
    # piwik.request(auth_token).
    #   url('http://yoursite.com/some-page.html').
    #   custom_variable(:foobar, 'value').
    #   track_page_view('Page Title')
    def setup
      @piwik = Piwik.new ENV['piwik'], ENV['site']
      @piwik.debug = true
      @request = @piwik.request(ENV['auth'])
    end

    test "should track pageview" do
      assert resp = @request.url('http://test.com/track_pageview').track_pageview( 'somwhere' )
      pp resp
    end

    test "should track action" do
      assert r = @request.url('http://test.com/track_action').track_action( 'http://targetsite.com/test.html', 'link' )
      pp r
    end

    test "should track goal" do
      assert r = @request.url('http://test.com/track_goal').track_goal( 1, 99 )
      pp r
    end
    
  end
end
