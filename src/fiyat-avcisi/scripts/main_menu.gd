extends Control

@onready var title: Label = %Title if has_node("%Title") else $VBox/Title
@onready var rank_label: Label = $VBox/RankPanel/RankVBox/RankLabel
@onready var xp_bar: ProgressBar = $VBox/RankPanel/RankVBox/XPBar
@onready var xp_label: Label = $VBox/RankPanel/RankVBox/XPLabel
@onready var tip_label: Label = $VBox/TipLabel
@onready var btn_which_store: Button = $VBox/BtnWhichStore
@onready var btn_basket_guess: Button = $VBox/BtnBasketGuess
@onready var btn_price_guess: Button = $VBox/BtnPriceGuess
@onready var high_score_label: Label = $VBox/StatsHBox/HighScore
@onready var games_played_label: Label = $VBox/StatsHBox/GamesPlayed
@onready var accuracy_label: Label = $VBox/StatsHBox/Accuracy


func _ready() -> void:
	btn_which_store.pressed.connect(_on_which_store)
	btn_basket_guess.pressed.connect(_on_basket_guess)
	btn_price_guess.pressed.connect(_on_price_guess)
	_update_ui()
	_animate_title()


func _update_ui() -> void:
	var gm := GameManager
	var rank := gm.get_rank()
	rank_label.text = "🏅 " + rank.title
	xp_bar.value = gm.get_rank_progress() * 100.0
	xp_label.text = "XP: %d / %d" % [gm.total_xp, gm.get_next_rank_xp()]
	tip_label.text = FunMessages.get_random_tip()
	high_score_label.text = "🏆 En Yüksek: %d" % gm.high_score
	games_played_label.text = "🎮 Oyun: %d" % gm.games_played
	accuracy_label.text = "🎯 %%%d" % roundi(gm.get_accuracy())


func _animate_title() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property($VBox/Title, "modulate", Color(1, 0.6, 0, 1), 1.0)
	tween.tween_property($VBox/Title, "modulate", Color(0.2, 0.7, 0.3, 1), 1.0)
	tween.tween_property($VBox/Title, "modulate", Color(0.9, 0.2, 0.3, 1), 1.0)
	tween.tween_property($VBox/Title, "modulate", Color(1, 1, 1, 1), 1.0)


func _on_which_store() -> void:
	get_tree().change_scene_to_file("res://scenes/which_store.tscn")


func _on_basket_guess() -> void:
	get_tree().change_scene_to_file("res://scenes/basket_guess.tscn")


func _on_price_guess() -> void:
	get_tree().change_scene_to_file("res://scenes/price_guess.tscn")
