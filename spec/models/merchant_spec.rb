require 'rails_helper'

RSpec.describe Merchant, type: :model do
  describe 'relationships' do
    it { should have_many(:items) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
  end

  describe 'factory object' do
    it 'should build a valid merchant object' do
      merchant = build(:merchant, name: 'fake name')

      expect(merchant).to be_a(Merchant)
      expect(merchant.name).to eq('fake name')
    end
  end 
end
