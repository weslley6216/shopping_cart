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

    it 'validates that price is greater than or equal to 0' do
      cart_item = build(:cart_item, price: -1)

      expect(cart_item).to_not be_valid
      expect(cart_item.errors[:price]).to include('must be greater than or equal to 0')
    end

    it 'is valid with a quantity greater than 0 and price greater than or equal to 0' do
      cart_item = build(:cart_item, quantity: 1, price: 10.0)

      expect(cart_item).to be_valid
    end
  end
end
