extends Control

## "Hangi Mağaza?" oyun modu — tamamen programatik UI.

var score_label: Label
var lives_label: Label
var streak_label: Label
var feedback_label: Label
var price_reveal_label: Label
var product_card_parent: VBoxContainer
var buttons_parent: VBoxContainer
var store_buttons: Array[Button] = []

var current_product: Dictionary
var current_stores: Array[String]
var correct_store: String
var is_waiting := false
var used_products: Array[String] = []
var next_timer: Timer


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

	score_label = UIFactory.make_label(top, "⭐ 0", 20, UIFactory.COLORS.accent_yellow)
	score_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	lives_label = UIFactory.make_label(top, "❤️❤️❤️", 20, UIFactory.COLORS.accent_red)

	# Streak
	streak_label = UIFactory.make_label(vbox, "", 18, UIFactory.COLORS.accent_orange)

	# Soru
	UIFactory.make_label(vbox, "En ucuzu hangi mağazada? 🤔", 18, UIFactory.COLORS.text_dim)

	# Ürün kartı alanı
	product_card_parent = VBoxContainer.new()
	product_card_parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(product_card_parent)

	UIFactory.make_spacer(vbox, 6)

	# Mağaza butonları alanı
	buttons_parent = VBoxContainer.new()
	buttons_parent.add_theme_constant_override("separation", 10)
	buttons_parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(buttons_parent)

	UIFactory.make_spacer(vbox, 4)

	# Geri bildirim
	feedback_label = UIFactory.make_label(vbox, "", 20, UIFactory.COLORS.accent_green)
	price_reveal_label = UIFactory.make_label(vbox, "", 16, UIFactory.COLORS.text_dim)

	# Timer
	next_timer = Timer.new()
	next_timer.wait_time = 2.2
	next_timer.one_shot = true
	next_timer.timeout.connect(_next_question)
	add_child(next_timer)

	_update_hud()
	_next_question()


func _next_question() -> void:
	if GameManager.lives <= 0:
		_game_over()
		return

	is_waiting = false
	feedback_label.text = ""
	price_reveal_label.text = ""

	current_product = _get_unused_product()
	current_stores = ProductDatabase.get_random_stores(3, current_product)
	correct_store = ProductDatabase.get_cheapest_store(current_product, current_stores)

	# Ürün kartını yeniden oluştur
	for child in product_card_parent.get_children():
		child.queue_free()
	UIFactory.make_product_card(product_card_parent, current_product, ProductDatabase)

	# Mağaza butonlarını yeniden oluştur
	for child in buttons_parent.get_children():
		child.queue_free()
	store_buttons.clear()

	for i in range(3):
		var store_id: String = current_stores[i]
		var btn := UIFactory.make_store_button(buttons_parent, store_id, ProductDatabase)
		btn.pressed.connect(_on_store_pressed.bind(i))
		store_buttons.append(btn)


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

	for btn in store_buttons:
		btn.disabled = true

	var selected_store: String = current_stores[index]

	# Fiyatları aç
	var reveal := ""
	for i in range(3):
		var sid: String = current_stores[i]
		var price := ProductDatabase.get_price(current_product, sid)
		var emoji := ProductDatabase.get_store_emoji(sid)
		var name := ProductDatabase.get_store_name(sid)
		if sid == correct_store:
			reveal += "✅ %s %s: ₺%.2f\n" % [emoji, name, price]
			store_buttons[i].modulate = Color(0.5, 1.0, 0.5, 1)
		elif sid == selected_store and sid != correct_store:
			reveal += "❌ %s %s: ₺%.2f\n" % [emoji, name, price]
			store_buttons[i].modulate = Color(1.0, 0.4, 0.4, 1)
		else:
			reveal += "    %s %s: ₺%.2f\n" % [emoji, name, price]
			store_buttons[i].modulate = Color(0.5, 0.5, 0.5, 1)

	price_reveal_label.text = reveal.strip_edges()

	if selected_store == correct_store:
		GameManager.add_correct_answer()
		feedback_label.add_theme_color_override("font_color", UIFactory.COLORS.accent_green)
		feedback_label.text = FunMessages.get_correct_message()
		var streak_msg := FunMessages.get_streak_message(GameManager.current_streak)
		if streak_msg != "":
			streak_label.text = streak_msg
	else:
		GameManager.add_wrong_answer()
		feedback_label.add_theme_color_override("font_color", UIFactory.COLORS.accent_red)
		feedback_label.text = FunMessages.get_wrong_message()
		streak_label.text = ""

	_update_hud()
	next_timer.start()


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
