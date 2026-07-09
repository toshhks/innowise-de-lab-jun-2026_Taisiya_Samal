usd_prices = {
"Banana": 1.2,
"Mango": 2.5,
"Avocado": 2.0
}
eur_prices = {key: value*0.9 for key, value in usd_prices.items()}

print(eur_prices)
