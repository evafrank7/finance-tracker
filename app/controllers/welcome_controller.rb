class WelcomeController < ApplicationController
    def index
      symbol = params[:symbol].presence || "AAPL"
      @stock = Stock.look_up(symbol)
      flash.now[:alert] = "No quote data returned." if @stock.nil? || @stock.last_price.nil?
    end
end