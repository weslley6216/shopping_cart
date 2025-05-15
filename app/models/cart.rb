class Cart < ApplicationRecord
  ABANDONMENT_THRESHOLD = 3.hours
  REMOVE_ABANDONED_AFTER = 7.days

  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  scope :recently_active, lambda {
    where('last_interaction_at > ?', ABANDONMENT_THRESHOLD.ago)
  }

  scope :inactive_for_abandonment, lambda {
    where(abandoned: false).where('last_interaction_at <= ?', ABANDONMENT_THRESHOLD.ago)
  }

  scope :expired_abandoned, lambda {
    where(abandoned: true).where('updated_at <= ?', REMOVE_ABANDONED_AFTER.ago)
  }

  def abandoned?
    abandoned
  end

  def mark_as_abandoned
    update!(abandoned: true) if !abandoned? && last_interaction_at <= ABANDONMENT_THRESHOLD.ago
  end

  def remove_if_abandoned
    destroy! if abandoned? && updated_at <= REMOVE_ABANDONED_AFTER.ago
  end

  def calculate_total_price = cart_items.sum(&:total_items_price)
  def empty? = cart_items.empty?
end
