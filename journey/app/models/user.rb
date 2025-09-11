class User < ApplicationRecord
  include Clearance::User

  has_one :profile, dependent: :destroy
  
  accepts_nested_attributes_for :profile

  enum :role, { guest: 0, member: 1, admin: 2 }, default: :member
  
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :name, presence: true 
  
  before_save :downcase_email
  
  private
 

  def downcase_email
    self.email = email.downcase if email.present?
  end
end
