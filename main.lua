local push = require('lib/push')

local stateMap = {}
stateMap.stateGame = require('stateGame')()
stateMap.statePaused = require('statePaused')()
stateMap.stateGameOver = require('stateGameOver')()

love.stateCurrent = 'stateGame'

function love.load()
  -- Sets display mode and properties of window
  -- love.window.setMode(width, height, flagsTable)
  -- love.window.setMode(1200, 700)
  local windowWidth, windowHeight = love.window.getMode()
  push:setupScreen(1200, 700, windowWidth, windowHeight, {
    resizable = true
  })

  math.randomseed(os.time())

  for _, state in pairs(stateMap) do
    if state.load then
      state.load()
    end
  end
end

function love.update(dt)
  if stateMap[love.stateCurrent].update then
    stateMap[love.stateCurrent].update(dt)
  end
end

function love.draw()
  push:start()

  if stateMap[love.stateCurrent].draw then
    stateMap[love.stateCurrent].draw()
  end

  push:finish()
end

function love.keypressed(key)
  if stateMap[love.stateCurrent].keypressed then
    stateMap[love.stateCurrent].keypressed(key)
  end
end

function love.resize(w, h)
    push:resize(w, h)
end
