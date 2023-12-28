-- WIP pomodoro menubar timer
--
-- Notes:
-- * You want to set your Hammerspoon notification settings to Alert
--   if you wish to make the notifications dismissable
--
-- Resources:
-- https://learnxinyminutes.com/docs/lua/
-- http://www.hammerspoon.org/docs/hs.menubar.html
-- http://www.hammerspoon.org/docs/hs.timer.html#doEvery

local menu = hs.menubar.new()
local timer = nil
local currentPomo = nil
local alertId = nil

local INTERVAL_SECONDS = 60 -- Set to 60 (one minute) for real use; set lower for debugging
local POMO_LENGTH = 25 -- Number of intervals (minutes) in one work pomodoro
local BREAK_LENGTH = 5 -- Number of intervals (minutes) in one break time
local LOG_FILE = "~/.pomo"

-- Namespace tables
local Commands = {}
local Log = {}
local App = {}

-- (ab)use hs.chooser as a text input with the possibility of using other options
local showChooserPrompt = function(items, callback)
	local chooser = nil
	chooser = hs.chooser.new(function(item)
		if item then
			callback(item.text)
		end
		if chooser then
			chooser:delete()
		end
	end)

	-- The table of choices to present to the user. It's comprised of one empty
	-- item (which we update as the user types), and those passed in as items
	local choiceList = { { text = "" } }
	for i = 1, #items do
		choiceList[#choiceList + 1] = items[i]
	end

	chooser:choices(function()
		choiceList[1]["text"] = chooser:query()
		return choiceList
	end)

	-- Re-compute the choices every time a key is pressed, to ensure that the top
	-- choice is always the entered text:
	chooser:queryChangedCallback(function()
		chooser:refreshChoicesCallback()
	end)

	chooser:show()
end

-- Read the last {count} lines of the log file, ordered with the most recent one first
Log.read = function(count)
	if not count then
		count = 10
	end
	-- Note the funky sed command at the end is to reverse the ordering of the lines:
	return hs.execute("tail -" .. count .. " " .. LOG_FILE .. " | sed '1!G;h;$!d' ${inputfile}")
end

Log.writeItem = function(pomo)
	local timestamp = os.date("%Y-%m-%d %H:%M")
	local isFirstToday = #(Log.getCompletedToday()) == 0

	if isFirstToday then
		hs.execute('echo "" >> ' .. LOG_FILE)
	end -- Add linebreak between days
	hs.execute('echo "[' .. timestamp .. "] " .. pomo.name .. '" >> ' .. LOG_FILE)
end

Log.getLatestItems = function(count)
	local logs = Log.read(count)
	local logItems = {}
	for match in logs:gmatch("(.-)\r?\n") do
		table.insert(logItems, match)
	end
	return logItems
end

Log.getCompletedToday = function()
	local logItems = Log.getLatestItems(20)
	local timestamp = os.date("%Y-%m-%d")
	local todayItems = hs.fnutils.filter(logItems, function(s)
		return string.find(s, timestamp, 1, true) ~= nil
	end)
	return todayItems
end

-- Return a table of recent tasks ({text, subText}), most recent first
Log.getRecentTaskNames = function()
	local tasks = Log.getLatestItems(12)
	local nonEmptyTasks = hs.fnutils.filter(tasks, function(t)
		return t ~= ""
	end)
	local names = hs.fnutils.map(nonEmptyTasks, function(taskWithTimestamp)
		local timeStampEnd = string.find(taskWithTimestamp, "]")
		return {
			text = string.sub(taskWithTimestamp, timeStampEnd + 2),
			subText = string.sub(taskWithTimestamp, 2, timeStampEnd - 1), -- slice braces off
		}
	end)

	-- TODO: dedupe these items before returning
	return names
end

Commands.startNew = function()
	local options = Log.getRecentTaskNames()
	showChooserPrompt(options, function(taskName)
		if taskName then
			currentPomo = { minutesLeft = POMO_LENGTH, name = taskName }
			if timer then
				timer:stop()
			end
			timer = hs.timer.doEvery(INTERVAL_SECONDS, App.timerCallback)
		end
		App.updateUI()
	end)
end

Commands.togglePaused = function()
	if not currentPomo then
		return
	end
	currentPomo.paused = not currentPomo.paused
	App.updateUI()
end

Commands.toggleLatestDisplay = function()
	local logs = Log.read(30)
	if alertId then
		hs.alert.closeSpecific(alertId)
		alertId = nil
	else
		local msg = "LATEST ACTIVITY\n\n" .. logs
		if currentPomo then
			msg = "NOW: " .. currentPomo.name .. "\n==========\n\n" .. msg
		end
		alertId = hs.alert(msg, { textSize = 17, textFont = "Courier" }, "indefinite")
	end
end

App.timerCallback = function()
	if not currentPomo then
		return
	end
	if currentPomo.paused then
		return
	end
	currentPomo.minutesLeft = currentPomo.minutesLeft - 1
	if currentPomo.minutesLeft <= 0 then
		App.completePomo(currentPomo)
	end
	App.updateUI()
end

App.completePomo = function(pomo)
	local n = hs.notify.new({
		title = "Pomodoro complete",
		subTitle = pomo.name,
		informativeText = "Completed at " .. os.date("%H:%M"),
		soundName = "Hero",
	})
	n:autoWithdraw(false)
	n:hasActionButton(false)
	n:send()

	Log.writeItem(pomo)
	currentPomo = nil

	if timer then
		timer:stop()
	end
	timer = hs.timer.doAfter(INTERVAL_SECONDS * BREAK_LENGTH, function()
		local n2 = hs.notify.new({
			title = "Get back to work",
			subTitle = "Break time is over",
			informativeText = "Sent at " .. os.date("%H:%M"),
			soundName = "Hero",
		})
		n2:autoWithdraw(false)
		n2:hasActionButton(false)
		n2:send()
	end)
end

App.getMenubarTitle = function(pomo)
	local title = "🍅"
	if pomo then
		title = title .. ("0:" .. string.format("%02d", pomo.minutesLeft))
		if pomo.paused then
			title = title .. " (paused)"
		end
	end
	return title
end

App.updateUI = function()
	menu:setTitle(App.getMenubarTitle(currentPomo))
end

App.init = function()
	menu:setMenu(function()
		local completedCount = #(Log.getCompletedToday())
		return {
			-- TODO: make these menu items contextual:
			{ title = completedCount .. " pomos completed today", disabled = true },
			{ title = "Start", fn = Commands.startNew },
			{ title = "Pause", fn = Commands.togglePaused },
		}
	end)

	App.updateUI()
end

App.init()

return Commands
