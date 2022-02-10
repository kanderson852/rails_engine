class Api::V1::ItemsController < ApplicationController
  def index
    render json: ItemSerializer.new(Item.all)
  end

  def show
    render json: ItemSerializer.new(Item.find(params[:id]))
  end

  def create
    item = Item.new(item_params)
    if item.save
      render json: ItemSerializer.new(Item.create(item_params)), status: :created
    end
  end

  def update
    item = Item.find(params[:id])
    if item.update(item_params) && Merchant.find(params[:item][:merchant_id])
      render json: ItemSerializer.new(item)
    else
      render status: 404
    end
  end

  def destroy
    item = Item.find(params[:id])
    if item.destroy
      render status: :no_content
    end
  end

  def find
    if params[:name]
      item = Item.find_by_name
    elsif params[:max_price] && params[:min_price]
      item = Item.find_by_range
    elsif params[:max_price]
      item = Item.find_by_max
    elsif params[:min_price]
      item = Item.find_by_min
    end
    
    render json: ItemSerializer.new(item)
  end

private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
