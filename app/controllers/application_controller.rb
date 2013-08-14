class ApplicationController < ActionController::Base
  class Action < ApplicationController
    include FocusedController::Mixin

    before_filter :authenticate_user!
  end

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
end
