require 'rails_helper'

RSpec.describe CartSerializer, type: :serializer do
  let(:product1) { create(:product, name: 'Camiseta', price: 29.99) }
  let(:product2) { create(:product, name: 'Boné', price: 19.99) }
  let(:cart) { create(:cart) }

  subject { described_class.new(cart) }

  let(:serialization) { ActiveModelSerializers::Adapter::Attributes.new(subject).as_json }

  before do
    create(:cart_item, cart: cart, product: product1, quantity: 2)
    create(:cart_item, cart: cart, product: product2, quantity: 3)
    cart.update!(total_price: cart.calculate_total_price)
  end

  it 'serializes the expected attributes' do
    expect(serialization).to eq(
      id: cart.id,
      total_price: 119.95,
      products: [
        {
          id: product1.id,
          name: 'Camiseta',
          quantity: 2,
          unit_price: 29.99,
          total_items_price: 59.98
        },
        {
          id: product2.id,
          name: 'Boné',
          quantity: 3,
          unit_price: 19.99,
          total_items_price: 59.97
        }
      ]
    )
  end
end
