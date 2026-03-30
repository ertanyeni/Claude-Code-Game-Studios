extends Control

## Ana menü — renkli, eğlenceli, tüm istatistikler görünür.

var rank_label: Label
var xp_bar: ProgressBar
var xp_label: Label
var tip_label: Label
var high_score_label: Label
var games_label: Label
var accuracy_label: Label


func _ready() -> void:
	UIFactory.make_bg(self)
	var vbox := UIFactory.make_vbox(self, 14)

	# Başlık
	UIFactory.make_label(vbox, "🛒  FİYAT AVCISI", 36, UIFactory.COLORS.accent_orange)
	UIFactory.make_label(vbox, "Marketten markete, kuruşu kuruşuna!", 16, UIFactory.COLORS.text_dim)

	UIFactory.make_spacer(vbox, 8)

	# Rütbe kartı
	var rank_card := UIFactory.make_card(vbox, Color(0.12, 0.15, 0.25))
	var rank_vbox := VBoxContainer.new()
	rank_vbox.add_theme_constant_override("separation", 8)
	rank_card.add_child(rank_vbox)

	rank_label = UIFactory.make_label(rank_vbox, "", 24, UIFactory.COLORS.accent_yellow)
	xp_bar = UIFactory.make_progress_bar(rank_vbox, 0, UIFactory.COLORS.accent_orange)
	xp_label = UIFactory.make_label(rank_vbox, "", 14, UIFactory.COLORS.text_dim)

	# İstatistik satırı
	var stats_hbox := UIFactory.make_hbox(vbox, 8)
	var s1 := UIFactory.make_card(stats_hbox, Color(0.15, 0.12, 0.2))
	s1.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	high_score_label = UIFactory.make_label(s1, "", 16, UIFactory.COLORS.accent_yellow)

	var s2 := UIFactory.make_card(stats_hbox, Color(0.12, 0.15, 0.15))
	s2.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	games_label = UIFactory.make_label(s2, "", 16, UIFactory.COLORS.accent_green)

	var s3 := UIFactory.make_card(stats_hbox, Color(0.15, 0.12, 0.15))
	s3.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	accuracy_label = UIFactory.make_label(s3, "", 16, UIFactory.COLORS.accent_blue)

	UIFactory.make_spacer(vbox, 4)

	# İpucu
	var tip_card := UIFactory.make_card(vbox, Color(0.1, 0.12, 0.18))
	tip_label = UIFactory.make_label(tip_card, "", 15, UIFactory.COLORS.text_dim)

	UIFactory.make_spacer(vbox, 8)

	# Oyun modu butonları
	var btn1 := UIFactory.make_button(vbox, "🏪  Hangi Mağaza?", UIFactory.COLORS.accent_orange, 68)
	UIFactory.make_label(vbox, "En ucuz mağazayı bul!", 13, UIFactory.COLORS.text_dim)

	UIFactory.make_spacer(vbox, 4)

	var btn2 := UIFactory.make_button(vbox, "🧺  Sepet Tahmini", UIFactory.COLORS.accent_green, 68)
	UIFactory.make_label(vbox, "Sepet tutarını tahmin et!", 13, UIFactory.COLORS.text_dim)

	UIFactory.make_spacer(vbox, 4)

	var btn3 := UIFactory.make_button(vbox, "🎯  Fiyat Bilmece", UIFactory.COLORS.accent_purple, 68)
	UIFactory.make_label(vbox, "Ürünün fiyatını bil!", 13, UIFactory.COLORS.text_dim)

	btn1.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/which_store.tscn"))
	btn2.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/basket_guess.tscn"))
	btn3.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/price_guess.tscn"))

	_update_ui()
	_animate_title(vbox.get_child(0))


func _update_ui() -> void:
	var gm := GameManager
	var rank := gm.get_rank()
	rank_label.text = "🏅 " + rank.title
	xp_bar.value = gm.get_rank_progress() * 100.0
	xp_label.text = "XP: %d / %d" % [gm.total_xp, gm.get_next_rank_xp()]
	tip_label.text = FunMessages.get_random_tip()
	high_score_label.text = "🏆 %d" % gm.high_score
	games_label.text = "🎮 %d" % gm.games_played
	accuracy_label.text = "🎯 %%%d" % roundi(gm.get_accuracy())


func _animate_title(title_node: Label) -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(title_node, "modulate", Color(1, 0.5, 0.15, 1), 1.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(title_node, "modulate", Color(1.0, 0.84, 0.0, 1), 1.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(title_node, "modulate", Color(0.3, 0.87, 0.47, 1), 1.5).set_trans(Tween.TRANS_SINE)
	tween.tween_property(title_node, "modulate", Color(1, 0.5, 0.15, 1), 1.5).set_trans(Tween.TRANS_SINE)
