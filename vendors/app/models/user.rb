class User < ActiveRecord::Base
  has_many :lookbooks, :dependent => :destroy
  belongs_to :lookbook
  acts_as_authentic
  #acts_as_authorization_subject  :association_name => :roles

  def deliver_password_reset_instructions!
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)
  end  

  def current_lookbook
    if lookbook.blank?
      lb = lookbooks.create!(:name => "Default")       
      self.update_attribute(:lookbook_id, lb.id)
      return lb
    else
      return lookbook
    end
  end
  
  def self.find_by_login_or_email(login)
    User.find_by_login(login) || User.find_by_email(login)
  end
end
