require 'rails_helper'

RSpec.describe Tutor, type: :model do
  describe "associations" do
    it { is_expected.to belong_to(:course) }
  end

  describe "validations" do
    subject { build(:tutor) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email) }
  end
end
