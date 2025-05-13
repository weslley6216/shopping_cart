class BaseCartService
  class ProductNotFoundError < StandardError; end

  attr_reader :cart, :product_id

  def initialize(cart, product_id)
    @cart = cart
    @product_id = product_id
  end

  private

  def find_product(product_id) = Product.find(product_id)
  def update_cart_total_price!(cart) = cart.update!(total_price: calculate_total_price(cart))
  def calculate_total_price(cart) = cart.cart_items.sum('quantity * price')
end
