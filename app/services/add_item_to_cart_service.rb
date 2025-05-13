class AddItemToCartService
  class ProductNotFoundError < StandardError; end
  class InvalidQuantityError < StandardError; end

  attr_reader :cart, :product_id, :quantity

  def initialize(cart, product_id, quantity)
    @cart = cart
    @product_id = product_id
    @quantity = quantity.to_i
  end

  def call
    product = find_product(product_id)
    normalized_quantity = validate_quantity(quantity)
    cart_item = find_or_build_cart_item(cart, product, normalized_quantity)

    save_cart_item!(cart_item)
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

  def find_product(product_id) = Product.find(product_id)
  def save_cart_item!(cart_item) = cart_item.save!
  def update_cart_total_price!(cart) = cart.update!(total_price: calculate_total_price(cart))
  def calculate_total_price(cart) = cart.cart_items.sum('quantity * price')
end
