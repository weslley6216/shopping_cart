require 'rails_helper'

RSpec.describe 'Carts API', type: :request do
  let(:product) { create(:product, name: 'Camiseta', price: 10.0) }

  describe 'POST /carts' do
    it 'creates a new cart with a product' do
      post '/carts', params: { product_id: product.id, quantity: 2 }

      expect(response).to have_http_status(:created)
      expect(parsed_response).to eq(
        id: Cart.last.id,
        total_price: 20.0,
        products: [
          {
            id: product.id,
            name: 'Camiseta',
            quantity: 2,
            unit_price: 10.0,
            total_price: 20.0
          }
        ]
      )
    end
  end
end
