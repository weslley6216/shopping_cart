class CartItemSerializer < ActiveModel::Serializer
  attributes :id, :name, :quantity, :unit_price, :total_price

  def name = object.product.name
  def unit_price = object.price.to_f
  def total_price = (object.price * object.quantity).to_f
end
