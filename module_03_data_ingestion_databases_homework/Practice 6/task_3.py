from enum import unique

suppliers_log = [
	"FreshFarm Inc",
	"GreenFields Ltd",
	"AgroWorld Co",
	"FreshFarm Inc",
	"GreenFields Ltd"
]

unique_suppliers = set(suppliers_log)
unique_suppliers.add('GreenFields Ltd')
print("FreshFarm Inc" in unique_suppliers)
print(unique_suppliers)
print(len(unique_suppliers))
