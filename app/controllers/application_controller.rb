class ApplicationController < ActionController::Base
    before :authenticate_user!
    
end
