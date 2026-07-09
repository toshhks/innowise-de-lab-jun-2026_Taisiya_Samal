SMALL_BATCH_LIMIT = 500

def calculate_batch(weight, price, discount = 0.0):
    """
    Рассчитывает общую стоимость партии товара.

    Args:
        weight (float): Вес партии в килограммах. Должен быть положительным числом.
        price (float): Цена за один килограмм в рублях. Должна быть положительным числом.

    Returns:
        float: Общая стоимость партии (weight * price).
    """

    summa = weight * price * (1 - discount)
    is_summa_bigger = summa > SMALL_BATCH_LIMIT

    return (summa, is_summa_bigger)

carrots, apples = calculate_batch(100, 4), calculate_batch(50, 20, 0.1)

print(f'Партия 1 (Морковь): Сумма {carrots[0]}. Превышение лимита: {carrots[1]}\nПартия 2 (Яблоки): Сумма {apples[0]}. Превышение лимита: {apples[1]}')

