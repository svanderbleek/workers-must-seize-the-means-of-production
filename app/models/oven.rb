class Oven < ActiveRecord::Base
  belongs_to :user
  has_one :cookie, as: :storage

  validates :user, presence: true

  def bake!
    cookie.update(ready: true)
  end
end
