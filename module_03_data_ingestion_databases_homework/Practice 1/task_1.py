# category_a: "Vegetables" (Ошибочно присвоено фруктам)
category_a = "Vegetables"

# category_b: "Fruits" (Ошибочно присвоено овощам)
category_b = "Fruits"

# price_per_unit_a: 150 (цена за ящик партии фруктов)
price_per_unit_a = 150

#quantity_a: 40 (количество ящиков партии фруктов)
quantity_a = 40

# vat_rate: 0.2 (НДС 20%)
vat_rate = 0.2

category_a, category_b = category_b, category_a

total_value = (price_per_unit_a*quantity_a) + (price_per_unit_a*quantity_a*vat_rate)


print(f'Текущая категория A: {category_a}')
print(f'Общая стоимость партии с НДС:{total_value}')
