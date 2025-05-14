require 'rails_helper'

RSpec.describe CartItemSerializer, type: :serializer do
  let(:product) { create(:product, name: 'Camiseta', price: 29.99) }
  let(:cart) { create(:cart) }
  let(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2, price: product.price) }

  subject { described_class.new(cart_item) }

  let(:serialization) { ActiveModelSerializers::Adapter::Attributes.new(subject).as_json }

  it 'serializes the expected attributes' do
    expect(serialization).to eq(
      id: product.id,
      name: 'Camiseta',
      quantity: 2,
      unit_price: 29.99,
      total_items_price: 59.98
    )
  end
end
