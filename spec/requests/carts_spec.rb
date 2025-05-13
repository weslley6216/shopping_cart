require 'rails_helper'

RSpec.describe 'Carts API', type: :request do
  let(:product) { create(:product, name: 'Camiseta', price: 10.0) }

  describe 'POST /cart' do
    it 'creates a new cart with a product' do
      post '/cart', params: { product_id: product.id, quantity: 2 }

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

  describe 'GET /cart' do
    context 'when a cart exists in the session' do
      before { post '/cart', params: { product_id: product.id, quantity: 2 } }

      it 'returns the current cart with products' do
        get '/cart'

        expect(response).to have_http_status(:ok)
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

    context 'when there is no cart in the session' do
      it 'returns not found' do
        get '/cart'

        expect(response).to have_http_status(:not_found)
        expect(parsed_response).to eq({ error: 'Cart not found' })
      end
    end
  end
end
