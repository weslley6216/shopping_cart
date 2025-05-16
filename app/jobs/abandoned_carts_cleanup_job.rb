class AbandonedCartsCleanupJob < ApplicationJob
  queue_as :default

  def perform
    Rails.logger.info('[AbandonedCartsCleanupJob] Starting cleanup...')

    mark_abandoned_carts
    remove_old_abandoned_carts

    Rails.logger.info('[AbandonedCartsCleanupJob] Cleanup finished.')
  end

  private

  def mark_abandoned_carts
    Cart.inactive_for_abandonment.find_each(&:mark_as_abandoned!)
  end

  def remove_old_abandoned_carts
    Cart.expired_abandoned.find_each(&:remove_if_abandoned!)
  end
end
