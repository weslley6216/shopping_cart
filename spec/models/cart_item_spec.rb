require 'rails_helper'

RSpec.describe CartItem, type: :model do
  context 'associations' do
    it 'belongs to a cart' do
      cart_item = build(:cart_item)

      expect(cart_item.cart).to be_a(Cart)
    end

    it 'belongs to a product' do
      cart_item = build(:cart_item)

      expect(cart_item.product).to be_a(Product)
    end
  end

  context 'validations' do
    it 'validates that quantity is greater than 0' do
      cart_item = build(:cart_item, quantity: -1)

      expect(cart_item).to_not be_valid
      expect(cart_item.errors[:quantity]).to include('must be greater than 0')
    end

    it 'is valid with a quantity greater than 0' do
      cart_item = build(:cart_item, quantity: 1)

      expect(cart_item).to be_valid
    end
  end
end
