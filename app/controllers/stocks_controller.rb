# app/controllers/stocks_controller.rb
class StocksController < ApplicationController
  def search
    symbol = params[:stock].to_s.upcase.strip
    @tracked_stocks = current_user&.stocks || []

    if symbol.blank?
      @stock = nil
      flash.now[:alert] = "Please enter a ticker and try again."
    else
      @stock = Stock.look_up(symbol)  # <-- returns Stock or nil
      flash.now[:alert] = "Price/company unavailable for #{symbol}." if @stock.nil?
    end

    respond_to do |format|
      format.js   # renders app/views/stocks/search.js.erb
      format.html { render "users/my_portfolio" }
    end
  end
end