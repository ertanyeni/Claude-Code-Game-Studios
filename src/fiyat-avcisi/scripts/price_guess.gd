extends Control

## "Fiyat Bilmece" oyun modu.
## Ürünün fiyatını slider ile tahmin et.

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

const TOTAL_ROUNDS := 10

@onready var round_label: Label = $VBox/TopBar/RoundLabel
@onready var score_label: Label = $VBox/TopBar/ScoreLabel
@onready var question_label: Label = $VBox/QuestionLabel
@onready var product_icon: Label = $VBox/ProductPanel/ProductVBox/ProductIcon
@onready var product_name: Label = $VBox/ProductPanel/ProductVBox/ProductName
@onready var store_label: Label = $VBox/ProductPanel/ProductVBox/StoreLabel
@onready var guess_label: Label = $VBox/GuessLabel
@onready var guess_slider: HSlider = $VBox/GuessSlider
@onready var submit_btn: Button = $VBox/SubmitBtn
@onready var feedback_label: Label = $VBox/FeedbackLabel
@onready var next_btn: Button = $VBox/NextBtn
@onready var accuracy_bar: ProgressBar = $VBox/AccuracyBar
@onready var accuracy_label: Label = $VBox/AccuracyLabel
@onready var back_btn: Button = $VBox/TopBar/BackBtn

var current_product: Dictionary
var current_store: String
var current_round := 0
var total_accuracy := 0.0
var product_queue: Array[Dictionary] = []


func _ready() -> void:
	GameManager.start_new_game()
	submit_btn.pressed.connect(_on_submit)
	next_btn.pressed.connect(_next_round)
	back_btn.pressed.connect(_on_back)
	guess_slider.value_changed.connect(_on_slider_changed)
	product_queue = ProductDatabase.get_random_products(TOTAL_ROUNDS)
	_next_round()


func _next_round() -> void:
	current_round += 1
	if current_round > TOTAL_ROUNDS or product_queue.is_empty():
		_game_over()
		return

	submit_btn.visible = true
	next_btn.visible = false
	feedback_label.text = ""

	current_product = product_queue.pop_front()

	# Rastgele mağaza
	var store_ids := ProductDatabase.stores.keys()
	current_store = store_ids[randi() % store_ids.size()]

	# UI
	var icon_key: String = current_product.get("icon", "")
	product_icon.text = PRODUCT_ICONS.get(icon_key, "📦")
	product_name.text = current_product.get("name", "???")
	store_label.text = "🏪 " + ProductDatabase.get_store_name(current_store)
	round_label.text = "🎯 Soru: %d/%d" % [current_round, TOTAL_ROUNDS]

	var fun_qs := [
		"Bu ürün %s'ta kaç lira? 🤔" % ProductDatabase.get_store_name(current_store),
		"%s'ta bunu kaça bulursun? 💰" % ProductDatabase.get_store_name(current_store),
		"Hmm, %s'ta fiyatı ne acaba? 🧐" % ProductDatabase.get_store_name(current_store),
		"Kasada ne yazar? %s fiyatı! 🏷️" % ProductDatabase.get_store_name(current_store),
	]
	question_label.text = fun_qs[randi() % fun_qs.size()]

	# Slider ayarla
	var real_price := ProductDatabase.get_price(current_product, current_store)
	guess_slider.min_value = maxf(5.0, real_price * 0.3)
	guess_slider.max_value = real_price * 2.2
	guess_slider.step = _get_step(real_price)
	guess_slider.value = snappedi(int((guess_slider.min_value + guess_slider.max_value) / 2.0), int(guess_slider.step))
	_on_slider_changed(guess_slider.value)


func _get_step(price: float) -> float:
	if price < 30:
		return 0.5
	elif price < 100:
		return 1.0
	elif price < 300:
		return 2.5
	else:
		return 5.0


func _on_slider_changed(value: float) -> void:
	guess_label.text = "₺ %.2f" % value


func _on_submit() -> void:
	var guess: float = guess_slider.value
	var real_price := ProductDatabase.get_price(current_product, current_store)
	var diff := absf(guess - real_price)
	var accuracy_percent := (diff / real_price) * 100.0

	var xp_earned := GameManager.add_guess_score(accuracy_percent)
	total_accuracy += (100.0 - minf(accuracy_percent, 100.0))

	var emoji := ""
	if accuracy_percent <= 3.0:
		emoji = "🎯💯"
	elif accuracy_percent <= 10.0:
		emoji = "🎯"
	elif accuracy_percent <= 20.0:
		emoji = "👍"
	else:
		emoji = "😅"

	var fb := "%s\n" % emoji
	fb += "Gerçek fiyat: ₺%.2f\n" % real_price
	fb += "Senin tahmin: ₺%.2f\n" % guess
	fb += "Fark: ₺%.2f\n\n" % diff

	if accuracy_percent <= 1.0:
		fb += "KURUŞU KURUŞUNA! Sen market robotu musun?! 🤖"
	elif accuracy_percent <= 3.0:
		fb += "İnanılmaz! Kasiyerler bile bu kadar bilmez! 🧠"
	elif accuracy_percent <= 5.0:
		fb += "Çok yakın! Alışveriş teyzesi seviyesi! 👵"
	elif accuracy_percent <= 10.0:
		fb += "Fena değil! Biraz daha market gezsen pro olacaksın! 🚶"
	elif accuracy_percent <= 20.0:
		fb += "Hmm, etiketlere biraz daha dikkat! 👀"
	else:
		fb += "Sen en son markete 2019'da mı girdin?! 😂"

	fb += "\n+%d XP" % xp_earned

	feedback_label.text = fb
	submit_btn.visible = false
	next_btn.visible = true
	next_btn.text = "➡️ Sonraki Ürün" if current_round < TOTAL_ROUNDS else "🏁 Sonuçlar"

	# Doğruluk barı
	var avg_accuracy := total_accuracy / float(current_round)
	accuracy_bar.value = avg_accuracy
	accuracy_label.text = "Toplam Doğruluk: %%%d" % roundi(avg_accuracy)
	score_label.text = "⭐ %d" % GameManager.current_score


func _game_over() -> void:
	GameManager.end_game()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func _on_back() -> void:
	GameManager.end_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
