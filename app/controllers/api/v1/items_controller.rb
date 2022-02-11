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
    item.update(item_params)
    if item.save
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
      if params[:max_price] || params[:min_price]
        item = '400'
      elsif params[:name] == ''
        item = '400'
      else
        item = Item.where("name ILIKE ?", "%#{params[:name]}%")
              .order(name: :asc)
              .first
      end
    elsif params[:max_price] && params[:min_price]
      if params[:max_price] < params[:min_price]
        item = '400'
      else
        item = Item.where("unit_price >= ?", params[:min_price])
            .where("unit_price <= ?", params[:max_price])
            .order(name: :asc)
            .first
      end
    elsif params[:max_price]
      if params[:max_price].to_i > 0
        item = Item.where("unit_price <= ?", params[:max_price])
            .order(name: :asc)
            .first
      else
        item = '400'
      end
    elsif params[:min_price]
      if params[:min_price].to_i > 0
        item = Item.where("unit_price >= ?", params[:min_price].to_f)
            .order(name: :asc)
            .first
      else
        item = '400'
      end
    else
      item = '400'
    end
    if item == nil
      render json: { data: { message: 'Error: not found'}}
    elsif item == '400'
      render status: 400
    else
      render json: ItemSerializer.new(item)
    end
  end

private

  def item_params
    params.require(:item).permit(:name, :description, :unit_price, :merchant_id)
  end
end
