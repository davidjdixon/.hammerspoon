-- Application-related utilities
local lib = {}

-- osascript to tell an application to do something
function lib.tell(app, appCmd)
	local cmd = 'tell application "'..app..'" to '..appCmd
	local ok, result = hs.applescript(cmd)
	if ok and result == nil then result = true end
	if not ok then result = nil end
	return result
end

-- Easy notify
function lib.notify(title, message, withdrawAfter)

	local params = {title=title, informativeText=message}

	if withdrawAfter == 0 then
		params.autoWithdraw = false
	elseif withdrawAfter ~= nil and withdrawAfter > 0 then
		params.withdrawAfter = withdrawAfter
	end

	hs.notify.new(params):send()
end

return lib