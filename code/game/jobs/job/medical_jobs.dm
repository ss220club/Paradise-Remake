/datum/job/cmo
	title = "Chief Medical Officer"
	flag = JOB_CMO
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_COMMAND | DEP_FLAG_MEDICAL
	supervisors = "капитаном"
	department_head = list("Captain")
	selection_color = "#ffddf0"
	req_admin_notify = 1
	department_account_access = TRUE
	access = list(
		ACCESS_CHEMISTRY,
		ACCESS_CMO,
		ACCESS_EVA,
		ACCESS_GENETICS,
		ACCESS_HEADS,
		ACCESS_KEYCARD_AUTH,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MORGUE,
		ACCESS_PARAMEDIC,
		ACCESS_PSYCHIATRIST,
		ACCESS_RC_ANNOUNCE,
		ACCESS_SEC_DOORS,
		ACCESS_SURGERY,
		ACCESS_VIROLOGY,
		ACCESS_WEAPONS
	)
	minimal_player_age = 21
	exp_map = list(EXP_TYPE_MEDICAL = 1200)
	blacklisted_disabilities = list(DISABILITY_FLAG_BLIND, DISABILITY_FLAG_DEAF, DISABILITY_FLAG_MUTE, DISABILITY_FLAG_DIZZY)
	outfit = /datum/outfit/job/cmo
	important_information = "Эта роль требует, чтобы вы координировали работу отдела. От вас требуется знание Стандартных Рабочих Процедур (Медицинских), базовых должностных обязанностей и профессиональных действий."

/datum/outfit/job/cmo
	name = "Chief Medical Officer"
	jobtype = /datum/job/cmo

	uniform = /obj/item/clothing/under/rank/medical/chief_medical_officer
	suit = /obj/item/clothing/suit/storage/labcoat/cmo
	shoes = /obj/item/clothing/shoes/brown
	l_ear = /obj/item/radio/headset/heads/cmo
	id = /obj/item/card/id/cmo
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/doctor
	pda = /obj/item/pda/heads/cmo
	backpack_contents = list(
		/obj/item/melee/classic_baton/telescopic = 1
	)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/datum/job/doctor
	title = "Medical Doctor"
	flag = JOB_DOCTOR
	department_flag = JOBCAT_MEDSCI
	total_positions = 5
	spawn_positions = 3
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "главным врачом"
	department_head = list("Chief Medical Officer")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_SURGERY, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Surgeon","Nurse")
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/doctor

/datum/outfit/job/doctor
	name = "Medical Doctor"
	jobtype = /datum/job/doctor

	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/storage/labcoat
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/medical
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/storage/firstaid/doctor
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

/datum/job/doctor/intern	// SS220 ADDITION - new jobs

/datum/job/coroner
	title = "Coroner"
	flag = JOB_CORONER
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "главным врачом"
	department_head = list("Chief Medical Officer")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_MAINT_TUNNELS)
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/coroner

/datum/outfit/job/coroner
	name = "Coroner"
	jobtype = /datum/job/coroner

	uniform = /obj/item/clothing/under/rank/medical/scrubs/coroner
	suit = /obj/item/clothing/suit/storage/labcoat/mortician
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/coroner
	suit_store = /obj/item/flashlight/pen
	l_hand = /obj/item/clipboard
	pda = /obj/item/pda/medical

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical

	backpack_contents = list(
					/obj/item/clothing/head/surgery/black = 1,
					/obj/item/autopsy_scanner = 1,
					/obj/item/reagent_scanner = 1,
					/obj/item/healthanalyzer = 1,
					/obj/item/storage/box/bodybags = 1)

/datum/outfit/job/doctor/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Surgeon")
				uniform = /obj/item/clothing/under/rank/medical/scrubs
				head = /obj/item/clothing/head/surgery/blue
			if("Medical Doctor")
				uniform = /obj/item/clothing/under/rank/medical/doctor
			if("Nurse")
				if(H.gender == FEMALE)
					if(prob(50))
						uniform = /obj/item/clothing/under/rank/medical/nursesuit
					else
						uniform = /obj/item/clothing/under/rank/medical/nurse
					head = /obj/item/clothing/head/nursehat
				else
					uniform = /obj/item/clothing/under/rank/medical/scrubs/purple



//Chemist is a medical job damnit	//YEAH FUCK YOU SCIENCE	-Pete	//Guys, behave -Erro
/datum/job/chemist
	title = "Chemist"
	flag = JOB_CHEMIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 2
	spawn_positions = 2
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "главным врачом"
	department_head = list("Chief Medical Officer")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_CHEMISTRY, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	alt_titles = list("Pharmacist","Pharmacologist")
	minimal_player_age = 7
	exp_map = list(EXP_TYPE_CREW = 300)
	outfit = /datum/outfit/job/chemist

/datum/outfit/job/chemist
	name = "Chemist"
	jobtype = /datum/job/chemist

	uniform = /obj/item/clothing/under/rank/medical/chemist
	suit = /obj/item/clothing/suit/storage/labcoat/chemist
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_med
	glasses = /obj/item/clothing/glasses/science
	id = /obj/item/card/id/chemist
	pda = /obj/item/pda/chemist

	backpack = /obj/item/storage/backpack/chemistry
	satchel = /obj/item/storage/backpack/satchel_chem
	dufflebag = /obj/item/storage/backpack/duffel/chemistry

/datum/job/geneticist
	title = "Geneticist"
	flag = JOB_GENETICIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 2
	spawn_positions = 2
	job_department_flags = DEP_FLAG_MEDICAL | DEP_FLAG_SCIENCE
	supervisors = "главным врачом и директором исследований"
	department_head = list("Chief Medical Officer", "Research Director")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_GENETICS, ACCESS_RESEARCH, ACCESS_MAINT_TUNNELS)
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/geneticist

/datum/outfit/job/geneticist
	name = "Geneticist"
	jobtype = /datum/job/geneticist

	uniform = /obj/item/clothing/under/rank/rnd/geneticist
	suit = /obj/item/clothing/suit/storage/labcoat/genetics
	shoes = /obj/item/clothing/shoes/white
	l_ear = /obj/item/radio/headset/headset_medsci
	id = /obj/item/card/id/geneticist
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/geneticist

	backpack = /obj/item/storage/backpack/genetics
	satchel = /obj/item/storage/backpack/satchel_gen
	dufflebag = /obj/item/storage/backpack/duffel/genetics


/datum/job/virologist
	title = "Virologist"
	flag = JOB_VIROLOGIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "главным врачом"
	department_head = list("Chief Medical Officer")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_VIROLOGY, ACCESS_MAINT_TUNNELS, ACCESS_MINERAL_STOREROOM)
	alt_titles = list("Pathologist","Microbiologist")
	minimal_player_age = 7
	exp_map = list(EXP_TYPE_CREW = 300)
	required_objectives = list(
		/datum/job_objective/virus_samples
	)
	outfit = /datum/outfit/job/virologist

/datum/outfit/job/virologist
	name = "Virologist"
	jobtype = /datum/job/virologist

	uniform = /obj/item/clothing/under/rank/medical/virologist
	suit = /obj/item/clothing/suit/storage/labcoat/virologist
	shoes = /obj/item/clothing/shoes/white
	mask = /obj/item/clothing/mask/surgical
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/virologist
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/viro

	backpack = /obj/item/storage/backpack/virology
	satchel = /obj/item/storage/backpack/satchel_vir
	dufflebag = /obj/item/storage/backpack/duffel/virology

/datum/job/psychiatrist
	title = "Psychiatrist"
	flag = JOB_PSYCHIATRIST
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "главным врачом"
	department_head = list("Chief Medical Officer")
	selection_color = "#ffeef0"
	access = list(ACCESS_MEDICAL, ACCESS_PSYCHIATRIST, ACCESS_MAINT_TUNNELS)
	alt_titles = list("Psychologist","Therapist")
	outfit = /datum/outfit/job/psychiatrist

/datum/outfit/job/psychiatrist
	name = "Psychiatrist"
	jobtype = /datum/job/psychiatrist

	uniform = /obj/item/clothing/under/rank/medical/doctor
	suit = /obj/item/clothing/suit/storage/labcoat/psych
	shoes = /obj/item/clothing/shoes/laceup
	l_ear = /obj/item/radio/headset/headset_med
	id = /obj/item/card/id/psychiatrist
	suit_store = /obj/item/flashlight/pen
	pda = /obj/item/pda/medical

/datum/outfit/job/psychiatrist/pre_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	. = ..()
	if(H.mind && H.mind.role_alt_title)
		switch(H.mind.role_alt_title)
			if("Psychiatrist")
				uniform = /obj/item/clothing/under/rank/medical/psych
			if("Psychologist")
				uniform = /obj/item/clothing/under/rank/medical/psych/turtleneck
			if("Therapist")
				uniform = /obj/item/clothing/under/rank/medical/doctor

/datum/job/paramedic
	title = "Paramedic"
	flag = JOB_PARAMEDIC
	department_flag = JOBCAT_MEDSCI
	total_positions = 1
	spawn_positions = 1
	job_department_flags = DEP_FLAG_MEDICAL
	supervisors = "главным врачом"
	department_head = list("Chief Medical Officer")
	selection_color = "#ffeef0"
	access = list(
		ACCESS_CARGO,
		ACCESS_EVA,
		ACCESS_EXTERNAL_AIRLOCKS,
		ACCESS_MAILSORTING,
		ACCESS_MAINT_TUNNELS,
		ACCESS_MEDICAL,
		ACCESS_MINERAL_STOREROOM,
		ACCESS_MINING_STATION,
		ACCESS_MINING,
		ACCESS_MORGUE,
		ACCESS_PARAMEDIC
	)
	minimal_player_age = 3
	exp_map = list(EXP_TYPE_CREW = 180)
	outfit = /datum/outfit/job/paramedic
	important_information = "Вы являетесь первым, кто реагирует на неотложные медицинские ситуации за пределами неприкосновенности медицинского отсека. Вы также можете реагировать на вызовы с Лаваленда с помощью шахтерского шаттла, расположенного в отделе снабжения."

/datum/outfit/job/paramedic
	name = "Paramedic"
	jobtype = /datum/job/paramedic

	uniform = /obj/item/clothing/under/rank/medical/paramedic
	shoes = /obj/item/clothing/shoes/black
	head = /obj/item/clothing/head/soft/blue
	mask = /obj/item/clothing/mask/cigarette
	l_ear = /obj/item/radio/headset/headset_med/para
	id = /obj/item/card/id/paramedic
	l_pocket = /obj/item/flashlight/pen
	pda = /obj/item/pda/medical
	backpack_contents = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/sensor_device = 1,
		/obj/item/pinpointer/crew = 1)

	backpack = /obj/item/storage/backpack/medic
	satchel = /obj/item/storage/backpack/satchel_med
	dufflebag = /obj/item/storage/backpack/duffel/medical
	box = /obj/item/storage/box/engineer
