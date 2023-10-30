/datum/tts_provider/white_dream
	name = "White Dream"
	is_enabled = TRUE
	api_url = "https://pubtts.ss14.su/api/v1/tts"

/datum/tts_provider/white_dream/vv_edit_var(var_name, var_value)
	if(var_name == "api_url")
		return FALSE
	return ..()

/datum/tts_provider/white_dream/request(text, datum/tts_seed/white_dream/seed, datum/callback/proc_callback)
	if(throttle_check())
		return FALSE

	var/ssml_text = {"[text]"}

	var/list/req_body = list()
	req_body["text"] = ssml_text
	req_body["speaker"] = seed.value
	req_body["ext"] = "ogg"

	SShttp.create_async_request(RUSTG_HTTP_METHOD_GET, api_url, json_encode(req_body), list("content-type" = "application/json", 
    "Authorization", {Bearer "[GLOB.configuration.tts.tts_token_white_dream]"}), proc_callback)

	return TRUE

/datum/tts_provider/white_dream/process_response(datum/http_response/response)
    log_debug(response.body)
    var/data = json_decode(response.body)

    return data["results"][1]["audio"]

	//var/sha1 = data["original_sha1"]

/datum/tts_provider/white_dream/pitch_whisper(text)
	return {"[text]"}

/datum/tts_provider/white_dream/rate_faster(text)
	return {"[text]"}

/datum/tts_provider/white_dream/rate_medium(text)
	return {"[text]"}
