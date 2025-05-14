# Create products
products_data = [
  { name: 'Samsung Galaxy S24 Ultra', price: 12999.99 },
  { name: 'iPhone 15 Pro Max', price: 14999.99 },
  { name: 'Xiaomi Mi 27 Pro Plus Master Ultra', price: 999.99 },
]

products = products_data.map do |product_data|
  Product.find_or_create_by!(name: product_data[:name]) do |product|
    product.price = product_data[:price]
  end
end

puts "Created #{Product.count} products."

# 1. Active Cart (should not be affected)
active_cart = Cart.find_or_create_by!(last_interaction_at: 2.hours.ago) do |cart|
  cart.total_price = 0
end

CartItem.find_or_create_by!(cart: active_cart, product: products[0]) do |item|
  item.quantity = 1
  item.price = products[0].price
end

active_cart.update!(total_price: active_cart.cart_items.sum('quantity * price'))
puts "Created active cart (ID: #{active_cart.id})"

# 2. Inactive Cart (must be marked as abandoned)
inactive_cart = Cart.find_or_create_by!(last_interaction_at: 4.hours.ago) do |cart|
  cart.total_price = 0
end

CartItem.find_or_create_by!(cart: inactive_cart, product: products[1]) do |item|
  item.quantity = 2
  item.price = products[1].price
end

inactive_cart.update!(total_price: inactive_cart.cart_items.sum('quantity * price'))
puts "Created inactive cart (ID: #{inactive_cart.id}) - Should be abandoned"

# 3. Old Abandoned Cart (must be removed)
old_abandoned_cart = Cart.find_or_create_by!(last_interaction_at: 8.days.ago,
                                             abandoned: true) do |cart|
  cart.total_price = 0
end

CartItem.find_or_create_by!(cart: old_abandoned_cart, product: products[2]) do |item|
  item.quantity = 3
  item.price = products[2].price
end

old_abandoned_cart.update!(total_price: old_abandoned_cart.cart_items.sum('quantity * price'))
old_abandoned_cart.update_column(:updated_at, 8.days.ago)
puts "Created old abandoned cart (ID: #{old_abandoned_cart.id}) - Should be removed"

puts 'Seed completed!'
