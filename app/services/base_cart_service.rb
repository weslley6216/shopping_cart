class BaseCartService
  class ProductNotFoundError < StandardError; end

  attr_reader :cart, :product_id

  def initialize(cart, product_id)
    @cart = cart
    @product_id = product_id
  end

  private

  def find_product(product_id) = Product.find(product_id)
  def update_cart_total_price!(cart) = cart.update!(total_price: cart.calculate_total_price)
  def update_last_interaction! = cart.update!(last_interaction_at: Time.current)
end
