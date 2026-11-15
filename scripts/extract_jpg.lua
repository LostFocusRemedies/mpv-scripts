-- Extract a JPG image sequence from the currently playing file into
-- a "JPG" subfolder of the source directory. Bound to "J".
-- Compression: -b:v 0.75M (0.75 Mbps).

local utils = require 'mp.utils'

local function extract_jpg()
	local path = mp.get_property_native("path")
	if path == nil or path == "" then
		mp.osd_message("extract_jpg: no file loaded", 3)
		return
	end

	local dir, _ = utils.split_path(path)
	local name_no_ext = mp.get_property_native("filename/no-ext") or "frame"
	local out_dir = utils.join_path(dir, name_no_ext .. "_JPG")
	local pattern = utils.join_path(out_dir, name_no_ext .. "_%06d.jpg")

	-- Create the output directory (Windows).
	mp.command_native({
		name = "subprocess",
		playback_only = false,
		args = { "cmd", "/c", "if", "not", "exist", out_dir, "mkdir", out_dir },
	})

	mp.msg.info("extracting jpg sequence to " .. pattern)
	mp.osd_message("Extracting JPG sequence...\n" .. out_dir, 60)

	local res = mp.command_native({
		name = "subprocess",
		capture_stdout = true,
		capture_stderr = true,
		playback_only = false,
		args = {
			"ffmpeg", "-y",
			"-i", path,
			"-b:v", "0.75M",
			pattern,
		},
	})

	if res and res.status == 0 then
		local msg = "JPG sequence exported:\n" .. out_dir
		mp.msg.info(msg)
		mp.osd_message(msg, 5)
	else
		local code = res and res.status or "?"
		local err = res and res.stderr or ""
		mp.msg.error("ffmpeg failed (" .. tostring(code) .. "): " .. tostring(err))
		mp.osd_message("JPG export failed (ffmpeg " .. tostring(code) .. ")", 5)
	end
end

-- key bindings

mp.add_forced_key_binding("J", "extract_jpg", extract_jpg)
mp.register_script_message("extract-jpg", extract_jpg)
mp.msg.info("extract_jpg.lua loaded; bound to Shift+J")
