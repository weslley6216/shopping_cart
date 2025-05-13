class CartsController < ApplicationController
  def create
    product = Product.find(cart_params[:product_id])
    quantity = cart_params[:quantity].to_i

    cart = current_cart || Cart.new(total_price: 0)
    cart_item = cart.cart_items.find_by(product_id: product.id)

    if cart_item
      cart_item.quantity += quantity
      cart_item.save!
    else
      cart.cart_items.build(product: product, quantity: quantity, price: product.price)
      cart.save!
    end

    cart.update!(total_price: cart.cart_items.sum('quantity * price'))

    session[:cart_id] = cart.id
    render json: cart, serializer: CartSerializer, status: :created
  end

  def show
    cart = current_cart

    return render json: { error: 'Cart not found' }, status: :not_found if cart.blank?

    render json: cart, serializer: CartSerializer
  end

  def add_item
    cart = current_cart
    return render json: { error: 'Cart not found' }, status: :not_found unless cart

    product = Product.find(cart_params[:product_id])
    quantity = cart_params[:quantity].to_i

    item = cart.cart_items.find_by(product: product)

    if item
      item.quantity += quantity
    else
      item = cart.cart_items.build(product: product, quantity: quantity, price: product.price)
    end

    item.save!

    cart.update!(total_price: cart.cart_items.sum('quantity * price'))

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

  def current_cart = Cart.find_by(id: session[:cart_id])
  def cart_params = params.permit(:product_id, :quantity)
end
