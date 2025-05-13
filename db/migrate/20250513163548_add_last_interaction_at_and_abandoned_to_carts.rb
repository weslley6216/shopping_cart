class AddLastInteractionAtAndAbandonedToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :last_interaction_at, :datetime
    add_column :carts, :abandoned, :boolean, default: false
  end
end
