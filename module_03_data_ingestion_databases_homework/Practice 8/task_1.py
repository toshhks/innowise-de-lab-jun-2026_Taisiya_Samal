def calculate_purchase(product_name, weight, price):
    """
    Parameters:
    product_name (str): Название товара
    weight (int/float/str): Вес товара в килограммах (может быть передан как число или строка)
    price (float): Цена за один килограмм товара
    """
    try:
        numeric_weight = float(weight)
        total_cost = numeric_weight * price
        technical_index = 100 / numeric_weight
        print(f'Товар: {product_name}. Итоговая стоимость: {total_cost}$ ')
        print(f'Технический индекс: {technical_index:.2f}')
    except (TypeError, ValueError, ZeroDivisionError) as e:
        print(f'Тип ошибки: {type(e)}>\nСообщение: {e}')
        return 0
    finally:
        print("--- Проверка партии завершена ---")


calculate_purchase('Томаты', 100, 2.5)
calculate_purchase('Огурцы', 'пятьдесят', 1.8)
calculate_purchase('Перец', 0, 4.0)
calculate_purchase('Зелень', [10], 5.0)