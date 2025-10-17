require 'faraday'
require 'json'

class Fmp
  BASE = 'https://financialmodelingprep.com/stable'

  def initialize(api_key: ENV.fetch('FMP_API_KEY'))
    @api_key = api_key
    @http = Faraday.new do |f|
      f.request :retry, max: 3, interval: 0.3, interval_randomness: 0.5, backoff_factor: 2
      f.response :raise_error
      f.adapter Faraday.default_adapter
    end
  end

  def get(path, params = {})
    url = "#{BASE}/#{path}"
    resp = @http.get(url, params.merge(apikey: @api_key))
    JSON.parse(resp.body)
  end

  # --- common convenience methods ---

  # Real-time quote (full)
  # https://financialmodelingprep.com/stable/quote?symbol=AAPL
  def quote(symbol)
    get('quote', symbol: symbol).first
  end

  # Lightweight quote (price/volume)
  # https://financialmodelingprep.com/stable/quote-short?symbol=AAPL
  def quote_short(symbol)
    get('quote-short', symbol: symbol).first
  end

  # Company profile
  # https://financialmodelingprep.com/stable/profile?symbol=AAPL
  def profile(symbol)
    get('profile', symbol: symbol).first
  end

  # Daily historical EOD (15y)
  # https://financialmodelingprep.com/stable/historical-price-eod/full?symbol=AAPL
  def historical_eod(symbol, variant: 'full') # or 'light'
    get("historical-price-eod/#{variant}", symbol: symbol).fetch('historical')
  end

  # Intraday bars (1min, 5min, 1hour, etc.)
  # https://financialmodelingprep.com/stable/historical-chart/1min?symbol=AAPL
  def intraday(symbol, interval: '1min')
    get("historical-chart/#{interval}", symbol: symbol)
  end

  # Search
  # https://financialmodelingprep.com/stable/search-symbol?query=AAPL
  def search(query)
    get('search-symbol', query: query)
  end
end

# ---- usage ----
# client = FMP.new(api_key: 'YOUR_API_KEY')
# puts client.quote('AAPL')
# puts client.quote_short('AAPL')
# puts client.profile('AAPL')
# p client.historical_eod('AAPL', variant: 'light').first
# p client.intraday('AAPL', interval: '5min').first
# p client.search('Apple')