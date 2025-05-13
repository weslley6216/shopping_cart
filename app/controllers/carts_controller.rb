class CartsController < ApplicationController
  rescue_from BaseCartService::ProductNotFoundError, with: :render_product_not_found
  rescue_from AddItemToCartService::InvalidQuantityError, with: :render_invalid_quantity_error
  rescue_from RemoveItemFromCartService::ItemNotInCartError, with: :render_item_not_in_cart
  rescue_from ActionController::ParameterMissing, with: :render_parameter_missing

  before_action :set_current_cart, only: %i[create add_item remove_item]

  def create
    cart = AddItemToCartService.new(@current_cart, cart_params[:product_id], cart_params[:quantity]).call
    session[:cart_id] = cart.id

    render json: cart, serializer: CartSerializer, status: :created
  end

  def add_item
    cart = AddItemToCartService.new(@current_cart, cart_params[:product_id], cart_params[:quantity]).call

    render json: cart, serializer: CartSerializer, status: :ok
  end

  def show
    cart = current_cart
    return render json: { error: 'Cart not found' }, status: :not_found unless current_cart

    render json: cart, serializer: CartSerializer, status: :ok
  end

  def remove_item
    return render json: { error: 'Cart not found' }, status: :not_found unless @current_cart

    updated_cart = RemoveItemFromCartService.new(@current_cart, params[:product_id]).call
    return render json: { message: 'Cart is empty' }, status: :ok if updated_cart.empty?

    render json: updated_cart, serializer: CartSerializer, status: :ok
  end

  private

  def set_current_cart
    @current_cart = current_cart || Cart.new(total_price: 0)
  end

  def cart_params
    params.require(:product_id)
    params.require(:quantity)
    params.permit(:product_id, :quantity)
  end

  def current_cart = Cart.find_by(id: session[:cart_id])

  def render_product_not_found = render json: { error: 'Product not found' }, status: :not_found
  def render_invalid_quantity_error(error) = render json: { error: error.message }, status: :unprocessable_entity
  def render_item_not_in_cart = render json: { error: 'Product is not in the cart' }, status: :unprocessable_entity
  def render_parameter_missing(error) = render json: { error: error.message }, status: :bad_request
end
