require 'rails_helper'

RSpec.describe AbandonedCartsCleanupJob, type: :job do
  describe '#perform' do
    let(:recent_cart) { create(:cart, last_interaction_at: 1.hours.ago) }
    let(:inactive_cart) { create(:cart, last_interaction_at: 3.hours.ago) }
    let(:old_abandoned_cart) do
      create(:cart, last_interaction_at: 7.days.ago, abandoned: true, updated_at: 7.days.ago)
    end

    it 'marks carts as abandoned if inactive for over 3 hours' do
      expect { described_class.perform_now }.to change {
        inactive_cart.reload.abandoned?
      }.from(false).to(true)
    end

    it 'does not mark carts as abandoned if interaction is recent' do
      expect { described_class.perform_now }.not_to change(recent_cart, :abandoned?)
    end

    it 'removes carts abandoned for over 7 days' do
      expect { described_class.perform_now }.to change {
        Cart.exists?(old_abandoned_cart.id)
      }.from(true).to(false)
    end
  end
end
