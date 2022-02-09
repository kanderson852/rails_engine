require 'rails_helper'

describe "Merchants API" do
  it "sends a list of merchants" do
    list = create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants[:data].count).to eq(3)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:relationships)
      expect(merchant[:relationships]).to be_a(Hash)

      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)
    end
   end

   it "can get one merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(merchant[:data]).to have_key(:relationships)
    expect(merchant[:data][:relationships]).to be_a(Hash)

    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to be_a(Hash)
  end

end
