// Not subtype of /mob/living/carbon/human/shadow because of weird parent proc call
/mob/living/carbon/human/shadowling/Initialize(mapload)
	. = ..(mapload, /datum/species/shadow/ling)
