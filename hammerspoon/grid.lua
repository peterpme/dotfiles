Grid = {}
Grid.BORDER = 1

-- Describe the share of the screen that the L/R "chunks" take:
Grid.L_CHUNK_SHARE = 0.5
Grid.R_CHUNK_SHARE = 0.5

Grid.PEEK_PIXELS = 70

function Grid.fullscreen()
  local win = hs.window.focusedWindow()
  if not win then return end

  local screenframe = Grid.screenframe(win)
  win:setFrame(screenframe)
end

function Grid.lefthalf()
  local win = hs.window.focusedWindow()
  if not win then return end

  local screenframe = Grid.screenframe(win)
  local newframe = {
    x = screenframe.x,
    y = screenframe.y,
    w = screenframe.w / 2 - Grid.BORDER,
    h = screenframe.h,
  }

  win:setFrame(newframe)
end

function Grid.topHalf()
  local win = hs.window.focusedWindow()
  if not win then return end

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
  if not win then return end

  local screenframe = Grid.screenframe(win)
  local newframe = {
    x = screenframe.x,
    y = screenframe.y + screenframe.h / 2 + Grid.BORDER,
    w = screenframe.w,
    h = screenframe.h / 2 - Grid.BORDER,
  }

  win:setFrame(newframe)
end

function Grid.righthalf()
  local win = hs.window.focusedWindow()
  if not win then return end

  local screenframe = Grid.screenframe(win)
  local newframe = {
    x = screenframe.x + screenframe.w / 2 + Grid.BORDER,
    y = screenframe.y,
    w = screenframe.w / 2 - Grid.BORDER,
    h = screenframe.h,
  }

  win:setFrame(newframe)
end

function Grid.topleft()
  local win = hs.window.focusedWindow()
  if not win then return end

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
  if not win then return end

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
  if not win then return end

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
  if not win then return end

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
  if not win then return end

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
function Grid.leftchunk()
  local win = hs.window.focusedWindow()
  if not win then return end

  local screenframe = Grid.screenframe(win)
  local newframe = {
    x = screenframe.x,
    y = screenframe.y,
    w = screenframe.w * Grid.L_CHUNK_SHARE - Grid.BORDER,
    h = screenframe.h,
  }

  win:setFrame(newframe)
end

function Grid.rightchunk()
  local win = hs.window.focusedWindow()
  if not win then return end

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
  if not win then return end

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
