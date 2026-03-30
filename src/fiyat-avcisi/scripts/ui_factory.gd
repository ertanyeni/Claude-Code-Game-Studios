class_name UIFactory

## Tutarlı ve renkli UI bileşenleri oluşturan fabrika.
## Tüm sahneler bu sınıfı kullanarak bileşen oluşturur.

const COLORS := {
	"bg_dark": Color(0.09, 0.09, 0.14),
	"bg_card": Color(0.14, 0.14, 0.22),
	"bg_card_light": Color(0.18, 0.18, 0.28),
	"accent_orange": Color(1.0, 0.42, 0.21),
	"accent_green": Color(0.3, 0.87, 0.47),
	"accent_red": Color(1.0, 0.33, 0.33),
	"accent_yellow": Color(1.0, 0.84, 0.0),
	"accent_blue": Color(0.35, 0.65, 1.0),
	"accent_purple": Color(0.7, 0.4, 1.0),
	"text_white": Color(0.97, 0.97, 0.97),
	"text_dim": Color(0.6, 0.6, 0.7),
	"text_brand": Color(0.8, 0.7, 0.5),
	"correct_bg": Color(0.1, 0.3, 0.15),
	"wrong_bg": Color(0.35, 0.1, 0.1),
}


static func make_bg(parent: Control) -> ColorRect:
	var bg := ColorRect.new()
	bg.color = COLORS.bg_dark
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	parent.add_child(bg)
	return bg


static func make_vbox(parent: Control, separation: int = 12) -> VBoxContainer:
	var vbox := VBoxContainer.new()
	vbox.set_anchors_preset(Control.PRESET_FULL_RECT)
	vbox.set_offsets_preset(Control.PRESET_FULL_RECT, Control.PRESET_MODE_MINSIZE, 24)
	vbox.add_theme_constant_override("separation", separation)
	parent.add_child(vbox)
	return vbox


static func make_label(parent: Control, text: String, size: int = 20, color: Color = COLORS.text_white, align: HorizontalAlignment = HORIZONTAL_ALIGNMENT_CENTER) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = align
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(label)
	return label


static func make_card(parent: Control, bg_color: Color = COLORS.bg_card) -> PanelContainer:
	var panel := PanelContainer.new()
	var style := StyleBoxFlat.new()
	style.bg_color = bg_color
	style.corner_radius_top_left = 16
	style.corner_radius_top_right = 16
	style.corner_radius_bottom_left = 16
	style.corner_radius_bottom_right = 16
	style.content_margin_left = 20
	style.content_margin_right = 20
	style.content_margin_top = 16
	style.content_margin_bottom = 16
	panel.add_theme_stylebox_override("panel", style)
	panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(panel)
	return panel


static func make_button(parent: Control, text: String, color: Color = COLORS.accent_orange, height: int = 60) -> Button:
	var btn := Button.new()
	btn.text = text
	btn.custom_minimum_size = Vector2(0, height)
	btn.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var normal := StyleBoxFlat.new()
	normal.bg_color = color
	normal.corner_radius_top_left = 14
	normal.corner_radius_top_right = 14
	normal.corner_radius_bottom_left = 14
	normal.corner_radius_bottom_right = 14
	normal.content_margin_left = 16
	normal.content_margin_right = 16
	normal.content_margin_top = 8
	normal.content_margin_bottom = 8
	btn.add_theme_stylebox_override("normal", normal)

	var hover := normal.duplicate()
	hover.bg_color = color.lightened(0.15)
	btn.add_theme_stylebox_override("hover", hover)

	var pressed := normal.duplicate()
	pressed.bg_color = color.darkened(0.2)
	btn.add_theme_stylebox_override("pressed", pressed)

	var disabled := normal.duplicate()
	disabled.bg_color = Color(0.3, 0.3, 0.35)
	btn.add_theme_stylebox_override("disabled", disabled)

	btn.add_theme_font_size_override("font_size", 22)
	btn.add_theme_color_override("font_color", Color.WHITE)
	btn.add_theme_color_override("font_hover_color", Color.WHITE)
	btn.add_theme_color_override("font_pressed_color", Color(0.9, 0.9, 0.9))
	btn.add_theme_color_override("font_disabled_color", Color(0.5, 0.5, 0.5))

	parent.add_child(btn)
	return btn


static func make_store_button(parent: Control, store_id: String, db: Node) -> Button:
	var color: Color = db.get_store_color(store_id)
	var emoji: String = db.get_store_emoji(store_id)
	var name: String = db.get_store_name(store_id)
	var btn := make_button(parent, "%s  %s" % [emoji, name], color, 68)
	return btn


static func make_hbox(parent: Control, separation: int = 12) -> HBoxContainer:
	var hbox := HBoxContainer.new()
	hbox.add_theme_constant_override("separation", separation)
	hbox.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	parent.add_child(hbox)
	return hbox


static func make_spacer(parent: Control, height: int = 12) -> Control:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, height)
	parent.add_child(spacer)
	return spacer


static func make_progress_bar(parent: Control, value: float = 0.0, fg_color: Color = COLORS.accent_orange) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 14)
	bar.value = value
	bar.show_percentage = false
	bar.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var bg_style := StyleBoxFlat.new()
	bg_style.bg_color = Color(0.2, 0.2, 0.25)
	bg_style.corner_radius_top_left = 7
	bg_style.corner_radius_top_right = 7
	bg_style.corner_radius_bottom_left = 7
	bg_style.corner_radius_bottom_right = 7
	bar.add_theme_stylebox_override("background", bg_style)

	var fill_style := StyleBoxFlat.new()
	fill_style.bg_color = fg_color
	fill_style.corner_radius_top_left = 7
	fill_style.corner_radius_top_right = 7
	fill_style.corner_radius_bottom_left = 7
	fill_style.corner_radius_bottom_right = 7
	bar.add_theme_stylebox_override("fill", fill_style)

	parent.add_child(bar)
	return bar


static func make_slider(parent: Control, min_val: float, max_val: float, step: float = 1.0) -> HSlider:
	var slider := HSlider.new()
	slider.min_value = min_val
	slider.max_value = max_val
	slider.step = step
	slider.custom_minimum_size = Vector2(0, 40)
	slider.size_flags_horizontal = Control.SIZE_EXPAND_FILL

	var grabber_style := StyleBoxFlat.new()
	grabber_style.bg_color = COLORS.accent_orange
	grabber_style.corner_radius_top_left = 16
	grabber_style.corner_radius_top_right = 16
	grabber_style.corner_radius_bottom_left = 16
	grabber_style.corner_radius_bottom_right = 16
	grabber_style.content_margin_left = 16
	grabber_style.content_margin_right = 16
	grabber_style.content_margin_top = 16
	grabber_style.content_margin_bottom = 16

	parent.add_child(slider)
	return slider


static func make_product_card(parent: Control, product: Dictionary, db: Node, show_price: bool = false, store_id: String = "") -> PanelContainer:
	var card := make_card(parent, COLORS.bg_card_light)

	var vbox := VBoxContainer.new()
	vbox.add_theme_constant_override("separation", 6)
	card.add_child(vbox)

	# Kategori + emoji
	var cat_name: String = product.get("category", "")
	var cat_emoji: String = db.get_category_emoji(cat_name)
	make_label(vbox, cat_emoji + " " + cat_name, 14, COLORS.text_dim)

	# Ürün ismi (büyük)
	var icon_key: String = product.get("icon", "")
	var icon_str: String = get_product_icon(icon_key)
	make_label(vbox, icon_str, 48)

	# Marka
	var brand: String = product.get("brand", "")
	if brand != "":
		make_label(vbox, brand, 16, COLORS.text_brand)

	# İsim
	make_label(vbox, product.get("name", "???"), 22, COLORS.text_white)

	# Detay satırı: gramaj + açıklama
	var weight: String = product.get("weight", "")
	var desc: String = product.get("description", "")
	if weight != "" or desc != "":
		var detail_text := ""
		if weight != "":
			detail_text += "📦 " + weight
		if desc != "":
			if detail_text != "":
				detail_text += "  •  "
			detail_text += desc
		make_label(vbox, detail_text, 14, COLORS.text_dim)

	# Fiyat (opsiyonel)
	if show_price and store_id != "":
		var price: float = db.get_price(product, store_id)
		make_label(vbox, "₺%.2f" % price, 28, COLORS.accent_yellow)

	return card


static func get_product_icon(icon_key: String) -> String:
	var icons := {
		"milk": "🥛", "bread": "🍞", "egg": "🥚", "cheese": "🧀",
		"olive": "🫒", "tea": "🍵", "sugar": "🍬", "flour": "🌾",
		"oil": "🫗", "pasta": "🍝", "rice": "🍚", "chicken": "🍗",
		"tomato": "🍅", "potato": "🥔", "banana": "🍌", "detergent": "🧴",
		"paper": "🧻", "diaper": "👶", "cola": "🥤", "coffee": "☕",
		"chocolate": "🍫", "chips": "🥨", "shampoo": "🧴", "toothpaste": "🪥",
		"yogurt": "🥛", "butter": "🧈", "chickpea": "🫘", "lentil": "🫘",
		"paste": "🥫", "honey": "🍯", "water": "💧",
	}
	return icons.get(icon_key, "📦")
