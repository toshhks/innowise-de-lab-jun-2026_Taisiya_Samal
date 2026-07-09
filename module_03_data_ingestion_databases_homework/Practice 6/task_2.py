product = { 
	"id": 105, 
	"name": "Organic Buckwheat", 
	"price": 3.50, 
	"stock": 100 
}
product['price'] = 4.20
product['category'] = 'Grains'
discount_rate = product.get('discount', 0)
print(product)
print(discount_rate)