class RemovePriceFromCartItems < ActiveRecord::Migration[7.1]
  def change
    remove_column :cart_items, :price, :decimal
  end
end
