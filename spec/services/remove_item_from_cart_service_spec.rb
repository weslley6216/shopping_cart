require 'rails_helper'

RSpec.describe RemoveItemFromCartService do
  describe '#call' do
    let(:product) { create(:product, price: 10) }
    let(:cart) { create(:cart) }

    context 'when the item is in the cart with quantity greater than 1' do
      let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 3) }

      it 'decreases the item quantity by 1 and updates last_interaction_at' do
        expect {
          described_class.new(cart, product.id).call
        }.to change(cart.reload, :last_interaction_at)

        expect(cart_item.reload.quantity).to eq(2)
      end

      it 'does not remove the item from the cart' do
        expect {
          described_class.new(cart, product.id).call
        }.not_to change(CartItem, :count)
      end

      it 'updates the total price of the cart' do
        described_class.new(cart, product.id).call

        expect(cart.reload.total_price).to eq(20)
      end
    end

    context 'when the item is in the cart with quantity equal to 1 and updates last_interaction_at' do
      before { create(:cart_item, cart: cart, product: product, quantity: 1) }

      it 'removes the item from the cart' do
        expect {
          described_class.new(cart, product.id).call
        }.to change(cart.reload, :last_interaction_at).and change(CartItem, :count).by(-1)
      end

      it 'sets the cart total price to 0' do
        described_class.new(cart, product.id).call

        expect(cart.reload.total_price).to eq(0)
      end
    end

    context 'when the product does not exist' do
      it 'raises ProductNotFoundError' do
        expect {
          described_class.new(cart, 999).call
        }.to raise_error(RemoveItemFromCartService::ProductNotFoundError)

        expect { cart.reload.last_interaction_at }.to_not change(cart, :last_interaction_at)
      end
    end

    context 'when the item is not in the cart' do
      let(:another_product) { create(:product) }

      it 'raises ItemNotInCartError' do
        expect {
          described_class.new(cart, another_product.id).call
        }.to raise_error(RemoveItemFromCartService::ItemNotInCartError)

        expect { cart.reload.last_interaction_at }.to_not change(cart, :last_interaction_at)
      end
    end
  end
end
