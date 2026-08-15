require 'rails_helper'

RSpec.describe Course, type: :model do
  describe "associations" do
    it { is_expected.to have_many(:tutors).dependent(:destroy) }
  end

  describe "validations" do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe "dependent destroy" do
    it "destroys associated tutors when the course is destroyed" do
      course = create(:course)
      tutor = create(:tutor, course: course)

      expect { course.destroy }.to change(Tutor, :count).by(-1)

      expect(Tutor.exists?(tutor.id)).to be(false)
    end
  end
end
