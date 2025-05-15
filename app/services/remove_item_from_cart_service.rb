class RemoveItemFromCartService < BaseCartService
  class ItemNotInCartError < StandardError; end

  def call
    product = find_product(product_id)
    cart_item = find_cart_item(cart, product)

    reduce_or_destroy_item!(cart_item)
    update_cart_total_price!(cart)
    update_last_interaction!

    cart
  rescue ActiveRecord::RecordNotFound
    raise ProductNotFoundError
  end

  private

  def reduce_or_destroy_item!(cart_item)
    return cart_item.update!(quantity: cart_item.quantity - 1) if cart_item.quantity > 1

    cart_item.destroy!
  end

  def find_cart_item(cart, product)
    cart.cart_items.find_by(product_id: product.id) || raise(ItemNotInCartError)
  end
end
