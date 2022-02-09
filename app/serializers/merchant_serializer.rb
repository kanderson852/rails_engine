class MerchantSerializer
  include JSONAPI::Serializer
  attributes :id, :name
  has_many :items
end
