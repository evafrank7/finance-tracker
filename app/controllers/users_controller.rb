class UsersController < ApplicationController
  def my_portfolio
    @tracked_stocks =  current_user.stocks
  end

  def my_friends
    @friends = current_user.friends
  end

  def show
    @user = User.find(params[:id])
    @tracked_stocks = @user.stocks
  end

  def search
    if params[:friend].present?
      @friends = current_user.except_current_user(User.search(params[:friend]))
      flash.now[:alert] = "Couldn't find user" if @friends.blank?
    else
      @friends = []
      flash.now[:alert] = "Please enter a friend name or email to search"
    end

    respond_to do |format|
      # This will render app/views/friends/friend_result.js.erb
      format.js { render 'friends/friend_result' }
      # optional HTML fallback if someone hits it non-AJAX
      format.html { redirect_to my_friends_path }
    end
  end

end