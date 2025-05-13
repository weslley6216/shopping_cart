class CartsController < ApplicationController
  def create
    product = Product.find(cart_params[:product_id])
    quantity = cart_params[:quantity].to_i

    cart = current_cart || Cart.new(total_price: 0)
    cart.total_price += product.price * quantity
    cart.cart_items.build(product: product, quantity: quantity, price: product.price)

    return render json: { errors: cart.errors.full_messages }, status: :unprocessable_entity unless cart.save

    session[:cart_id] = cart.id
    render json: cart, serializer: CartSerializer, status: :created
  end

  def show
    cart = current_cart

    return render json: { error: 'Cart not found' }, status: :not_found if cart.blank?

    render json: cart, serializer: CartSerializer
  end

  private

  def current_cart = Cart.find_by(id: session[:cart_id])
  def cart_params = params.permit(:product_id, :quantity)
end
