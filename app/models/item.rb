class Item < ApplicationRecord
  belongs_to :merchant

  validates :name, :description, :unit_price, :merchant_id, presence: true

  # def self.find_by_name
  #   Item.where("name ILIKE ?", "%#{params[:name]}%")
  #       .order(name: :asc)
  #       .first
  # end
  #
  # def self.find_by_max
  #   Item.where("unit_price >= ?", "%#{params[:unit_price]}%")
  #       .order(name: :asc)
  #       .first
  # end
  #
  # def self.find_by_min
  #   Item.where("unit_price <= ?", "%#{params[:unit_price]}%")
  #       .order(name: :asc)
  #       .first
  # end
  #
  # def self.find_by_range
  # end
end
