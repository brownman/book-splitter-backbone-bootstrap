ActionMailer::Base.smtp_settings = {
  :address        => 'smtp.sendgrid.net',
  :port           => '587',
  :authentication => :plain,
  :user_name      => ENV['SENDGRID_USERNAME'],
  :password       => ENV['SENDGRID_PASSWORD'],
  :domain         => "mariana82.herokuapp.com",
  :address => "smtp.sendgrid.net",
  :enable_starttls_auto => true
}
ActionMailer::Base.delivery_method = :smtp

