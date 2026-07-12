def calculate_total_delivery_cost(product_name, weights, prices, discount, currency_rate, extra_costs=''):
    if (len(weights) == len(prices)):
        every_position_price: list[int] = [weights[i]*prices[i] for i in range(len(weights))]
        total_sum:float = sum(every_position_price)
        if discount:
            total_sum *= (1 - discount)
        if extra_costs:
            total_sum += sum([int(el) for el in (extra_costs.split(','))])
        final_sum: float = total_sum * currency_rate
        return {product_name: final_sum}
    else:
        return 0

result1 = calculate_total_delivery_cost(
    product_name="Овощная партия",
    weights=[100, 50],
    prices=[4, 6],
    discount=0.1,
    currency_rate=1,
    extra_costs="20,15"
)

result2 = calculate_total_delivery_cost(
    product_name="Фруктовая партия",
    weights=(30, 20, 10),
    prices=(15, 12, 18),
    discount=None,
    currency_rate=1.2,
    extra_costs="25"
)

for result in [result1, result2]:
    if result:
        for name, cost in result.items():
            print(f"Товар: {name}, итоговая стоимость: {cost}")