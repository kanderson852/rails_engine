require 'rails_helper'

describe "Merchants API" do
  it "sends a list of merchants" do
    list = create_list(:merchant, 3)

    get '/api/v1/merchants'

    expect(response).to be_successful

    merchants = JSON.parse(response.body, symbolize_names: true)

    expect(merchants[:data].count).to eq(3)

    merchants[:data].each do |merchant|
      expect(merchant).to have_key(:attributes)
      expect(merchant[:attributes]).to be_a(Hash)
      expect(merchant[:attributes]).to have_key(:name)
      expect(merchant[:attributes][:name]).to be_a(String)
    end
   end

   it "can get one merchant by its id" do
    id = create(:merchant).id

    get "/api/v1/merchants/#{id}"

    merchant = JSON.parse(response.body, symbolize_names: true)
    expect(response).to be_successful

    expect(merchant[:data]).to have_key(:attributes)
    expect(merchant[:data][:attributes]).to be_a(Hash)
    expect(merchant[:data][:attributes]).to have_key(:name)
    expect(merchant[:data][:attributes][:name]).to be_a(String)
  end

  it "can get one merchants items" do
    merchant = create(:merchant)
    list = create_list(:item, 3, merchant_id: merchant.id)
    get "/api/v1/merchants/#{merchant.id}/items"

    merchant = JSON.parse(response.body, symbolize_names: true)
    expect(response).to be_successful

    expect(merchant[:data]).to be_a(Array)
    expect(merchant[:data].first).to be_a(Hash)
    expect(merchant[:data].first).to have_key(:attributes)
  end

  it 'can search for all merchants' do
    merchant = create(:merchant, name: "Ring World")
    merchant1 = create(:merchant, name: "Turing School")
    get '/api/v1/merchants/find_all?name=ring'

    expected = {
      "data": [
        {
          "id": "#{merchant.id}",
          "type": "merchant",
          "attributes": {
            "name": "Ring World"
          }
        },
        {
          "id": "#{merchant1.id}",
          "type": "merchant",
          "attributes": {
            "name": "Turing School"
          }
        }
      ]
    }.to_json
    expect(response).to be_successful
    expect(response.body).to eq(expected)
  end

end
