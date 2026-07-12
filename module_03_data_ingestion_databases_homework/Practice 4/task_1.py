raw_log = "ORDER-2025-01-15|FRT-APPLE-PL|+111 (23) 456-78-90| мИНсК "
order_id, product_code, raw_phone, raw_city = raw_log.split("|")


print(f'Позиция первого дефиса в коде товара: {product_code.find('-')}')
print(f'{"Код товара начинается с 'FRT'" if product_code.startswith( "FRT") else "Код товара не начинается с 'FRT'"}')

clean_phone = ''
for el in raw_phone:
    if (el.isdigit()):
        clean_phone+=el
    else:
        continue

print('Длина номера телефона: ' + str(len(clean_phone)))

clean_city = raw_city.strip().lower().title()

report = f'Заказ: {order_id}\nКатегория: {product_code[:3]} | Регион: {product_code[-2:]}\nТелефон: {clean_phone}\nГород: {clean_city}'
print(report)