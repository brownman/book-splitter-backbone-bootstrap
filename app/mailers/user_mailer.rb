class UserMailer < ActionMailer::Base
  default :from => "notifications@example.com"

def user_added
mail(:to => "brownman556@gmail.com", :subject => "New friend added")
end

  def welcome_email(user)
    @user = user
    @url  = "http://example.com/login"
    mail(:to => user.email, :subject => "Welcome to My Awesome Site")
  end
end
