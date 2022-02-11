require 'rails_helper'

describe "Items API" do
  it "sends a list of items" do
    merchant = create(:merchant)
    list = create_list(:item, 3, merchant_id: merchant.id)
    get '/api/v1/items'

    items = JSON.parse(response.body, symbolize_names: true)
    expect(response).to be_successful

    expect(items[:data].count).to eq(3)

    items[:data].each do |item|
      expect(item).to have_key(:id)
      expect(item[:id]).to be_a(String)

      expect(item[:attributes]).to have_key(:name)
      expect(item[:attributes][:name]).to be_a(String)
    end
   end

   it "can get one item by its id" do
    merchant = create(:merchant)
    id = create(:item, merchant_id: merchant.id).id

    get "/api/v1/items/#{id}"

    item = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful

    expect(item[:data]).to have_key(:type)
    expect(item[:data][:type]).to eq("item")

    expect(item[:data]).to have_key(:attributes)
    expect(item[:data][:attributes]).to be_a(Hash)
  end

  it "can create a new item" do
    merchant = create(:merchant)
    item_params = ({
                    name: 'abc',
                    description: 'xyz',
                    unit_price: 2,
                    merchant_id: merchant.id
                  })
    headers = {"CONTENT_TYPE" => "application/json"}
    post "/api/v1/items", headers: headers, params: JSON.generate(item: item_params)
    created_item = Item.last

    expect(response).to be_successful
    expect(created_item.name).to eq(item_params[:name])
    expect(created_item.description).to eq(item_params[:description])
    expect(created_item.unit_price).to eq(item_params[:unit_price])
    expect(created_item.merchant_id).to eq(item_params[:merchant_id])
  end

  it "can destroy an item" do
    merchant = create(:merchant)
    item = create(:item, merchant_id: merchant.id)

    expect(Item.count).to eq(1)

    delete "/api/v1/items/#{item.id}"

    expect(response).to be_successful
    expect(Item.count).to eq(0)
    expect{Item.find(item.id)}.to raise_error(ActiveRecord::RecordNotFound)
  end

  it "can update an existing item" do
    merchant = create(:merchant)
    id = create(:item, merchant_id: merchant.id).id
    previous_name = Item.last.name
    item_params = { name: "abc", merchant_id: "#{merchant.id}" }
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
    item = Item.find_by(id: id)

    expect(response).to be_successful
    expect(item.name).to_not eq(previous_name)
    expect(item.name).to eq("abc")
  end

  it "returns an error if invalid params given" do
    merchant = create(:merchant)
    id = create(:item, merchant_id: merchant.id).id
    previous_name = Item.last.name
    item_params = { name: nil }
    headers = {"CONTENT_TYPE" => "application/json"}

    patch "/api/v1/items/#{id}", headers: headers, params: JSON.generate({item: item_params})
    expect(response).to have_http_status(404)
  end

  it 'can find an items merchant' do
    merchant1 = create(:merchant)
    item = create(:item, merchant_id: merchant1.id)
    get "/api/v1/items/#{item.id}/merchant"

    merchant = JSON.parse(response.body, symbolize_names: true)

    expect(response).to be_successful
    expect(merchant[:data]).to be_a(Hash)
    expect(merchant[:data]).to have_key(:id)
    expect(merchant[:data][:id]).to eq("#{merchant1.id}")
  end

  it 'can search for an item' do
    merchant = create(:merchant)
    item = Item.create!(name: 'ring', description: 'abc', unit_price: 10, merchant_id: merchant.id)
    get '/api/v1/items/find?name=ring'

    expected = {
      "data": {
        "id": "#{item.id}",
        "type": "item",
        "attributes": {
          "name": "ring",
          "description": "abc",
          "unit_price": 10.0,
          "merchant_id": merchant.id
        }
      }
    }.to_json
    expect(response).to be_successful
    expect(response.body).to eq(expected)
  end

  it 'finds first item that contains case insensitive name search' do
    merchant = create(:merchant)
    item = create(:item, name: "turing", merchant: merchant)
    item2 = create(:item, name: "Ring", merchant: merchant)
    get '/api/v1/items/find?name=rin'

    item_name = JSON(response.body)["data"]["attributes"]["name"]
    expect(response).to be_successful
    expect(item_name).to eq("Ring")
  end

  it 'finds item above a minimum price' do
    merchant = create(:merchant)
    item = create(:item, unit_price: 55, merchant: merchant)
    item2 = create(:item, unit_price: 22, merchant: merchant)
    get '/api/v1/items/find?min_price=50'

    item_price = JSON(response.body)["data"]["attributes"]["unit_price"]
    expect(response).to be_successful
    expect(item_price).to eq(55)
  end

  it 'finds item below a maximum price' do
    merchant = create(:merchant)
    item = create(:item, unit_price: 55, merchant: merchant)
    item2 = create(:item, unit_price: 220, merchant: merchant)
    get '/api/v1/items/find?max_price=150'

    item_price = JSON(response.body)["data"]["attributes"]["unit_price"]
    expect(response).to be_successful
    expect(item_price).to eq(55)
  end

  it 'finds item above a minimum price' do
    merchant = create(:merchant)
    item = create(:item, unit_price: 55, merchant: merchant)
    item2 = create(:item, unit_price: 22, merchant: merchant)
    get '/api/v1/items/find?min_price=50&max_price=70'

    item_price = JSON(response.body)["data"]["attributes"]["unit_price"]
    expect(response).to be_successful
    expect(item_price).to eq(55)
  end

  it 'cannot have an empty search field' do
    merchant = create(:merchant)
    item = create(:item, unit_price: 55, merchant: merchant)
    item2 = create(:item, unit_price: 220, merchant: merchant)
    get '/api/v1/items/find'

    expect(response).to have_http_status(400)
  end

  it 'parameter cannot be empty' do
    merchant = create(:merchant)
    item = create(:item, unit_price: 55, merchant: merchant)
    item2 = create(:item, unit_price: 220, merchant: merchant)
    get '/api/v1/items/find?name='

    expect(response).to have_http_status(400)
  end

  it 'cannot send both name and min_price' do
    merchant = create(:merchant)
    item = create(:item, unit_price: 55, merchant: merchant)
    item2 = create(:item, unit_price: 220, merchant: merchant)
    get '/api/v1/items/find?name=ring&min_price=50'

    expect(response).to have_http_status(400)
  end

  it 'cannot send both name and max_price' do
    merchant = create(:merchant)
    item = create(:item, unit_price: 55, merchant: merchant)
    item2 = create(:item, unit_price: 220, merchant: merchant)
    get '/api/v1/items/find?name=ring&max_price=50'

    expect(response).to have_http_status(400)
  end

  it 'cannot send both name and min_price and max_price' do
    merchant = create(:merchant)
    item = create(:item, unit_price: 55, merchant: merchant)
    item2 = create(:item, unit_price: 220, merchant: merchant)
    get '/api/v1/items/find?name=ring&min_price=50&max_price=250'

    expect(response).to have_http_status(400)
  end

  it 'returns an error if no matches found' do
    merchant = create(:merchant)
    item = create(:item, name: 'abc', merchant: merchant)

    get '/api/v1/items/find?name=xyz'

    expect(response.body).to be_a(String)
  end

  it 'cannot have min_price greater than max_price' do
    merchant = create(:merchant)
    item = create(:item, unit_price: 550, merchant: merchant)
    item2 = create(:item, unit_price: 220, merchant: merchant)
    get '/api/v1/items/find?min_price=500&max_price=250'

    expect(response).to have_http_status(400)
  end

  it 'cannot have a max_price too low' do
    merchant = create(:merchant)
    item = create(:item, unit_price: 55, merchant: merchant)
    item2 = create(:item, unit_price: 220, merchant: merchant)
    get '/api/v1/items/find?max_price=0'

    expect(response).to have_http_status(400)
  end

  it 'cannot have a min_price too low' do
    merchant = create(:merchant)
    item = create(:item, unit_price: 55, merchant: merchant)
    item2 = create(:item, unit_price: 220, merchant: merchant)
    get '/api/v1/items/find?min_price=0'

    expect(response).to have_http_status(400)
  end
end
