# spec/services/add_item_to_cart_service_spec.rb
require 'rails_helper'

RSpec.describe AddItemToCartService do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, price: 10.0) }

  describe '#call' do
    context 'when the product exists' do
      it 'adds a new item to the cart if it does not exist' do
        expect {
          described_class.new(cart, product.id, 2).call
        }.to change(cart.cart_items, :count).by(1)

        cart_item = cart.cart_items.first

        expect(cart_item.product).to eq(product)
        expect(cart_item.quantity).to eq(2)
        expect(cart_item.price).to eq(10.0)
        expect(cart.total_price).to eq(20.0)
      end

      it 'increments the quantity of an existing item in the cart' do
        create(:cart_item, cart: cart, product: product, quantity: 1, price: 10.0)

        expect {
          described_class.new(cart, product.id, 3).call
        }.to_not change(cart.cart_items, :count)

        cart_item = cart.cart_items.first

        expect(cart_item.quantity).to eq(4)
        expect(cart.total_price).to eq(40.0)
      end

      it 'updates total price when item already exists' do
        create(:cart_item, cart: cart, product: product, quantity: 1, price: 10.0)

        described_class.new(cart, product.id, 2).call

        expect(cart.reload.total_price).to eq(30.0)
      end
    end

    context 'when the product does not exist' do
      it 'raises ProductNotFoundError' do
        expect {
          described_class.new(cart, 999, 1).call
        }.to raise_error(AddItemToCartService::ProductNotFoundError)
      end
    end

    context 'when the quantity is zero or negative' do
      it 'raises InvalidQuantityError for zero quantity' do
        expect {
          described_class.new(cart, product.id, 0).call
        }.to raise_error(AddItemToCartService::InvalidQuantityError, 'Quantity must be greater than zero.')
      end

      it 'raises InvalidQuantityError for negative quantity' do
        expect {
          described_class.new(cart, product.id, -1).call
        }.to raise_error(AddItemToCartService::InvalidQuantityError, 'Quantity must be greater than zero.')
      end
    end
  end
end
