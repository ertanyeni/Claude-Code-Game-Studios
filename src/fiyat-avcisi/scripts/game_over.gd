extends Control

@onready var fun_message: Label = $VBox/FunMessage
@onready var score_label: Label = $VBox/ScorePanel/ScoreVBox/ScoreLabel
@onready var high_score_label: Label = $VBox/ScorePanel/ScoreVBox/HighScoreLabel
@onready var streak_label: Label = $VBox/ScorePanel/ScoreVBox/StreakLabel
@onready var rank_label: Label = $VBox/ScorePanel/ScoreVBox/RankLabel
@onready var xp_bar: ProgressBar = $VBox/ScorePanel/ScoreVBox/XPBar
@onready var xp_label: Label = $VBox/ScorePanel/ScoreVBox/XPLabel
@onready var share_label: Label = $VBox/ShareLabel
@onready var play_again_btn: Button = $VBox/PlayAgainBtn
@onready var menu_btn: Button = $VBox/MenuBtn


func _ready() -> void:
	play_again_btn.pressed.connect(_on_play_again)
	menu_btn.pressed.connect(_on_menu)
	_update_ui()


func _update_ui() -> void:
	var gm := GameManager
	var score := gm.current_score
	var rank := gm.get_rank()

	fun_message.text = FunMessages.get_game_over_message(score)
	score_label.text = "⭐ Skor: %d" % score
	high_score_label.text = "🏆 En Yüksek: %d" % gm.high_score
	streak_label.text = "🔥 En İyi Seri: %d" % gm.best_streak
	rank_label.text = "🏅 Rütbe: %s" % rank.title
	xp_bar.value = gm.get_rank_progress() * 100.0
	xp_label.text = "XP: %d / %d" % [gm.total_xp, gm.get_next_rank_xp()]

	# Paylaşım metni
	var share_texts := [
		"📱 Fiyat Avcısı'nda %d puan yaptım!\n%s seviyesine ulaştım! 🛒\nSen yapabilir misin?" % [score, rank.title],
		"🛒 %d puanla %s oldum!\nMarket fiyatlarını benden iyi bilen var mı? 😎" % [score, rank.title],
		"💰 Fiyat Avcısı skorum: %d\nRütbem: %s\nBeni geçebilecek cesur var mı? 🏆" % [score, rank.title],
	]
	share_label.text = share_texts[randi() % share_texts.size()]

	# Animasyon
	var tween := create_tween()
	tween.tween_property($VBox/GameOverTitle, "scale", Vector2(1.1, 1.1), 0.5).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property($VBox/GameOverTitle, "scale", Vector2(1.0, 1.0), 0.3)


func _on_play_again() -> void:
	get_tree().change_scene_to_file("res://scenes/which_store.tscn")


func _on_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
