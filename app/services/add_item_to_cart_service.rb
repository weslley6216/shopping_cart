class AddItemToCartService < BaseCartService
  class InvalidQuantityError < StandardError; end

  attr_reader :quantity

  def initialize(cart, product_id, quantity)
    super(cart, product_id)
    @quantity = quantity.to_i
  end

  def call
    product = find_product(product_id)
    normalized_quantity = validate_quantity(quantity)
    cart_item = find_or_build_cart_item(cart, product, normalized_quantity)

    cart_item.save!
    update_cart_total_price!(cart)

    cart
  rescue ActiveRecord::RecordNotFound
    raise ProductNotFoundError
  end

  private

  def validate_quantity(quantity)
    raise InvalidQuantityError, 'Quantity must be greater than zero.' if quantity <= 0

    quantity
  end

  def find_or_build_cart_item(cart, product, quantity)
    cart_item = cart.cart_items.find_by(product_id: product.id)

    return cart.cart_items.build(product: product, quantity: quantity, price: product.price) unless cart_item

    cart_item.quantity += quantity
    cart_item
  end
end
