class Role < ApplicationRecord
  before_save :set_slug
  has_many :agents

  private
  def set_slug
    self.slug = self.name.downcase.parameterize
  end
end
