require 'rails_helper'

RSpec.describe 'Carts API', type: :request do
  let(:product) { create(:product, name: 'Camiseta', price: 10.0) }

  describe 'POST /cart' do
    context 'when the request is valid' do
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
              total_items_price: 20.0
            }
          ]
        )
      end

      it 'stores cart_id in the session' do
        post '/cart', params: { product_id: product.id, quantity: 2 }

        expect(session[:cart_id]).to eq(Cart.last.id)
      end
    end

    context 'when the product already exists in the cart' do
      it 'does not create a new cart but updates the quantity' do
        post '/cart', params: { product_id: product.id, quantity: 2 }
        post '/cart', params: { product_id: product.id, quantity: 1 }

        expect(response).to have_http_status(:created)
        expect(parsed_response[:products].first[:quantity]).to eq(3)
      end
    end

    context 'when adding different products to the cart' do
      let(:product2) { create(:product, name: 'Boné', price: 15.0) }

      it 'calculates the total price correctly' do
        post '/cart', params: { product_id: product.id, quantity: 2 }
        post '/cart', params: { product_id: product2.id, quantity: 1 }

        expect(response).to have_http_status(:created)
        expect(parsed_response[:total_price]).to eq(35.0)
      end
    end

    context 'when the product does not exist' do
      it 'returns 404' do
        post '/cart', params: { product_id: 999, quantity: 2 }

        expect(response).to have_http_status(:not_found)
        expect(parsed_response[:error]).to eq('Product not found')
      end
    end

    context 'when the quantity is invalid' do
      it 'returns 422' do
        post '/cart', params: { product_id: product.id, quantity: 0 }

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_response[:error]).to eq('Quantity must be greater than zero.')
      end
    end

    context 'when required params are missing' do
      it 'returns 400 if product_id is missing' do
        post '/cart', params: { quantity: 2 }

        expect(response).to have_http_status(:bad_request)
        expect(parsed_response[:error]).to eq('param is missing or the value is empty: product_id')
      end

      it 'returns 400 if quantity is missing' do
        post '/cart', params: { product_id: product.id }

        expect(response).to have_http_status(:bad_request)
        expect(parsed_response[:error]).to eq('param is missing or the value is empty: quantity')
      end
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
              total_items_price: 20.0
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

  describe 'POST /cart/add_item' do
    before do
      post '/cart', params: { product_id: product.id, quantity: 1 }
    end

    context 'when adding the same product again' do
      it 'increments the quantity and updates total price' do
        post '/cart/add_item', params: { product_id: product.id, quantity: 2 }

        expect(response).to have_http_status(:ok)
        expect(parsed_response).to eq(
          id: Cart.last.id,
          total_price: 30.0,
          products: [
            {
              id: product.id,
              name: 'Camiseta',
              quantity: 3,
              unit_price: 10.0,
              total_items_price: 30.0
            }
          ]
        )
      end
    end

    context 'when adding a new product' do
      let(:other_product) { create(:product, name: 'Boné', price: 15.0) }

      it 'adds a new item to the cart' do
        post '/cart/add_item', params: { product_id: other_product.id, quantity: 1 }

        expect(response).to have_http_status(:ok)
        expect(parsed_response).to eq(
          id: Cart.last.id,
          total_price: 25.0,
          products: [
            {
              id: product.id,
              name: 'Camiseta',
              quantity: 1,
              unit_price: 10.0,
              total_items_price: 10.0
            },
            {
              id: other_product.id,
              name: 'Boné',
              quantity: 1,
              unit_price: 15.0,
              total_items_price: 15.0
            }
          ]
        )
      end
    end
  end

  describe 'DELETE /cart/:product_id' do
    let(:product) { create(:product, name: 'Boné', price: 15.0) }
    let(:cart) { create(:cart) }
    let(:item) { create(:cart_item, cart: cart, product: product, quantity: 2, price: 15.0) }

    before { post '/cart', params: { product_id: product.id, quantity: 1 } }

    context 'when product is in the cart' do
      it 'removes the product and returns the updated cart' do
        delete "/cart/#{product.id}"

        expect(response).to have_http_status(:ok)
        expect(parsed_response[:message]).to eq('Cart is empty')
      end
    end

    context 'when product is not in the cart' do
      it 'returns error message' do
        delete '/cart/999'

        expect(response).to have_http_status(:not_found)
        expect(parsed_response[:error]).to eq('Product not found')
      end
    end
  end
end
