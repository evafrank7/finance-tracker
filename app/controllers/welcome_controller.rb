class WelcomeController < ApplicationController
    def index
        key = ENV['FMP_API_KEY'] || Rails.application.credentials.dig(:fmp, :api_key)
        client = Fmp.new(api_key: key)
    
        @quote = begin
          data = client.quote('AAPL') # could be nil if API key missing / rate limit / offline
          data.is_a?(Hash) ? data : nil
        rescue => e
          Rails.logger.error("FMP quote error: #{e.class}: #{e.message}")
          nil
        end
    
        flash.now[:alert] = "Quote unavailable right now." if @quote.nil?
    end
end