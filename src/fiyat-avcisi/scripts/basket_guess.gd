extends Control

## "Sepet Tahmini" oyun modu.
## Ürünleri sepete ekle, toplam tutarı tahmin et.

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

const BASKET_SIZE := 6

@onready var round_label: Label = $VBox/TopBar/RoundLabel
@onready var score_label: Label = $VBox/TopBar/ScoreLabel
@onready var store_info: Label = $VBox/StoreInfo
@onready var product_icon: Label = $VBox/ProductPanel/ProductVBox/ProductIcon
@onready var product_name: Label = $VBox/ProductPanel/ProductVBox/ProductName
@onready var add_btn: Button = $VBox/AddBtn
@onready var basket_list: Label = $VBox/BasketList
@onready var guess_section: VBoxContainer = $VBox/GuessSection
@onready var guess_label: Label = $VBox/GuessSection/GuessLabel
@onready var guess_slider: HSlider = $VBox/GuessSection/GuessSlider
@onready var submit_btn: Button = $VBox/GuessSection/SubmitBtn
@onready var feedback_label: Label = $VBox/FeedbackLabel
@onready var result_section: VBoxContainer = $VBox/ResultSection
@onready var result_text: Label = $VBox/ResultSection/ResultText
@onready var continue_btn: Button = $VBox/ResultSection/ContinueBtn
@onready var back_btn: Button = $VBox/TopBar/BackBtn
@onready var product_panel: PanelContainer = $VBox/ProductPanel

var basket_products: Array[Dictionary] = []
var current_product: Dictionary
var selected_store: String
var product_queue: Array[Dictionary] = []
var basket_total := 0.0
var rounds_played := 0


func _ready() -> void:
	GameManager.start_new_game()
	add_btn.pressed.connect(_on_add_to_basket)
	submit_btn.pressed.connect(_on_submit_guess)
	continue_btn.pressed.connect(_start_new_round)
	back_btn.pressed.connect(_on_back)
	guess_slider.value_changed.connect(_on_slider_changed)
	_start_new_round()


func _start_new_round() -> void:
	basket_products.clear()
	basket_total = 0.0
	rounds_played += 1
	feedback_label.text = ""
	result_section.visible = false
	guess_section.visible = false
	product_panel.visible = true
	add_btn.visible = true

	# Rastgele mağaza seç
	var store_ids := ProductDatabase.stores.keys()
	selected_store = store_ids[randi() % store_ids.size()]
	var store_name := ProductDatabase.get_store_name(selected_store)
	var joke := FunMessages.get_store_joke(selected_store)
	store_info.text = "🏪 %s'ta alışverişteyiz!\n%s" % [store_name, joke]

	# Ürün kuyruğu
	product_queue = ProductDatabase.get_random_products(BASKET_SIZE)
	_show_next_product()
	_update_basket_display()


func _show_next_product() -> void:
	if product_queue.is_empty():
		_show_guess_phase()
		return

	current_product = product_queue.pop_front()
	var icon_key: String = current_product.get("icon", "")
	product_icon.text = PRODUCT_ICONS.get(icon_key, "📦")
	product_name.text = current_product.get("name", "???")
	round_label.text = "🧺 Sepet: %d/%d ürün" % [basket_products.size(), BASKET_SIZE]

	var fun_texts := [
		"🛒 Sepete At!",
		"🛒 Bunu da Alalım!",
		"🛒 Hop Sepete!",
		"🛒 Bu Lazım!",
		"🛒 Atıyorum!",
	]
	add_btn.text = fun_texts[randi() % fun_texts.size()]


func _on_add_to_basket() -> void:
	var price := ProductDatabase.get_price(current_product, selected_store)
	basket_total += price
	basket_products.append(current_product)
	_update_basket_display()
	_show_next_product()


func _update_basket_display() -> void:
	if basket_products.is_empty():
		basket_list.text = "Sepet boş... Doldur bakalım! 🛒"
		return

	var text := "📋 Sepetindekiler:\n"
	for p in basket_products:
		var icon_key: String = p.get("icon", "")
		var icon: String = PRODUCT_ICONS.get(icon_key, "📦")
		text += "%s %s\n" % [icon, p.get("name", "")]
	basket_list.text = text.strip_edges()


func _show_guess_phase() -> void:
	product_panel.visible = false
	add_btn.visible = false
	guess_section.visible = true
	round_label.text = "🧺 Sepet dolu! Tahmin zamanı!"

	# Slider aralığını ayarla
	var min_guess := maxf(10.0, basket_total * 0.4)
	var max_guess := basket_total * 1.8
	guess_slider.min_value = snappedi(int(min_guess), 5)
	guess_slider.max_value = snappedi(int(max_guess), 5)
	guess_slider.value = snappedi(int((min_guess + max_guess) / 2.0), 5)
	_on_slider_changed(guess_slider.value)

	var fun_asks := [
		"💰 Bu sepetin tutarını tahmin et!\nİçinden gel!",
		"💰 Kasada ne kadar ödeyeceksin?\nHadi bakalım!",
		"💰 Toplam tutar ne?\nTeyze hesabını yapsın!",
	]
	$VBox/GuessSection/GuessTitle.text = fun_asks[randi() % fun_asks.size()]


func _on_slider_changed(value: float) -> void:
	guess_label.text = "₺ %.2f" % value


func _on_submit_guess() -> void:
	var guess: float = guess_slider.value
	var diff := absf(guess - basket_total)
	var accuracy_percent := (diff / basket_total) * 100.0

	var xp_earned := GameManager.add_guess_score(accuracy_percent)

	var result := "🧾 Gerçek Tutar: ₺%.2f\n" % basket_total
	result += "🎯 Senin Tahmin: ₺%.2f\n" % guess
	result += "📏 Fark: ₺%.2f (%%%s)\n\n" % [diff, "%.1f" % accuracy_percent]
	result += FunMessages.get_basket_message(accuracy_percent)
	result += "\n\n+%d XP kazandın!" % xp_earned

	result_text.text = result
	guess_section.visible = false
	result_section.visible = true
	score_label.text = "⭐ %d" % GameManager.current_score


func _on_back() -> void:
	GameManager.end_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
