require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)

      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include('must be greater than or equal to 0')
    end
  end

  describe 'mark_as_abandoned' do
    let(:cart) { create(:cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      cart.update(last_interaction_at: 3.hours.ago)

      expect { cart.mark_as_abandoned }.to change { cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:cart) { create(:cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      cart.mark_as_abandoned
      cart.update_column(:updated_at, 8.days.ago)

      expect { cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end

  describe 'scopes' do
    let(:active_cart) { create(:cart, last_interaction_at: 2.hours.ago, abandoned: false) }
    let(:inactive_cart) { create(:cart, last_interaction_at: 4.hours.ago, abandoned: false) }
    let(:abandoned_cart_recent) { create(:cart, last_interaction_at: 8.days.ago, abandoned: true, updated_at: 1.day.ago) }
    let(:abandoned_cart_expired) { create(:cart, last_interaction_at: 10.days.ago, abandoned: true, updated_at: 8.days.ago) }

    describe '.recently_active' do
      it 'returns carts with last interaction within the abandonment threshold' do
        expect(Cart.recently_active).to include(active_cart)
        expect(Cart.recently_active).not_to include(inactive_cart)
        expect(Cart.recently_active).not_to include(abandoned_cart_recent)
        expect(Cart.recently_active).not_to include(abandoned_cart_expired)
      end
    end

    describe '.inactive_for_abandonment' do
      it 'returns non-abandoned carts with last interaction before the abandonment threshold' do
        expect(Cart.inactive_for_abandonment).to include(inactive_cart)
        expect(Cart.inactive_for_abandonment).not_to include(active_cart)
        expect(Cart.inactive_for_abandonment).not_to include(abandoned_cart_recent)
        expect(Cart.inactive_for_abandonment).not_to include(abandoned_cart_expired)
      end
    end

    describe '.expired_abandoned' do
      it 'returns abandoned carts updated before the removal threshold' do
        expect(Cart.expired_abandoned).to include(abandoned_cart_expired)
        expect(Cart.expired_abandoned).not_to include(active_cart)
        expect(Cart.expired_abandoned).not_to include(inactive_cart)
        expect(Cart.expired_abandoned).not_to include(abandoned_cart_recent)
      end
    end
  end
end
