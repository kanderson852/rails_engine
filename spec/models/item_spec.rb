require 'rails_helper'

RSpec.describe Item, type: :model do
  describe 'relationships' do
    it { should belong_to(:merchant) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:description) }
    it { should validate_presence_of(:unit_price) }
    it { should validate_presence_of(:merchant_id) }
  end

  describe 'factory object' do
    it 'should build a valid item object' do
      item = build(:item, name: 'fake name', description: 'describe', unit_price: 10, merchant_id: 1)

      expect(item).to be_a(Item)
      expect(item.name).to eq('fake name')
      expect(item.description).to eq('describe')
      expect(item.unit_price).to eq(10)
      expect(item.merchant_id).to eq(1)
    end
  end
end
