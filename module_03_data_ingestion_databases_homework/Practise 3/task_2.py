total_revenue = 0

daily_logs = [
    [500, 0, 1200],       # Касса 1 (Нормальная)
    [300, -999, 800],     # Касса 2 (Сломалась посередине, 800 не должно посчитаться)
    [1500, 200]           # Касса 3 (Нормальная)
]

for i, v in enumerate(daily_logs):
    print(f'--- Обработка Кассы №{1} ---')
    for el in v:
        if (el == -999):
            print('Аварийная остановка кассы!')
            break
        elif (el == 0):
            print('Сбой (0).')
            continue
        elif (el > 0):
            total_revenue += el
            print(f'Добавлено: {el}')
else:
      print('=== ИТОГ ДНЯ ===')
      print(f'Общая выручка магазина: {total_revenue}')
