extends Control

## Oyun sonu ekranı — programatik UI.


func _ready() -> void:
	UIFactory.make_bg(self)
	var vbox := UIFactory.make_vbox(self, 16)

	UIFactory.make_spacer(vbox, 20)

	# Başlık
	var title := UIFactory.make_label(vbox, "🛒  Oyun Bitti!", 34, UIFactory.COLORS.accent_orange)

	# Komik mesaj
	UIFactory.make_label(vbox, FunMessages.get_game_over_message(GameManager.current_score), 20, UIFactory.COLORS.accent_yellow)

	UIFactory.make_spacer(vbox, 8)

	# Skor kartı
	var card := UIFactory.make_card(vbox, Color(0.12, 0.14, 0.25))
	var cvbox := VBoxContainer.new()
	cvbox.add_theme_constant_override("separation", 12)
	card.add_child(cvbox)

	UIFactory.make_label(cvbox, "⭐  Skor: %d" % GameManager.current_score, 28, UIFactory.COLORS.accent_yellow)
	UIFactory.make_label(cvbox, "🏆  En Yüksek: %d" % GameManager.high_score, 20, UIFactory.COLORS.text_white)
	UIFactory.make_label(cvbox, "🔥  En İyi Seri: %d" % GameManager.best_streak, 20, UIFactory.COLORS.accent_orange)

	# Rütbe
	var rank := GameManager.get_rank()
	UIFactory.make_spacer(cvbox, 4)
	UIFactory.make_label(cvbox, "🏅  Rütbe: %s" % rank.title, 22, UIFactory.COLORS.accent_purple)
	UIFactory.make_progress_bar(cvbox, GameManager.get_rank_progress() * 100.0, UIFactory.COLORS.accent_purple)
	UIFactory.make_label(cvbox, "XP: %d / %d" % [GameManager.total_xp, GameManager.get_next_rank_xp()], 14, UIFactory.COLORS.text_dim)

	UIFactory.make_spacer(vbox, 8)

	# Paylaşım
	var share_card := UIFactory.make_card(vbox, Color(0.1, 0.12, 0.18))
	var shares := [
		"📱 Fiyat Avcısı'nda %d puan yaptım!\n%s seviyesine ulaştım! 🛒" % [GameManager.current_score, rank.title],
		"💰 %d puanla %s oldum!\nBeni geçebilecek var mı? 😎" % [GameManager.current_score, rank.title],
	]
	UIFactory.make_label(share_card, shares[randi() % shares.size()], 15, UIFactory.COLORS.text_dim)

	UIFactory.make_spacer(vbox, 12)

	# Butonlar
	var btn1 := UIFactory.make_button(vbox, "🔄  Tekrar Oyna!", UIFactory.COLORS.accent_green, 64)
	var btn2 := UIFactory.make_button(vbox, "🏠  Ana Menü", UIFactory.COLORS.accent_blue, 56)

	btn1.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/which_store.tscn"))
	btn2.pressed.connect(func(): get_tree().change_scene_to_file("res://scenes/main_menu.tscn"))

	# Başlık animasyonu
	var tween := create_tween()
	tween.tween_property(title, "scale", Vector2(1.05, 1.05), 0.6).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(title, "scale", Vector2(1.0, 1.0), 0.4)
