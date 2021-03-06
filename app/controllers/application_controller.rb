class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  helper_method :current_user, :signed_in?

  def sign_in!(user)
    @current_user = user
    session[:token] = user.reset_session_token!
  end

  def current_user
    @current_user ||= User.find_by(session_token: session[:token])
  end

  def signed_in?
    !!current_user
  end

  def sign_out!
    current_user.reset_session_token!
    session[:token] = nil
  end

  def require_signed_in!
    redirect_to new_session_url unless signed_in?
  end
  
  def send_text(receiver, body)
    client = Twilio::REST::Client.new ENV["TWILIO_SID"], ENV["TWILIO_TOKEN"]

    client.account.messages.create(
      :from => ENV["TWILIO_NUMBER"],
      :to => receiver,
      :body => body
    )
  end
end
