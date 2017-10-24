class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  has_many :cases
  has_many :voice_messages
  has_many :hearings, through: :cases
  has_many :documents, through: :cases

  validate :email_whitelist, on: :create

  def email_whitelist
    errors.add(:email, "is not on whitelist") unless whitelist.include?(self.email)
  end

  def whitelist
    ["coopermayne@gmail.com", "coopcoop@gmail.com"]
  end


end
