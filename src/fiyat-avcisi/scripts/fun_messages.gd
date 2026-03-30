class_name FunMessages

## Oyundaki tüm eğlenceli mesajlar, şakalar ve komik tepkiler.

# --- Doğru cevap tepkileri ---
const CORRECT_MESSAGES := [
	"Teyze radar gibi çalışıyor! 📡",
	"Sen mi market, market mi sen?",
	"Enflasyon seni yenemez! 💪",
	"Bu bilgiyle bakkala bile danışmanlık verirsin!",
	"Anne kart bilgilerini hissettin değil mi?",
	"Fiyat hafızası: EFSANE! 🧠",
	"Kasiyerler senden korkuyor!",
	"Sen olsan Merkez Bankası başkanı olurdun!",
	"Kuruşuna kadar bilen adam/kadın!",
	"Market reyonlarının Neo'su! 🕶️",
	"Poşet bile sana indirim yapar!",
	"Hesap makinesine gerek yok, sen varsın!",
	"Bu kafayla emeklilikte köşeyi dönersin! 🏖️",
	"Fiyat etiketleri seni görünce titriyor!",
	"Etiket okuma olimpiyatlarında altın madalya! 🥇",
]

# --- Yanlış cevap tepkileri ---
const WRONG_MESSAGES := [
	"Aaaa! Teyze şaşırdı! 😱",
	"Bu fiyata o marketten olmaz be dayı!",
	"Enflasyon kafanı karıştırmış! 🌀",
	"Cüzdan ağladı şu an! 💸",
	"Sana market yasağı geliyor!",
	"Kasada sürpriz yaşanırdı! 😅",
	"Bu tahmini poşete koyup çöpe at!",
	"Etiket okuma dersi: KALDIN!",
	"Fiyatlar uçmuş, sen kaçırmışsın! ✈️",
	"Bakkala bile giremezsin bu bilgiyle!",
	"Enflasyon 1 - Sen 0 😢",
	"Kredi kartın rahatlama nefesi aldı!",
	"Market alışverişine anneni çağır bence!",
	"Bu hesapla ancak hayal marketten alışveriş!",
]

# --- Streak mesajları ---
const STREAK_MESSAGES := {
	3: "🔥 3'lü kombo! Isınıyorsun!",
	5: "🔥🔥 5x Streak! Alışveriş Teyzesi moduna geçtin!",
	7: "🔥🔥🔥 7 art arda! Market müdürü seni izliyor!",
	10: "💎 10x MEGA STREAK! Efsane seviyesi!",
	15: "👑 15x! Sen insanlığın fiyat hafızasısın!",
	20: "🏆 20x TANRISAL STREAK! Enflasyon karşında diz çöktü!",
}

# --- Sepet tahmini tepkileri ---
const BASKET_PERFECT := [  # ±%3
	"SEN ROBOT MUSUN?! 🤖",
	"Kasiyerlere iş bırakmıyorsun!",
	"Bu kafayla muhasebeci ol direkt!",
	"Kuruşu kuruşuna! EFSANE! 💯",
]

const BASKET_CLOSE := [  # ±%10
	"Fena değil teyze, fena değil! 👏",
	"Az kalsın tutturuyordun!",
	"Bu kadar yakın tahmin = doğuştan yetenek!",
	"Yakın ama puro yok! 🎯",
]

const BASKET_OK := [  # ±%20
	"Hmm, idare eder ama çalış biraz! 📚",
	"Daha çok markete git bence 😄",
	"Ortalama bir alışverişçisin, gelişme var!",
	"Market tecrüben biraz paslı!",
]

const BASKET_FAR := [  # >%20
	"AJSKDJASK bu fiyat mı?! 🤣",
	"Sen en son ne zaman markete girdin?",
	"Bu tahminle ancak 2019'da alışveriş yaparsın!",
	"Enflasyonu duymamışsın galiba! 📰",
	"Mars'taki market fiyatlarını mı biliyorsun?",
]

# --- Oyun sonu mesajları ---
const GAME_OVER_GOOD := [
	"Helal olsun! Market diplomanı hak ettin! 🎓",
	"Bu skorla teyzelerin WhatsApp grubuna alınırsın!",
	"Süpersin! Ama hâlâ poşet parası var unutma! 😄",
]

const GAME_OVER_OK := [
	"Fena değil ama indirim günlerini kaçırıyorsun!",
	"İdare eder, bir dahakine broşürleri oku!",
	"Gelişme var! Haftalık insert'lere göz at! 📰",
]

const GAME_OVER_BAD := [
	"Hmm... Online siparişe geç bence 📱",
	"Market yerine uzay istasyonunda mı yaşıyorsun?",
	"Anneye sor, o bilir fiyatları! 👩‍🦳",
]

# --- Ana menü ipuçları ---
const TIPS := [
	"💡 Biliyor muydun? Türkiye'de en çok tüketilen sebze domatesmiş!",
	"💡 İpucu: İndirim marketleri genelde en ucuz, ama her zaman değil!",
	"💡 Annelerin %94'ü market fiyatlarını ezbere bilir! (Kaynak: Biz uydurduk)",
	"💡 Ortalama bir Türk ayda 47 kez markete gider! (Tahmini)",
	"💡 Çay fiyatını bilmiyorsan Türk sayılmazsın! ☕",
	"💡 En pahalı market = en iyi market değildir!",
	"💡 Poşet ücreti ilk çıktığında herkes çanta taşımaya başladı 🛍️",
	"💡 3 farklı marketi gezen teyze, GPS'ten daha iyi yol bilir!",
]

# --- Mağaza şakaları ---
const STORE_JOKES := {
	"B101": "B101: Gittiğinde 3 şey alacaktın, 30 şeyle çıkarsın!",
	"DİM": "DİM: Mavi poşet taşıyan herkes kahramandır! 🦸",
	"BAM": "BAM: Girişte indirim tabelası, çıkışta boş cüzdan!",
	"Makros": "Makros: Sadece ekmek almaya gidip 500₺ bıraktığın yer!",
	"Trendiol": "Trendiol: Gece 3'te sipariş veren parmaklar bilir!",
	"Hepsimarka": "Hepsimarka: 'Sadece bakıyorum' deyip sepeti dolduran sensin!",
}


static func get_correct_message() -> String:
	return CORRECT_MESSAGES[randi() % CORRECT_MESSAGES.size()]


static func get_wrong_message() -> String:
	return WRONG_MESSAGES[randi() % WRONG_MESSAGES.size()]


static func get_streak_message(streak: int) -> String:
	if STREAK_MESSAGES.has(streak):
		return STREAK_MESSAGES[streak]
	if streak > 20:
		return "👑 %dx STREAK! İNSANÜSTÜ!" % streak
	return ""


static func get_basket_message(accuracy_percent: float) -> String:
	if accuracy_percent <= 3.0:
		return BASKET_PERFECT[randi() % BASKET_PERFECT.size()]
	elif accuracy_percent <= 10.0:
		return BASKET_CLOSE[randi() % BASKET_CLOSE.size()]
	elif accuracy_percent <= 20.0:
		return BASKET_OK[randi() % BASKET_OK.size()]
	else:
		return BASKET_FAR[randi() % BASKET_FAR.size()]


static func get_game_over_message(score: int) -> String:
	if score >= 200:
		return GAME_OVER_GOOD[randi() % GAME_OVER_GOOD.size()]
	elif score >= 80:
		return GAME_OVER_OK[randi() % GAME_OVER_OK.size()]
	else:
		return GAME_OVER_BAD[randi() % GAME_OVER_BAD.size()]


static func get_random_tip() -> String:
	return TIPS[randi() % TIPS.size()]


static func get_store_joke(store_id: String) -> String:
	return STORE_JOKES.get(store_id, "Bu marketi herkes bilir!")
