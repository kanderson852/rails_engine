class Api::V1::MerchantsController < ApplicationController
  def index
    render json: MerchantSerializer.new(Merchant.all)
  end

  def show
    if params[:id].to_i <= Merchant.last.id
      render json: MerchantSerializer.new(Merchant.find(params[:id]))
    else
      render status: 404
    end
  end
end
