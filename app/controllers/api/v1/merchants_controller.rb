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

  def find_all
    if params[:name]
      if params[:name] == ''
        merchants = '400'
      else
        merchants = Merchant.where("name ILIKE ?", "%#{params[:name]}%")
      end
    else
      merchants = '400'
    end
    if merchants == []
      render json: { data: []}
    elsif merchants == '400'
      render status: 400
    else
      render json: MerchantSerializer.new(merchants)
    end
  end
end
