class CartItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :quantity, :unit_price, :total_items_price

  def id = object.product.id
  def name = object.product.name
  def unit_price = object.price.to_f
  def total_items_price = object.total_items_price
end
