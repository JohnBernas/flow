class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable
  #
  # We removed:
  # :registerable, :recoverable
  devise :database_authenticatable, :rememberable, :trackable, :validatable
end
