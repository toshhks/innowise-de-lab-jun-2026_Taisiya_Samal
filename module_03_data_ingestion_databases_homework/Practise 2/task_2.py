product_name = "Морковь мытая"
price = 2.5
stock_quantity = 150
is_local_farm = True
supplier = None

has_coupon = True
has_card = False
total = 10

is_hit = True if price < 3 and is_local_farm else False
print('Является ли товар хитом? ' + str(is_hit))

has_supplier = True if supplier else False
can_show_in_app = True if has_supplier and stock_quantity else False 
needs_restock = True if stock_quantity <= 20 or is_hit else False
is_blocked = True if not is_local_farm else False

print('Поставщик указан? ' + str(has_supplier))
print('Показывать в приложении? ' + str(can_show_in_app))
print('Нужно пополнение? ' + str(needs_restock))
print('Товар заблокирован для акции? ' + str(is_blocked))

discount_without_brackets = True if total > 50 and has_coupon or total > 50 and has_card else False
discount_with_brackets = True if total > 50 and (has_coupon or has_card) else False

print('Скидка без скобок: ' + str(discount_without_brackets))
print('Скидка со скобками: ' + str(discount_with_brackets))

price += 1.0
stock_quantity *= 2
boxes = stock_quantity
boxes //= 10

is_hit = True if price < 3 and is_local_farm else False
needs_restock = True if stock_quantity <= 20 or is_hit else False

print('Цена после изменения: ' + str(price))
print('Остаток после изменения: ' + str(stock_quantity))
print('Полных коробок по 10 кг: ' + str(boxes))

print('Является ли товар хитом (после изменений)? ' + str(is_hit))
print('Нужно пополнение (после изменений)? ' + str(needs_restock))