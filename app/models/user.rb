class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  before_create :check_for_invite_code

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable
  has_many :cases
  has_many :voice_messages
  has_many :hearings, through: :cases
  has_many :documents, through: :cases

  attr_accessor :invite_code

  def check_for_invite_code
    throw :abort
  end
end
