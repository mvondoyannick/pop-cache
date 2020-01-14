class Agent < ApplicationRecord
  acts_as_token_authenticatable
  belongs_to :role
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  def complete_name
    self.name+' '+self.prenom
  end
end
