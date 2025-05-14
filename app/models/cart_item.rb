class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  validates :quantity, numericality: { greater_than: 0 }

  def total_items_price = quantity * product.price
end
