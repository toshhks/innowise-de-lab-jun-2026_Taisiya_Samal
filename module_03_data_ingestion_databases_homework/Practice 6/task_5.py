import json
api_response_json = """ 
{ 
	"store": "StoreHub", 
	"orders": [ 
		{"id": 1, "total": 50}, 
		{"id": 2, "total": 200}, 
		{"id": 3, "total": 150} 
		]
 } 
"""
api_response_data = json.loads(api_response_json)
orders_list = api_response_data["orders"]
high_value_orders = [el for el in orders_list if el["total"] > 100]
api_response_data["high_value_orders"] = high_value_orders
api_response_json_modified = json.dumps(api_response_data)

print(api_response_json_modified)