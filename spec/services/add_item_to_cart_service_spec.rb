require 'rails_helper'

RSpec.describe AddItemToCartService do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, price: 10.0) }

  describe '#call' do
    context 'when the product exists' do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

      it 'increments quantity and updates last_interaction_at' do
        expect {
          described_class.new(cart, product.id, 3).call
        }.to change(cart.reload, :last_interaction_at)

        expect(cart.cart_items.size).to eq(1)
        expect(cart_item.reload.quantity).to eq(4)
        expect(cart.reload.total_price).to eq(40.0)
      end

      it 'updates total price' do
        described_class.new(cart, product.id, 2).call

        expect(cart_item.reload.quantity).to eq(3)
        expect(cart.reload.total_price).to eq(30.0)
      end
    end

    context 'when adding a new product' do
      let(:new_product) { create(:product, price: 20.0) }

      it 'adds item and updates last_interaction_at' do
        expect {
          described_class.new(cart, new_product.id, 2).call
        }.to change(cart.cart_items, :count).by(1).and change(cart.reload, :last_interaction_at)

        expect(cart.reload.total_price).to eq(40.0)
        expect(cart.cart_items.last.product).to eq(new_product)
        expect(cart.cart_items.last.quantity).to eq(2)
      end
    end

    context 'when the product does not exist' do
      it 'raises ProductNotFoundError and does not update last_interaction_at' do
        expect {
          described_class.new(cart, 999, 1).call
        }.to raise_error(AddItemToCartService::ProductNotFoundError)

        expect { cart.reload.last_interaction_at }.to_not change(cart, :last_interaction_at)
      end
    end

    context 'when the quantity is invalid' do
      it 'raises InvalidQuantityError for zero quantity' do
        expect {
          described_class.new(cart, product.id, 0).call
        }.to raise_error(AddItemToCartService::InvalidQuantityError, 'Quantity must be greater than zero.')

        expect { cart.reload.last_interaction_at }.to_not change(cart, :last_interaction_at)
      end

      it 'raises InvalidQuantityError for negative quantity' do
        expect {
          described_class.new(cart, product.id, -1).call
        }.to raise_error(AddItemToCartService::InvalidQuantityError, 'Quantity must be greater than zero.')

        expect { cart.reload.last_interaction_at }.to_not change(cart, :last_interaction_at)
      end
    end

    context 'when adding to an abandoned cart' do
      let(:new_product) { create(:product, price: 25.0) }
      let(:abandoned_cart) { create(:cart, abandoned: true) }

      it 'reactivates cart' do
        expect {
          described_class.new(abandoned_cart, new_product.id, 1).call
        }.to change { abandoned_cart.reload.abandoned? }.from(true).to(false)
      end
    end
  end
end
