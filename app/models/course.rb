class Course < ApplicationRecord
  has_many :tutors, dependent: :destroy

  validates :title, presence: true
end
