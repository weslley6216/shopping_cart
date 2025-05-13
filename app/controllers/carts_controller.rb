class CartsController < ApplicationController
  rescue_from AddItemToCartService::ProductNotFoundError, with: :render_product_not_found
  rescue_from AddItemToCartService::InvalidQuantityError, with: :render_invalid_quantity_error

  before_action :set_current_cart, only: %i[create add_item remove_item]

  def create
    cart = AddItemToCartService.new(@current_cart, params[:product_id], params[:quantity]).call
    session[:cart_id] = cart.id

    render json: cart, serializer: CartSerializer, status: :created
  end

  def add_item
    cart = AddItemToCartService.new(@current_cart, params[:product_id], params[:quantity]).call

    render json: cart, serializer: CartSerializer, status: :ok
  end

  def show
    cart = current_cart
    return render json: { error: 'Cart not found' }, status: :not_found unless current_cart

    render json: cart, serializer: CartSerializer, status: :ok
  end

  def remove_item
    cart = current_cart
    return render json: { error: 'Cart not found' }, status: :not_found unless cart

    product = Product.find_by(id: params[:product_id])
    return render json: { error: 'Product not found' }, status: :not_found unless product

    item = cart.cart_items.find_by(product_id: product.id)
    return render json: { error: 'Product is not in the cart' }, status: :unprocessable_entity unless item

    if item.quantity > 1
      item.update!(quantity: item.quantity - 1)
    else
      item.destroy!
    end

    cart.update!(total_price: cart.cart_items.sum('quantity * price'))

    if cart.cart_items.empty?
      render json: { message: 'Cart is empty' }, status: :ok
    else
      render json: cart, serializer: CartSerializer, status: :ok
    end
  end

  private

  def set_current_cart
    @current_cart = current_cart || Cart.new(total_price: 0)
  end

  def current_cart = Cart.find_by(id: session[:cart_id])
  def cart_params = params.permit(:product_id, :quantity)

  def render_product_not_found = render json: { error: 'Product not found' }, status: :not_found
  def render_invalid_quantity_error(error) = render json: { error: error.message }, status: :unprocessable_entity
end
