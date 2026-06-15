-- opens fpilot to the location of the currently playing file.
-- bound to Ctrl+f

local utils = require 'mp.utils'

local function open_location()
    local path = mp.get_property_native("path")
    if path == nil or path == "" then
		mp.osd_message("open_local error: no file", 3 )
		return
    end

    local dir, filename = utils.split_path(path)

    local res = mp.command_native({
		name           = "subprocess",
		capture_stdout = true,
		capture_stderr = true,
		playback_only  = false,
		args           = {
			"fpilot",
			path,
		},
    })

    if res and res.status == 0 then
		local msg = "opened location: " .. path
		mp.msg.info(msg)
		mp.osd_message(msg, 5)
    else
		local code = res and res.status or "?"
		local err  = res and res.stderr or ""
		mp.msg.error("failed to open the path with explorer: " .. tostring(code) .. " " .. tostring(err))
		mp.osd_message("super failed", 5)
    end
end


mp.add_forced_key_binding("Ctrl+f", "open_location", open_location, {repeatable = true})
-- mp.add_forced_key_binding("Ctrl+f", "open_location" .. tostring(code) .. tostring(err), open_location)
mp.register_script_message("open-location", open_location)
mp.msg.info("open_location.lua loaded; bound to Ctrl+f")



