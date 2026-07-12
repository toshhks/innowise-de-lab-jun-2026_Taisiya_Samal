branches = [
    {"city": "Minsk", "revenue": 15000},
    {"city": "Warsaw", "revenue": 32000},
    {"city": "London", "revenue": 12000}
]

def audit_logger(func):
	print('[AUDIT] Запуск анализа....')
	def wrapper(*args, **kwargs):
		result = func(*args, **kwargs)
		return result
	print('[AUDIT] Анализ завершен..')
	return wrapper

@audit_logger
def get_sorted_report(branches):
	return sorted(branches, key=lambda x: x['revenue'], reverse=True)

result = get_sorted_report(branches)
print('Топ филиалов:')
for index, item in enumerate(result):
	print(f'{index+1}. {item["city"]}: {item["revenue"]}')

