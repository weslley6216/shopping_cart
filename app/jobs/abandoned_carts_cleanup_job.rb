class AbandonedCartsCleanupJob < ApplicationJob
  queue_as :default

  def perform
    mark_abandoned_carts
    remove_old_abandoned_carts
  end

  private

  def mark_abandoned_carts
    Cart.inactive_since(3.hours.ago).where(abandoned: false).find_each(&:mark_as_abandoned)
  end

  def remove_old_abandoned_carts
    Cart.abandoned_since(7.days.ago).find_each(&:remove_if_abandoned)
  end
end
