extends Node

## Ürün ve mağaza verilerini JSON'dan yükler.
## Autoload olarak yüklenir.

var products: Array[Dictionary] = []
var stores: Dictionary = {}
var categories: Dictionary = {}
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.randomize()
	_load_data()


func _load_data() -> void:
	var file := FileAccess.open("res://data/products.json", FileAccess.READ)
	if not file:
		push_error("products.json yüklenemedi!")
		return

	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		push_error("products.json parse hatası: " + json.get_error_message())
		return

	var data: Dictionary = json.data
	var raw_products: Array = data.get("products", [])
	products.clear()
	for p in raw_products:
		products.append(p as Dictionary)
	stores = data.get("stores", {})
	categories = data.get("categories", {})


func get_random_product() -> Dictionary:
	if products.is_empty():
		return {}
	return products[_rng.randi_range(0, products.size() - 1)]


func get_random_products(count: int) -> Array[Dictionary]:
	var shuffled := products.duplicate()
	shuffled.shuffle()
	var result: Array[Dictionary] = []
	for i in range(mini(count, shuffled.size())):
		result.append(shuffled[i])
	return result


func get_random_stores(count: int, product: Dictionary) -> Array[String]:
	var available: Array[String] = []
	var prices: Dictionary = product.get("prices", {})
	for store_id in prices:
		available.append(store_id)
	available.shuffle()
	var result: Array[String] = []
	for i in range(mini(count, available.size())):
		result.append(available[i])
	return result


func get_cheapest_store(product: Dictionary, store_list: Array[String]) -> String:
	var cheapest := ""
	var min_price := INF
	var prices: Dictionary = product.get("prices", {})
	for store_id in store_list:
		var price: float = prices.get(store_id, INF)
		if price < min_price:
			min_price = price
			cheapest = store_id
	return cheapest


func get_price(product: Dictionary, store_id: String) -> float:
	var prices: Dictionary = product.get("prices", {})
	return prices.get(store_id, 0.0)


func get_store_color(store_id: String) -> Color:
	var store: Dictionary = stores.get(store_id, {})
	var hex: String = store.get("color", "#888888")
	return Color.html(hex)


func get_store_name(store_id: String) -> String:
	var store: Dictionary = stores.get(store_id, {})
	return store.get("name", store_id)


func get_average_price(product: Dictionary) -> float:
	var prices: Dictionary = product.get("prices", {})
	if prices.is_empty():
		return 0.0
	var total := 0.0
	for price in prices.values():
		total += float(price)
	return total / float(prices.size())


func get_store_emoji(store_id: String) -> String:
	var store: Dictionary = stores.get(store_id, {})
	return store.get("logo_emoji", "🏪")


func get_store_bg_color(store_id: String) -> Color:
	var store: Dictionary = stores.get(store_id, {})
	var hex: String = store.get("bg_color", "#F5F5F5")
	return Color.html(hex)


func get_category_emoji(cat_name: String) -> String:
	var cat: Dictionary = categories.get(cat_name, {})
	return cat.get("emoji", "📦")


func get_product_display_name(product: Dictionary) -> String:
	return product.get("name", "???")


func get_product_brand(product: Dictionary) -> String:
	return product.get("brand", "")


func get_product_weight(product: Dictionary) -> String:
	return product.get("weight", "")


func get_product_description(product: Dictionary) -> String:
	return product.get("description", "")
