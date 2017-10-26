class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable, :confirmable

  has_many :cases, dependent: :destroy
  has_many :voice_messages, dependent: :destroy
  has_many :hearings, through: :cases
  has_many :documents, through: :cases

  validate :email_whitelist, on: :create

  def email_whitelist
    errors.add(:email, "is not on whitelist") unless whitelist.include?(self.email)
  end

  def whitelist
    WhiteListedUser.all.map(&:email)
  end


end
