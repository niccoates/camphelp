class CampsiteUser < ApplicationRecord
  belongs_to :campsite
  belongs_to :user

  validates :campsite_id, uniqueness: { scope: :user_id }
end
