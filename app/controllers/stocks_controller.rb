class StocksController < ApplicationController
  def search
    @symbol = params[:stock].to_s.upcase
    @price  = Stock.new_lookup(@symbol)

    if @symbol.blank?
        flash[:alert] = "Please enter a ticker and try again."
        redirect_to my_portfolio_path
      elsif @price.present?
        @stock = @price.respond_to?(:last_price) ? @price : Stock.new(ticker: @symbol, name: @symbol, last_price: @price)
        render 'users/my_portfolio'
      else
        flash[:alert] = "Price unavailable for #{@symbol}. Try another ticker."
        redirect_to my_portfolio_path
      end
  end
end
