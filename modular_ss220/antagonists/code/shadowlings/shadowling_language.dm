/datum/language/shadowling
	name = "Шёпот из тени"
	desc = "В тени всегда есть те, кто слышит все ваши секреты. Шадоулинги используют рэдспейс для связи между собой."
	speech_verb = "says"
	colour = "purple"
	key = "sl"
	flags = RESTRICTED | HIVEMIND | NOBABEL
	follow = TRUE

/datum/language/shadowling/get_random_name()
	var/new_name
	if(prob(0.1))
		new_name = "Лучик Доброты" // :)
	else
		// Edgelord names ahead
		new_name += "[pick("Владыка", "Поработитель", "Повелитель", "Мучитель", "Пожиратель", "Угнетатель", "Судья", "Убийца", "Уничтожитель", "Тиран")]"
		new_name += " [pick("Тьмы", "Тени", "Темноты", "Ужаса", "Страха", "Ненависти", "Зависти", "Злости", "Греха", "Мрака", "Боли", "Кары")]"
	return new_name
