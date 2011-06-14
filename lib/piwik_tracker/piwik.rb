require 'uri'
require 'json'
require 'patron'

module PiwikTracker
  
  # Piwik HTTP client
  # piwik = Piwik.new('http://yoursite.com/piwik', 6)
  # piwik.request(auth_token).
  #   url('http://yoursite.com/some-page.html').
  #   custom_variable(:foobar, 'value').
  #   track_page_view('Page Title')
  class Piwik

    MAX_INT = 2 ** ((['foo'].pack('p').size * 8) - 1) - 1  	
    
    HTTP_TIMEOUT = 20
    USER_AGENT = "piwik-tracker/#{PiwikTracker::VERSION}"
    
    attr_accessor :debug
    attr_writer :logger

    # base_uri - the location of your Piwik installation, i.e. 'http://yoursite.com/piwik'.
    # site_id  - Id of the site to be tracked
    def initialize(base_uri, site_id)
      @base_uri = base_uri
      @site_id = site_id
    end

    # sends a tracking request
    def track(params)
      send_request params.merge( 'idsite' => @site_id,
                                 'rec'    => 1,
                                 'rand'   => rand(MAX_INT) )
    end


    protected

    def logger
      @logger ||= (require 'logger'; Logger.new($stdout))
    end

    def send_request(params)
      headers = { 'Accept-Language' => params.delete(:browser_language) }
      headers['User-Agent'] = params.delete(:user_agent) if params.key?(:user_agent)
      url = "piwik.php?#{hash_to_querystring(params)}"
      logger.debug "Piwik request:\n#{url}\n#{headers.inspect}"
      http.get url, headers
    end

    def http
      @http ||= connect
    end

    def hash_to_querystring(hash)
      (keys = hash.keys).inject('') do |query_string, key|
        query_string << '&' unless key == keys.first
        query_string << "#{URI.encode(key.to_s)}=#{URI.encode(hash[key].to_s)}"
      end
    end

    def connect
      Patron::Session.new.tap do |session|
        session.timeout = HTTP_TIMEOUT
        session.base_url = @base_uri
        session.headers['User-Agent'] = USER_AGENT
      end
    end


    public

    class Request

      # Piwik API version
      VERSION = 1

      # length of Piwik visitor ids
      VISITOR_ID_LENGTH = 16

      def initialize(piwik, auth_token = nil)
        @piwik = piwik
        @custom_variables = []
        @data = {}
        @data[:token_auth] = auth_token if auth_token
      end
      
      # Chainable attribute setters
      ########################### 
      
      # Sets the current URL being tracked
      def url(url)
        @data[:url] = url
        self
      end
      
      # Sets the URL referrer used to track Referrers details for new visits.
      def referrer(url)
        @data[:urlref] = url
        self
      end
      
      # Sets the attribution information to the visit, so that subsequent Goal conversions are 
      # properly attributed to the right Referrer URL, timestamp, Campaign Name & Keyword.
      # info - 4 element array of [campaign name, campaign keyword, Timestamp at which the referrer was set, Referrer URL]
      def attribution_info(info)
        info = JSON.parse(info) if String === info
        @data[:_rcn], @data[:_rck], @data[:_refts], @data[:_ref] = info
        self
      end
      
      # Sets Visit Custom Variable.
      # See http://piwik.org/docs/custom-variables/
      # slot_id - Custom variable slot ID from 1-5
      # name - Custom variable name
      # value - Custom variable value
      def custom_variable(slot_id, name, value)
        raise "invalid slot id, has to be between 1 and 5" unless (1..5).include?(slot_id)
        @custom_variables[slot_id - 1] = [name, value]
        self
      end
      
      def browser_language(lang)
        @data[:browser_language] = lang
        self
      end
      
      def user_agent(name)
        @data[:user_agent] = name
        self
      end
      
      # Overrides server date and time for the tracking requests. 
      # By default Piwik will track requests for the "current datetime" but this function allows you 
      # to track visits in the past.
      # time - ruby Time instance
      def forced_date_time(time)
        @data[:cdt] = time.utc.to_i
        self
      end
      
      # Overrides IP address
      # client_ip - IP address string
      def ip(client_ip)
        @data[:cip] = client_ip
        self
      end
      
      # Forces the requests to be recorded for the specified Visitor ID
      # rather than using the heuristics based on IP and other attributes.
      # id - 16 hexadecimal characters visitor ID, eg. "33c31e01394bdc63"
      def visitor_id(id)
        raise "visitor_id must be exactly #{VISITOR_ID_LENGTH} characters long" unless id.to_s.length == VISITOR_ID_LENGTH
        @data[:cid] = id
        self
      end
      
      
      
      # Tracking functions
      ########################### 
    
      # Tracks a page view
      # document_title is the page title as it will appear in the Actions > Page titles report
      def track_pageview(document_title)
        @piwik.track request_params.merge(:action_name => document_title)
      end
    
      # Records a Goal conversion
      # goal_id - Id of the goal to record
      # revenue - revenue for this conversion
      def track_goal(goal_id, revenue = nil)
        params = request_params.merge :idgoal => goal_id
        params[:revenue] = revenue if revenue
        @piwik.track params
      end
    
      # Tracks a download or outlink
      # action_url - URL of the download or outlink
      # action_type Type of the action: :download or :link
      def track_action(action_url, action_type)
        @piwik.track request_params.merge(action_type => action_url, :redirect => '0')
      end
    
      protected
      
      def request_params
        @data.dup.tap do |params|
          params[:_cvar] = @custom_variables.to_json if @custom_variables.any?
        end
      end
    
    end
    
    
    # generates a new request object.
    # 
    # Some Tracking API functionnality requires express authentication, using either the 
    # Super User token_auth, or a user with 'admin' access to the website.
    # 
    # The following features require access:
    # - force the visitor IP
    # - force the date & time of the tracking requests rather than track for the current datetime
    # - force Piwik to track the requests to a specific VisitorId rather than use the standard visitor matching heuristic
    def request(auth_token = nil)
      Request.new self, auth_token
    end
  end
  
end
