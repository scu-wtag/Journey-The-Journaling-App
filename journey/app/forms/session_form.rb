class SessionForm
  include ActiveModel::Model

  attr_accessor :email, :password

  validates :email, :password, presence: true

  def authenticate
    return nil unless valid?

    user = User.find_by(email: email)
    authenticated = if user.respond_to?(:authenticate)
           user.authenticate(password)
         elsif user.respond_to?(:authenticated?)
           user.authenticated?(password) && user
         end
    errors.add(:base, I18n.t('sessions.errors.wrong_email_or_password')) unless authenticated
    authenticated
  end
end
