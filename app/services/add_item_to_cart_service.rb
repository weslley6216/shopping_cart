class AddItemToCartService < BaseCartService
  class InvalidQuantityError < StandardError; end

  attr_reader :quantity

  def initialize(cart, product_id, quantity)
    super(cart, product_id)
    @quantity = quantity.to_i
  end

  def call
    product = find_product(product_id)
    raise InvalidQuantityError, 'Quantity must be greater than zero.' if quantity <= 0

    cart_item = find_or_build_cart_item(cart, product, quantity)

    cart_item.save!
    update_cart_total_price!(cart)
    update_last_interaction!
    cart.reactivate_if_abandoned!

    cart
  rescue ActiveRecord::RecordNotFound
    raise ProductNotFoundError
  end

  private

  def find_or_build_cart_item(cart, product, quantity)
    cart_item = cart.cart_items.find_by(product_id: product.id)

    return cart.cart_items.build(product: product, quantity: quantity) unless cart_item

    cart_item.quantity += quantity
    cart_item
  end
end
