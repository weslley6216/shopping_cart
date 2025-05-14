class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  validates_numericality_of :total_price, greater_than_or_equal_to: 0

  scope :inactive_since, ->(time) { where('last_interaction_at <= ?', time) }
  scope :abandoned_since, ->(time) { where(abandoned: true).where('updated_at <= ?', time) }

  def abandoned?
    abandoned
  end

  def mark_as_abandoned
    update!(abandoned: true) if !abandoned? && last_interaction_at <= 3.hours.ago
  end

  def remove_if_abandoned
    destroy! if abandoned? && updated_at <= 7.days.ago
  end

  def empty?
    cart_items.empty?
  end
end
