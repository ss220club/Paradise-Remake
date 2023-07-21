/mob/proc/combine_message_tts(list/message_pieces, mob/speaker, always_stars = FALSE)
	var/iteration_count = 0
	var/msg = ""
	for(var/datum/multilingual_say_piece/SP in message_pieces)
		iteration_count++
		var/piece = SP.message
		if(piece == "")
			continue

		if(SP.speaking?.flags & INNATE) // TTS should not read emotes like "laughts"
			return ""

		if(iteration_count == 1)
			piece = capitalize(piece)

		if(always_stars)
			continue
		if(!say_understands(speaker, SP.speaking))
			if(isanimal(speaker))
				var/mob/living/simple_animal/S = speaker
				if(LAZYLEN(S.speak))
					piece = pick(S.speak)
				else
					continue
			else if(SP.speaking)
				piece = SP.speaking.scramble(piece)
			else
				continue
		msg += (piece + " ")
	return trim(msg)


/mob/hear_say(list/message_pieces, verb, italics, mob/speaker, sound/speech_sound, sound_vol, sound_frequency, use_voice)
	. = ..()
	if(!can_hear())
		return

	var/message_tts = combine_message_tts(message_pieces, speaker)
	var/effect = SOUND_EFFECT_NONE
	if(isrobot(speaker))
		effect = SOUND_EFFECT_ROBOT
	var/traits = TTS_TRAIT_RATE_FASTER
	var/is_whisper = verb == "whispers"
	if(is_whisper)
		traits |= TTS_TRAIT_PITCH_WHISPER
	INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, speaker, src, message_tts, speaker.tts_seed, TRUE, effect, traits)

/mob/hear_radio(list/message_pieces, verb, part_a, part_b, mob/speaker, hard_to_hear, vname, atom/follow_target, radio_freq)
	. = ..()
	if(!can_hear())
		return

	if(src != speaker || isrobot(src) || isAI(src))
		var/effect = SOUND_EFFECT_RADIO
		var/message_tts = combine_message_tts(message_pieces, speaker, always_stars = hard_to_hear)
		if(isrobot(speaker))
			effect = SOUND_EFFECT_RADIO_ROBOT
		INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, src, src, message_tts, speaker.tts_seed, FALSE, effect, null, null, 'sound/effects/radio_chatter.ogg')

/mob/hear_holopad_talk(list/message_pieces, verb, mob/speaker, obj/effect/overlay/holo_pad_hologram/H)
	. = ..()
	if(!can_hear())
		return
	var/message_tts = combine_message_tts(message_pieces, speaker)
	var/effect = SOUND_EFFECT_RADIO
	if(isrobot(speaker))
		effect = SOUND_EFFECT_RADIO_ROBOT
	INVOKE_ASYNC(GLOBAL_PROC, /proc/tts_cast, H, src, message_tts, speaker.tts_seed, TRUE, effect)
