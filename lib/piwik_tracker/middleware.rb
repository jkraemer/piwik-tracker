module PiwikTracker
  # rack middleware to extract piwik site id and visitor id from request
  # cookies
  class Middleware

    def initialize(app)
      @app = app
    end

    def call(env)
      site_id, visitor_id = parse_cookie env
      env['piwik'] = {
        :site_id => site_id,
        :visitor_id => visitor_id
      }
      Rails.logger.debug "piwik env: #{env['piwik'].inspect}"
      @app.call(env)
    end
    
    private

    def parse_cookie(env)
      request = Rack::Request.new env
      request.cookies.each_pair do |name, value|
        if name =~ /^_pk_id\.(\d+)\.\w+$/
          return [$1.to_i, value.split('.').first]
        end
      end
      [nil, nil]
    end

  end
end
