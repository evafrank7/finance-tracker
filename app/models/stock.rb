require "net/http"
require "json"
require "uri"
require "bigdecimal"

class Stock < ApplicationRecord
  has_many :user_stocks
  has_many :users, through: :user_stocks

  validates :name, :ticker, presence: true

  def self.look_up(ticker_symbol)
    return nil if ticker_symbol.blank?

    sym = ticker_symbol.to_s.upcase
    api_key = Rails.application.credentials.api_key[:key]
    raise "Set FMP_API_KEY in your environment" if api_key.blank?

    # 1) Try full quote (includes name & price on paid keys; sometimes on free, too)
    data = fetch_json("https://financialmodelingprep.com/stable/quote?symbol=#{sym}&apikey=#{api_key}")
    quote = Array(data).first if data

    # 2) If missing or empty, fall back to quote-short (price only)
    if quote.nil? || quote == {}
      short = fetch_json("https://financialmodelingprep.com/stable/quote-short?symbol=#{sym}&apikey=#{api_key}")
      quote = Array(short).first if short
    end

    return nil if quote.nil? || quote == {}

    symbol = quote["symbol"] || sym
    price  = quote["price"] || quote["previousClose"] || quote["close"]

    # 3) If we don't have a name yet, look it up via profile endpoint
    name = quote["name"] || quote["companyName"]
    if name.to_s.strip.empty?
      profile = fetch_json("https://financialmodelingprep.com/stable/profile?symbol=#{sym}&apikey=#{api_key}")
      prof = Array(profile).first if profile
      name = prof && (prof["companyName"] || prof["companyName"] || prof["companyName"]) # defensive
    end

    return nil if price.nil?

    new(
      ticker: symbol,
      name:   name.presence || symbol,
      last_price: BigDecimal(price.to_s)
    )
  rescue => e
    Rails.logger.warn("[Stock.look_up] #{e.class}: #{e.message}")
    nil
  end

  def self.check_db(ticker_symbol)
    where(ticker: ticker_symbol).first
  end

  private

  def self.fetch_json(url)
    uri = URI(url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = (uri.scheme == 'https')
    http.read_timeout = 6
    http.open_timeout = 4

    req = Net::HTTP::Get.new(uri.request_uri)
    res = http.request(req)

    unless res.is_a?(Net::HTTPSuccess)
      Rails.logger.warn("[Stock.fetch_json] HTTP #{res.code} for #{uri} :: #{res.body&.byteslice(0,200)}")
      return nil
    end

    JSON.parse(res.body)
  rescue => e
    Rails.logger.warn("[Stock.fetch_json] #{e.class}: #{e.message} for #{url}")
    nil
  end

  # Backwards-compatible alias if you previously called `new_lookup`
  class << self
    alias_method :new_lookup, :look_up
  end
end
