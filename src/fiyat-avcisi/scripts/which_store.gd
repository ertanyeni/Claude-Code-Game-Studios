extends Control

## "Hangi Mağaza?" oyun modu.
## 3 mağaza arasından en ucuzunu seç.

const PRODUCT_ICONS := {
	"milk": "🥛", "bread": "🍞", "egg": "🥚", "cheese": "🧀",
	"olive": "🫒", "tea": "🍵", "sugar": "🍬", "flour": "🌾",
	"oil": "🫗", "pasta": "🍝", "rice": "🍚", "chicken": "🍗",
	"tomato": "🍅", "potato": "🥔", "banana": "🍌", "detergent": "🧴",
	"paper": "🧻", "diaper": "👶", "cola": "🥤", "coffee": "☕",
	"chocolate": "🍫", "chips": "🥨", "shampoo": "🧴", "toothpaste": "🪥",
	"yogurt": "🥛", "butter": "🧈", "chickpea": "🫘", "lentil": "🫘",
	"paste": "🥫", "honey": "🍯",
}

@onready var score_label: Label = $VBox/TopBar/ScoreLabel
@onready var lives_label: Label = $VBox/TopBar/LivesLabel
@onready var streak_label: Label = $VBox/StreakLabel
@onready var question_label: Label = $VBox/QuestionLabel
@onready var product_icon: Label = $VBox/ProductPanel/ProductVBox/ProductIcon
@onready var product_name: Label = $VBox/ProductPanel/ProductVBox/ProductName
@onready var category_label: Label = $VBox/ProductPanel/ProductVBox/CategoryLabel
@onready var store_btn1: Button = $VBox/StoreBtn1
@onready var store_btn2: Button = $VBox/StoreBtn2
@onready var store_btn3: Button = $VBox/StoreBtn3
@onready var feedback_label: Label = $VBox/FeedbackLabel
@onready var price_reveal: Label = $VBox/PriceReveal
@onready var back_btn: Button = $VBox/TopBar/BackBtn
@onready var next_timer: Timer = $NextTimer

var current_product: Dictionary
var current_stores: Array[String]
var correct_store: String
var is_waiting := false
var questions_asked := 0
var used_products: Array[String] = []


func _ready() -> void:
	GameManager.start_new_game()
	store_btn1.pressed.connect(_on_store_pressed.bind(0))
	store_btn2.pressed.connect(_on_store_pressed.bind(1))
	store_btn3.pressed.connect(_on_store_pressed.bind(2))
	back_btn.pressed.connect(_on_back)
	next_timer.timeout.connect(_next_question)
	_update_hud()
	_next_question()


func _next_question() -> void:
	if GameManager.lives <= 0:
		_game_over()
		return

	is_waiting = false
	feedback_label.text = ""
	price_reveal.text = ""
	_enable_buttons(true)

	# Kullanılmamış ürün seç
	current_product = _get_unused_product()
	current_stores = ProductDatabase.get_random_stores(3, current_product)
	correct_store = ProductDatabase.get_cheapest_store(current_product, current_stores)

	# UI güncelle
	var icon_key: String = current_product.get("icon", "")
	product_icon.text = PRODUCT_ICONS.get(icon_key, "📦")
	product_name.text = current_product.get("name", "???")
	category_label.text = current_product.get("category", "")

	var fun_questions := [
		"Bu ürünü en ucuza nerede bulursun? 🤔",
		"Cüzdanın için en iyi seçim hangisi? 💰",
		"Teyze hangisini seçerdi? 🧓",
		"En hesaplı mağaza hangisi? 🔍",
		"Kuruşçu dayı nereye gider? 🧐",
	]
	question_label.text = fun_questions[randi() % fun_questions.size()]

	var buttons := [store_btn1, store_btn2, store_btn3]
	for i in range(3):
		var store_id: String = current_stores[i]
		var store_name := ProductDatabase.get_store_name(store_id)
		buttons[i].text = "🏪 " + store_name
		var color := ProductDatabase.get_store_color(store_id)
		buttons[i].modulate = Color(1, 1, 1, 1)

	questions_asked += 1


func _get_unused_product() -> Dictionary:
	var product := ProductDatabase.get_random_product()
	var attempts := 0
	while used_products.has(product.get("id", "")) and attempts < 50:
		product = ProductDatabase.get_random_product()
		attempts += 1
	used_products.append(product.get("id", ""))
	if used_products.size() > 20:
		used_products.clear()
	return product


func _on_store_pressed(index: int) -> void:
	if is_waiting:
		return
	is_waiting = true
	_enable_buttons(false)

	var selected_store: String = current_stores[index]
	var buttons := [store_btn1, store_btn2, store_btn3]

	# Fiyatları göster
	var reveal_text := ""
	for i in range(3):
		var sid: String = current_stores[i]
		var price := ProductDatabase.get_price(current_product, sid)
		var price_str := "₺%.2f" % price
		if sid == correct_store:
			reveal_text += "✅ %s: %s\n" % [ProductDatabase.get_store_name(sid), price_str]
			buttons[i].modulate = Color(0.3, 1.0, 0.3, 1)
		elif sid == selected_store:
			reveal_text += "❌ %s: %s\n" % [ProductDatabase.get_store_name(sid), price_str]
			buttons[i].modulate = Color(1.0, 0.3, 0.3, 1)
		else:
			reveal_text += "   %s: %s\n" % [ProductDatabase.get_store_name(sid), price_str]
	price_reveal.text = reveal_text.strip_edges()

	if selected_store == correct_store:
		GameManager.add_correct_answer()
		feedback_label.text = FunMessages.get_correct_message()
		var streak_msg := FunMessages.get_streak_message(GameManager.current_streak)
		if streak_msg != "":
			streak_label.text = streak_msg
	else:
		GameManager.add_wrong_answer()
		feedback_label.text = FunMessages.get_wrong_message()
		streak_label.text = ""

	_update_hud()
	next_timer.start()


func _enable_buttons(enabled: bool) -> void:
	store_btn1.disabled = not enabled
	store_btn2.disabled = not enabled
	store_btn3.disabled = not enabled


func _update_hud() -> void:
	score_label.text = "⭐ %d" % GameManager.current_score
	var hearts := ""
	for i in range(GameManager.lives):
		hearts += "❤️"
	for i in range(3 - GameManager.lives):
		hearts += "🖤"
	lives_label.text = hearts


func _game_over() -> void:
	GameManager.end_game()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func _on_back() -> void:
	GameManager.end_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
