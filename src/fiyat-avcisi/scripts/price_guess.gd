extends Control

## "Fiyat Bilmece" oyun modu — programatik UI.

const TOTAL_ROUNDS := 10

var round_label: Label
var score_label: Label
var question_label: Label
var guess_label: Label
var feedback_label: Label
var accuracy_bar: ProgressBar
var accuracy_label: Label
var product_card_parent: VBoxContainer
var guess_section: VBoxContainer
var submit_btn: Button
var next_btn: Button
var guess_slider: HSlider

var current_product: Dictionary
var current_store: String
var current_round := 0
var total_accuracy := 0.0
var product_queue: Array[Dictionary] = []


func _ready() -> void:
	GameManager.start_new_game()

	UIFactory.make_bg(self)
	var vbox := UIFactory.make_vbox(self, 10)

	# Üst bar
	var top := UIFactory.make_hbox(vbox, 8)
	var back_btn := UIFactory.make_button(top, "◀", UIFactory.COLORS.bg_card_light, 44)
	back_btn.custom_minimum_size.x = 50
	back_btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	back_btn.pressed.connect(_on_back)

	round_label = UIFactory.make_label(top, "🎯 Soru: 1/10", 18, UIFactory.COLORS.text_white)
	round_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_label = UIFactory.make_label(top, "⭐ 0", 18, UIFactory.COLORS.accent_yellow)

	# Soru
	question_label = UIFactory.make_label(vbox, "", 18, UIFactory.COLORS.accent_purple)

	# Ürün kartı alanı
	product_card_parent = VBoxContainer.new()
	product_card_parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(product_card_parent)

	UIFactory.make_spacer(vbox, 6)

	# Tahmin bölümü
	guess_section = VBoxContainer.new()
	guess_section.add_theme_constant_override("separation", 10)
	guess_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(guess_section)

	guess_label = UIFactory.make_label(guess_section, "₺ 50.00", 36, UIFactory.COLORS.accent_yellow)
	guess_slider = UIFactory.make_slider(guess_section, 5, 500, 1)
	guess_slider.value_changed.connect(func(v: float): guess_label.text = "₺ %.2f" % v)

	submit_btn = UIFactory.make_button(guess_section, "🎯  Bu Fiyata İnanıyorum!", UIFactory.COLORS.accent_purple, 56)
	submit_btn.pressed.connect(_on_submit)

	# Feedback
	feedback_label = UIFactory.make_label(vbox, "", 18, UIFactory.COLORS.text_white)

	# Sonraki butonu (gizli)
	next_btn = UIFactory.make_button(vbox, "➡️  Sonraki Ürün", UIFactory.COLORS.accent_blue, 52)
	next_btn.visible = false
	next_btn.pressed.connect(_next_round)

	UIFactory.make_spacer(vbox, 6)

	# Doğruluk barı
	accuracy_bar = UIFactory.make_progress_bar(vbox, 0, UIFactory.COLORS.accent_green)
	accuracy_label = UIFactory.make_label(vbox, "Toplam Doğruluk: %0", 14, UIFactory.COLORS.text_dim)

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
	var store_ids := ProductDatabase.stores.keys()
	current_store = store_ids[randi() % store_ids.size()]

	round_label.text = "🎯 Soru: %d/%d" % [current_round, TOTAL_ROUNDS]

	var store_name := ProductDatabase.get_store_name(current_store)
	var store_emoji := ProductDatabase.get_store_emoji(current_store)
	var qs := [
		"%s %s'ta bu kaç lira? 🤔" % [store_emoji, store_name],
		"%s %s fiyatını bil bakalım! 💰" % [store_emoji, store_name],
		"Kasada ne yazar? %s %s 🏷️" % [store_emoji, store_name],
	]
	question_label.text = qs[randi() % qs.size()]

	# Ürün kartı
	for child in product_card_parent.get_children():
		child.queue_free()
	UIFactory.make_product_card(product_card_parent, current_product, ProductDatabase)

	# Slider ayarla
	var real_price := ProductDatabase.get_price(current_product, current_store)
	var min_v := maxf(5.0, real_price * 0.3)
	var max_v := real_price * 2.2
	var step := 0.5 if real_price < 30 else (1.0 if real_price < 100 else (2.5 if real_price < 300 else 5.0))
	guess_slider.min_value = min_v
	guess_slider.max_value = max_v
	guess_slider.step = step
	guess_slider.value = snappedi(int((min_v + max_v) / 2.0), int(maxf(step, 1)))
	guess_label.text = "₺ %.2f" % guess_slider.value


func _on_submit() -> void:
	var guess: float = guess_slider.value
	var real := ProductDatabase.get_price(current_product, current_store)
	var diff := absf(guess - real)
	var pct := (diff / real) * 100.0
	var xp := GameManager.add_guess_score(pct)
	total_accuracy += (100.0 - minf(pct, 100.0))

	var emoji := "🎯💯" if pct <= 3.0 else ("🎯" if pct <= 10.0 else ("👍" if pct <= 20.0 else "😅"))

	var fb := "%s\n" % emoji
	fb += "Gerçek fiyat: ₺%.2f\n" % real
	fb += "Senin tahmin: ₺%.2f  (fark: ₺%.2f)\n\n" % [guess, diff]

	if pct <= 1.0:
		fb += "KURUŞU KURUŞUNA! Robot musun?! 🤖"
	elif pct <= 3.0:
		fb += "İnanılmaz! Kasiyerler bile bilmez! 🧠"
	elif pct <= 5.0:
		fb += "Çok yakın! Alışveriş teyzesi seviyesi! 👵"
	elif pct <= 10.0:
		fb += "Fena değil! Biraz daha market gezsen pro! 🚶"
	elif pct <= 20.0:
		fb += "Hmm, etiketlere dikkat! 👀"
	else:
		fb += "2019'da mı kaldın?! 😂"

	fb += "\n+%d XP" % xp

	feedback_label.text = fb
	submit_btn.visible = false
	next_btn.visible = true
	next_btn.text = "➡️  Sonraki Ürün" if current_round < TOTAL_ROUNDS else "🏁  Sonuçlar"

	var avg := total_accuracy / float(current_round)
	accuracy_bar.value = avg
	accuracy_label.text = "Toplam Doğruluk: %%%d" % roundi(avg)
	score_label.text = "⭐ %d" % GameManager.current_score


func _game_over() -> void:
	GameManager.end_game()
	get_tree().change_scene_to_file("res://scenes/game_over.tscn")


func _on_back() -> void:
	GameManager.end_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
