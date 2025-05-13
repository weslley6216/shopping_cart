class CartSerializer < ActiveModel::Serializer
  attributes :id, :products, :total_price

  def products = object.cart_items.map { |item| CartItemSerializer.new(item) }
  def total_price = object.total_price.to_f
end
