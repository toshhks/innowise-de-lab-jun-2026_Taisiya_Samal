class Product:
    def __init__(self, name, price):
        self.__price = price
        self.name = name

    def set_price(self, new_price):
        if (new_price > 0):
            self.__price = new_price
        else:
            print("Ошибка безопасности: Цена должна быть положительной!")
    
    def get_price(self):
        return self.__price
    
    def calculate_cost(self):
        return self.get_price()
    
    def get_display_info(self):
        return f"Товар: {self.name} | Цена: {self.__price} руб."
    

class WeighableProduct(Product):
    def __init__(self, name, price, weight):
        super().__init__(name, price)
        self.weight = weight

    def get_display_info(self):
        return f"Весовой товар: {self.name} | Вес: {self.weight} кг | Итого: {self.calculate_cost()} руб."

class PackagedProduct(Product):

    def __init__(self, name, price, quantity):
        super().__init__(name, price)
        self.quantity = quantity

    def calculate_cost(self):
        return self.get_price() * self.quantity

    def get_display_info(self):
        return f"Упаковка: {self.name} | Количество: {self.quantity} шт. | Итого: {self.calculate_cost} руб."

products = []
products.append(Product('Молоко', 100.0))
products.append(WeighableProduct('Яблоки', 50.0, 2.5))
products.append(PackagedProduct('Яйца', 12.0, 10))

products[0].set_price(-200)
total_sum = 0

for product in products:
    product.get_display_info()
    total_sum = product.calculate_cost()

print(f'''--- Чек EcoMarket ---
Товар: Молоко | Цена: 100 руб.
Весовой товар: Яблоки | Вес: 2.5 кг | Итого: 125.0 руб.
Упаковка: Яйца | Количество: 10 шт. | Итого: 120 руб.
---------------------
ИТОГО К ОПЛАТЕ: {total_sum} руб.''')
