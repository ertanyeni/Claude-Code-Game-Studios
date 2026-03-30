extends Node

## Oyun genelindeki durum ve ilerleme yönetimi.
## Autoload olarak yüklenir.

signal xp_changed(new_xp: int, new_level: int)
signal lives_changed(new_lives: int)
signal streak_changed(new_streak: int)

const SAVE_PATH := "user://save_data.json"

# Oyuncu verileri
var player_name: String = "Oyuncu"
var total_xp: int = 0
var high_score: int = 0
var current_score: int = 0
var current_streak: int = 0
var best_streak: int = 0
var lives: int = 3
var games_played: int = 0
var correct_answers: int = 0
var total_answers: int = 0

# Rozetler
var badges: Array[String] = []

# Rütbe tablosu
const RANKS := [
	{"min_xp": 0, "title": "Çaylak Müşteri", "icon": "beginner"},
	{"min_xp": 500, "title": "Market Gezgini", "icon": "explorer"},
	{"min_xp": 2000, "title": "Alışveriş Teyzesi", "icon": "auntie"},
	{"min_xp": 5000, "title": "Pazarcı Dayı", "icon": "uncle"},
	{"min_xp": 10000, "title": "Fiyat Dedektifi", "icon": "detective"},
	{"min_xp": 25000, "title": "Enflasyon Ustası", "icon": "master"},
]

# XP ödülleri
const XP_CORRECT := 10
const XP_STREAK_BONUS := 5
const XP_PERFECT_GUESS := 50
const XP_CLOSE_GUESS := 25
const XP_OK_GUESS := 10


func _ready() -> void:
	load_game()


func get_rank() -> Dictionary:
	var current_rank := RANKS[0]
	for rank in RANKS:
		if total_xp >= rank.min_xp:
			current_rank = rank
	return current_rank


func get_level() -> int:
	var rank_index := 0
	for i in range(RANKS.size()):
		if total_xp >= RANKS[i].min_xp:
			rank_index = i
	return rank_index + 1


func get_next_rank_xp() -> int:
	var current_level := get_level()
	if current_level >= RANKS.size():
		return RANKS[-1].min_xp
	return RANKS[current_level].min_xp


func get_rank_progress() -> float:
	var current_level := get_level()
	if current_level >= RANKS.size():
		return 1.0
	var current_min: int = RANKS[current_level - 1].min_xp
	var next_min: int = RANKS[current_level].min_xp
	var range_size := next_min - current_min
	if range_size <= 0:
		return 1.0
	return float(total_xp - current_min) / float(range_size)


func add_xp(amount: int) -> void:
	var old_level := get_level()
	total_xp += amount
	var new_level := get_level()
	xp_changed.emit(total_xp, new_level)
	if new_level > old_level:
		# Seviye atladı
		pass


func add_correct_answer() -> void:
	correct_answers += 1
	total_answers += 1
	current_streak += 1
	if current_streak > best_streak:
		best_streak = current_streak
	streak_changed.emit(current_streak)

	var xp := XP_CORRECT + (current_streak * XP_STREAK_BONUS)
	add_xp(xp)
	current_score += xp

	_check_badges()


func add_wrong_answer() -> void:
	total_answers += 1
	current_streak = 0
	lives -= 1
	streak_changed.emit(current_streak)
	lives_changed.emit(lives)


func add_guess_score(accuracy_percent: float) -> int:
	total_answers += 1
	var xp := 0
	if accuracy_percent <= 3.0:
		xp = XP_PERFECT_GUESS
	elif accuracy_percent <= 10.0:
		xp = XP_CLOSE_GUESS
	elif accuracy_percent <= 20.0:
		xp = XP_OK_GUESS
	else:
		xp = 5

	add_xp(xp)
	current_score += xp
	return xp


func start_new_game() -> void:
	current_score = 0
	current_streak = 0
	lives = 3
	lives_changed.emit(lives)
	streak_changed.emit(current_streak)


func end_game() -> void:
	games_played += 1
	if current_score > high_score:
		high_score = current_score
	save_game()


func get_accuracy() -> float:
	if total_answers == 0:
		return 0.0
	return float(correct_answers) / float(total_answers) * 100.0


func _check_badges() -> void:
	if current_streak >= 5 and not badges.has("streak_5"):
		badges.append("streak_5")
	if current_streak >= 10 and not badges.has("streak_10"):
		badges.append("streak_10")
	if correct_answers >= 50 and not badges.has("answers_50"):
		badges.append("answers_50")
	if correct_answers >= 100 and not badges.has("answers_100"):
		badges.append("answers_100")


func save_game() -> void:
	var data := {
		"player_name": player_name,
		"total_xp": total_xp,
		"high_score": high_score,
		"games_played": games_played,
		"correct_answers": correct_answers,
		"total_answers": total_answers,
		"best_streak": best_streak,
		"badges": badges,
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		return
	var json := JSON.new()
	if json.parse(file.get_as_text()) != OK:
		return
	var data: Dictionary = json.data
	player_name = data.get("player_name", "Oyuncu")
	total_xp = data.get("total_xp", 0)
	high_score = data.get("high_score", 0)
	games_played = data.get("games_played", 0)
	correct_answers = data.get("correct_answers", 0)
	total_answers = data.get("total_answers", 0)
	best_streak = data.get("best_streak", 0)
	var loaded_badges: Array = data.get("badges", [])
	badges.clear()
	for b in loaded_badges:
		badges.append(str(b))
