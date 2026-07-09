raw_sku = "CARROT-001"
raw_regions = ("Minsk", "Warsaw", "Berlin", "Warsaw")
raw_weight_str = "2.5"
raw_stock_str = "150"

weight_kg = float(raw_weight_str)
stock_quantity = int(raw_stock_str)

sku_as_list = list(raw_sku)
regions_list = list(raw_regions)
unique_regions = set(raw_regions)
regions_tuple = tuple(unique_regions)

empty_list_1, empty_list_2 = [], list()
empty_dict_1, empty_dict_2 = {}, dict()
empty_tuple_1, empty_tuple_2 = (), tuple()
empty_set = set()

not_empty_list_1 = [1,2,3]
not_empty_dict_1 = {1: '1', 2: '2', 3: '3'}
not_empty_tuple_1 = (1,2,3)
not_empty_set = set([1, 2, 3])

print(weight_kg, stock_quantity)
print(sku_as_list, regions_list, unique_regions, regions_tuple)
print(bool(empty_list_1), bool(empty_dict_1), bool(empty_tuple_1), bool(empty_set))
print(bool(not_empty_list_1), bool(not_empty_dict_1), bool(not_empty_tuple_1), bool(not_empty_set))