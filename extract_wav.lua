-- Extract the audio track of the currently playing file to a WAV
-- file in the same directory. Bound to Shift+W.

local utils = require 'mp.utils'

local function extract_wav()
	local path = mp.get_property_native("path")
	if path == nil or path == "" then
		mp.osd_message("extractwav: no file loaded", 3)
		return
	end

	local dir, filename = utils.split_path(path)
	local name_no_ext = mp.get_property_native("filename/no-ext") or filename
	local dst = utils.join_path(dir, name_no_ext .. ".wav")

	mp.msg.info("extracting wav to " .. dst)
	mp.osd_message("Extracting WAV...\n" .. dst, 60)

	local res = mp.command_native({
		name = "subprocess",
		capture_stdout = true,
		capture_stderr = true,
		playback_only = false,
		args = { 
			"ffmpeg", "-y",
			"-i", path,
			"-vn",
			"-acodec", "pcm_s16le",
			dst,
		},
	})

	if res and res.status == 0 then
		local msg = "WAV exported:\n" .. dst
		mp.msg.info(msg)
		mp.osd_message(msg, 5)
	else
		local code = res and res.status or "?"
		local err = res and res.stderr or ""
		mp.msg.error("ffmpeg failed (" .. tostring(code) .. "): " .. tostring(err))
		mp.osd_message("WAV export failed (ffmpeg " .. tostring(code) .. ")", 5)
	end
end

mp.add_forced_key_binding("W", "extract_wav", extract_wav)
mp.register_script_message("extract-wav", extract_wav)
mp.msg.info("extractwav.lua loaded; bound to Shift+W")
