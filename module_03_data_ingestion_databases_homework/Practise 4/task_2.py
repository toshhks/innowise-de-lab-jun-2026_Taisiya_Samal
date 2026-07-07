product = " фермерский ТВОРОГ " 
price = 4.567 
qty = 3 
csv_row = "milk,bread,cheese" 
review = "Это лучший ТВОРОГ в городе!" 
file_path = r"C:\EcoMarket\data\2025\january\sales.csv"

clean_product = product.strip().lower().title()
total = price * qty
receipt = f'Чек "EcoMarket"\nТовар: Фермерский Творог\nКол-во: 3\nИтого: 13.70 руб.'
print(receipt)
print(' | '.join(csv_row.split(',')))
print('Отзыв относится к категории: Dairy' if 'творог' in review.lower() else '')
print(file_path)
# raw_string чтобы спецсимволы не учитывались а выводились как обычные