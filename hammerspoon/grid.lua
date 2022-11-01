local alert = require "hs.alert"

Grid = {}
Grid.BORDER = 1

-- Describe the share of the screen that the L/R "chunks" take:
Grid.L_CHUNK_SHARE = 0.5
Grid.R_CHUNK_SHARE = 0.5

Grid.PEEK_PIXELS = 70

local positions = {
	fullscreen = { x = 0.00, y = 0.00, w = 1.00, h = 1.00 },

	right50 = { x = 0.50, y = 0.00, w = 0.50, h = 1.00 },
	left50 = { x = 0.00, y = 0.00, w = 0.50, h = 1.00 },
	top50 = { x = 0.00, y = 0.00, w = 1.00, h = 0.50 },
	bottom50 = { x = 0.00, y = 0.50, w = 1.00, h = 0.50 },
	right33 = { x = (1 / 3) * 2, y = 0.00, x2 = 1.00, h = 1.00 },
	left33 = { x = 0.00, y = 0.00, w = 1 / 3, h = 1.00 },

	bottomCenter50 = { x = 0.25, y = 0.50, w = 0.50, h = 0.50 },
}

function alertCannotManipulateWindow()
	alert.show("Can't move window")
end

function move(position)
	local win = window.focusedWindow()
	if not win then
		alertCannotManipulateWindow()
		return
	end
	win:move(position, nil, true)
end

function Grid.fullscreen()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local screenframe = Grid.screenframe(win)
	win:setFrame(screenframe)
end

function Grid.topHalf()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local screenframe = Grid.screenframe(win)
	local newframe = {
		x = screenframe.x,
		y = screenframe.y,
		w = screenframe.w,
		h = screenframe.h / 2 - Grid.BORDER,
	}

	win:setFrame(newframe)
end

function Grid.bottomHalf()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local screenframe = Grid.screenframe(win)
	local newframe = {
		x = screenframe.x,
		y = screenframe.y + screenframe.h / 2 + Grid.BORDER,
		w = screenframe.w,
		h = screenframe.h / 2 - Grid.BORDER,
	}

	win:setFrame(newframe)
end

function Grid.topleft()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local screenframe = Grid.screenframe(win)
	local newframe = {
		x = screenframe.x,
		y = screenframe.y,
		w = screenframe.w * Grid.L_CHUNK_SHARE - Grid.BORDER,
		h = screenframe.h / 2 - Grid.BORDER,
	}

	win:setFrame(newframe)
end

function Grid.bottomleft()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local screenframe = Grid.screenframe(win)
	local newframe = {
		x = screenframe.x,
		y = screenframe.y + screenframe.h / 2 + Grid.BORDER,
		w = screenframe.w * Grid.L_CHUNK_SHARE - Grid.BORDER,
		h = screenframe.h / 2 - Grid.BORDER,
	}

	win:setFrame(newframe)
end

function Grid.topright()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local screenframe = Grid.screenframe(win)
	local newframe = {
		x = screenframe.x + screenframe.w * Grid.L_CHUNK_SHARE + Grid.BORDER,
		y = screenframe.y,
		w = screenframe.w * Grid.R_CHUNK_SHARE - Grid.BORDER,
		h = screenframe.h / 2 - Grid.BORDER,
	}

	win:setFrame(newframe)
end

function Grid.bottomright()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local screenframe = Grid.screenframe(win)
	local newframe = {
		x = screenframe.x + screenframe.w * Grid.L_CHUNK_SHARE + Grid.BORDER,
		y = screenframe.y + screenframe.h / 2 + Grid.BORDER,
		w = screenframe.w * Grid.R_CHUNK_SHARE - Grid.BORDER,
		h = screenframe.h / 2 - Grid.BORDER,
	}

	win:setFrame(newframe)
end

function Grid.pushwindow()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local winframe = win:frame()
	local nextscreen = win:screen():next()
	local screenframe = nextscreen:frame()
	local newframe = {
		x = screenframe.x,
		y = screenframe.y,
		w = math.min(winframe.w, screenframe.w),
		h = math.min(winframe.h, screenframe.h),
	}

	win:setFrame(newframe)
end

function Grid.screenframe(win)
	return win:screen():frame()
end

-- Customized versions of lefthalf() and righthalf() that make the left side slightly wider:
function Grid.leftHalf()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local screenframe = Grid.screenframe(win)
	local newframe = {
		x = screenframe.x,
		y = screenframe.y,
		w = screenframe.w * Grid.L_CHUNK_SHARE - Grid.BORDER,
		h = screenframe.h,
	}

	win:setFrame(newframe)
end

function Grid.rightHalf()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local screenframe = Grid.screenframe(win)
	local newframe = {
		x = screenframe.x + screenframe.w * Grid.L_CHUNK_SHARE + Grid.BORDER,
		y = screenframe.y,
		w = screenframe.w * Grid.R_CHUNK_SHARE - Grid.BORDER,
		h = screenframe.h,
	}

	win:setFrame(newframe)
end

function Grid.rightpeek()
	local win = hs.window.focusedWindow()
	if not win then
		return
	end

	local screenframe = Grid.screenframe(win)
	local newframe = {
		x = screenframe.x + screenframe.w - Grid.PEEK_PIXELS,
		y = screenframe.y,
		w = screenframe.w * Grid.R_CHUNK_SHARE - Grid.BORDER,
		h = screenframe.h,
	}

	win:setFrame(newframe)
end

return Grid
