class Api::V1::MerchantItemsController < ApplicationController
  def index
    if params[:merchant_id].to_i <= Merchant.last.id
      render json: ItemSerializer.new(Item.where(merchant_id: params[:merchant_id]))
    else
      render status: 404
    end
  end
end
