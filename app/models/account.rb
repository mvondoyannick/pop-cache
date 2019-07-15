class Account < ApplicationRecord
  belongs_to :customer


  #validation
  #validates_presence_of :name, presence: true
end
