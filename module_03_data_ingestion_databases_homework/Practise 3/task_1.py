products = ["Яблоки", "Хлеб", "Молоко", "Печенье", "Сок", "Кефир"]

for i in range(0, len(products), 2):
    product = products[i]
    print(f'Индекс {i}: Проверен товар {product} (Длина названия: {len(product)} символов)')
else:
    print('--- Выборочная проверка успешно завершена ---')