class ApplicationController < ActionController::Base

  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

  private
    def record_not_found(exception)
        redirect_to root_url
    end

end
