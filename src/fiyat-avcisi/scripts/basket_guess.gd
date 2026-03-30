extends Control

## "Sepet Tahmini" oyun modu — programatik UI.

const BASKET_SIZE := 6

var round_label: Label
var score_label: Label
var store_info_label: Label
var basket_list_label: Label
var feedback_label: Label
var guess_label: Label
var product_card_parent: VBoxContainer
var add_btn: Button
var guess_section: VBoxContainer
var result_section: VBoxContainer
var result_text: Label
var guess_slider: HSlider

var basket_products: Array[Dictionary] = []
var current_product: Dictionary
var selected_store: String
var product_queue: Array[Dictionary] = []
var basket_total := 0.0


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

	round_label = UIFactory.make_label(top, "🧺 Sepet: 0/6", 18, UIFactory.COLORS.text_white)
	round_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	score_label = UIFactory.make_label(top, "⭐ 0", 18, UIFactory.COLORS.accent_yellow)

	# Mağaza bilgisi
	store_info_label = UIFactory.make_label(vbox, "", 16, UIFactory.COLORS.accent_blue)

	# Ürün kartı alanı
	product_card_parent = VBoxContainer.new()
	product_card_parent.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(product_card_parent)

	# Sepete ekle butonu
	add_btn = UIFactory.make_button(vbox, "🛒  Sepete At!", UIFactory.COLORS.accent_green, 56)
	add_btn.pressed.connect(_on_add_to_basket)

	# Sepet listesi
	var basket_card := UIFactory.make_card(vbox, Color(0.1, 0.12, 0.18))
	basket_list_label = UIFactory.make_label(basket_card, "Sepet boş... Doldur bakalım! 🛒", 15, UIFactory.COLORS.text_dim)

	# Tahmin bölümü (gizli)
	guess_section = VBoxContainer.new()
	guess_section.add_theme_constant_override("separation", 12)
	guess_section.visible = false
	guess_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(guess_section)

	UIFactory.make_label(guess_section, "💰 Bu sepetin tutarı ne kadar?", 20, UIFactory.COLORS.accent_yellow)
	guess_label = UIFactory.make_label(guess_section, "₺ 150.00", 32, UIFactory.COLORS.text_white)
	guess_slider = UIFactory.make_slider(guess_section, 10, 2000, 5)
	guess_slider.value_changed.connect(func(v: float): guess_label.text = "₺ %.2f" % v)

	var submit_btn := UIFactory.make_button(guess_section, "🎯  Tahminimi Gönder!", UIFactory.COLORS.accent_orange, 56)
	submit_btn.pressed.connect(_on_submit_guess)

	# Sonuç bölümü (gizli)
	result_section = VBoxContainer.new()
	result_section.add_theme_constant_override("separation", 10)
	result_section.visible = false
	result_section.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vbox.add_child(result_section)

	result_text = UIFactory.make_label(result_section, "", 18, UIFactory.COLORS.text_white)
	var cont_btn := UIFactory.make_button(result_section, "🔄  Yeni Sepet!", UIFactory.COLORS.accent_blue, 56)
	cont_btn.pressed.connect(_start_new_round)

	# Feedback
	feedback_label = UIFactory.make_label(vbox, "", 16, UIFactory.COLORS.accent_green)

	_start_new_round()


func _start_new_round() -> void:
	basket_products.clear()
	basket_total = 0.0
	feedback_label.text = ""
	result_section.visible = false
	guess_section.visible = false
	product_card_parent.visible = true
	add_btn.visible = true

	var store_ids := ProductDatabase.stores.keys()
	selected_store = store_ids[randi() % store_ids.size()]
	var name := ProductDatabase.get_store_name(selected_store)
	var emoji := ProductDatabase.get_store_emoji(selected_store)
	var joke := FunMessages.get_store_joke(selected_store)
	store_info_label.text = "%s %s'ta alışverişteyiz!\n%s" % [emoji, name, joke]

	product_queue = ProductDatabase.get_random_products(BASKET_SIZE)
	_show_next_product()
	_update_basket_display()


func _show_next_product() -> void:
	if product_queue.is_empty():
		_show_guess_phase()
		return

	current_product = product_queue.pop_front()
	round_label.text = "🧺 Sepet: %d/%d" % [basket_products.size(), BASKET_SIZE]

	for child in product_card_parent.get_children():
		child.queue_free()
	UIFactory.make_product_card(product_card_parent, current_product, ProductDatabase)

	var texts := ["🛒 Sepete At!", "🛒 Bunu da Alalım!", "🛒 Hop Sepete!", "🛒 Bu Lazım!"]
	add_btn.text = texts[randi() % texts.size()]


func _on_add_to_basket() -> void:
	var price := ProductDatabase.get_price(current_product, selected_store)
	basket_total += price
	basket_products.append(current_product)
	_update_basket_display()
	_show_next_product()


func _update_basket_display() -> void:
	if basket_products.is_empty():
		basket_list_label.text = "Sepet boş... Doldur bakalım! 🛒"
		return
	var text := "📋 Sepetindekiler:\n"
	for p in basket_products:
		var icon := UIFactory.get_product_icon(p.get("icon", ""))
		var brand: String = p.get("brand", "")
		text += "%s %s (%s)\n" % [icon, p.get("name", ""), brand]
	basket_list_label.text = text.strip_edges()


func _show_guess_phase() -> void:
	product_card_parent.visible = false
	add_btn.visible = false
	guess_section.visible = true
	round_label.text = "🧺 Sepet dolu! Tahmin zamanı!"

	var min_g := maxf(10.0, basket_total * 0.4)
	var max_g := basket_total * 1.8
	guess_slider.min_value = snappedi(int(min_g), 5)
	guess_slider.max_value = snappedi(int(max_g), 5)
	guess_slider.value = snappedi(int((min_g + max_g) / 2.0), 5)
	guess_label.text = "₺ %.2f" % guess_slider.value


func _on_submit_guess() -> void:
	var guess: float = guess_slider.value
	var diff := absf(guess - basket_total)
	var pct := (diff / basket_total) * 100.0
	var xp := GameManager.add_guess_score(pct)

	var r := "🧾 Gerçek Tutar: ₺%.2f\n" % basket_total
	r += "🎯 Senin Tahmin: ₺%.2f\n" % guess
	r += "📏 Fark: ₺%.2f (%%%.1f)\n\n" % [diff, pct]
	r += FunMessages.get_basket_message(pct)
	r += "\n\n+%d XP kazandın!" % xp

	result_text.text = r
	guess_section.visible = false
	result_section.visible = true
	score_label.text = "⭐ %d" % GameManager.current_score


func _on_back() -> void:
	GameManager.end_game()
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
