local timer = require('lib/hump/timer')

return function(physicsModelFactory)
  -- constants

  -- variables
  local batPhysics = physicsModelFactory()
  local batImage
  local batImageWidth = 500
  local batImageHeight = 500
  local batQuads = {}
  local batX = 250
  local batY = 200 -- pixels -- Starting position
  local batRotation = -0.6 -- Initial rotation
  local batCurrentQuad -- Quad
  local batScale = 0.2
  local batDensity = 1

  local batRespawnCounterLevel = 5
  local batRespawnCounter = 5
  local batDeathPositionY = 750

  local batUserDatas = {
    'bat head', 'bat stomach'
  }
  local batPolygons = {}
  batPolygons[1] = {
    -- head
    366.00,237.00,
    356.00,302.00,
    380.00,354.00,
    420.00,370.00,
    439.00,337.00,
    418.00,296.00,
  }
  batPolygons[2] = {
    -- stomac
    378.00,351.00,
    352.00,307.00,
    254.00,275.00,
    53.00,282.00,
    29.00,310.00,
    287.00,396.00,
  }

  local bat = {}

  bat.batIsDead = false

  bat.load = function(world)
    -- Load image from file
    -- love.graphics.newImage(filename) -> Image
    batImage = love.graphics.newImage('assets/bat/spritesheet.png')

    -- Define quad for batImage
    -- love.graphics.newQuad(x, y, width, height, sheetWidth, sheetHeight) -> Quad
    batQuads[1] = love.graphics.newQuad(0, 0, batImageWidth, batImageHeight, batImage:getDimensions())
    batQuads[2] = love.graphics.newQuad(500, 0, batImageWidth, batImageHeight, batImage:getDimensions())
    batQuads[3] = love.graphics.newQuad(1000, 0, batImageWidth, batImageHeight, batImage:getDimensions())
    batQuads[4] = love.graphics.newQuad(1500, 0, batImageWidth, batImageHeight, batImage:getDimensions())

    -- initial quad
    batCurrentQuad = batQuads[1]


    batPhysics.load(
      batPolygons,
      world,
      batX,
      batY,
      batImageWidth,
      batImageHeight,
      batScale,
      batUserDatas,
      batDensity
    )
  end

  bat.update = function(dt)
    -- Prevent from flying up above screen
    if batY < 30 then
      batPhysics.getBody():applyLinearImpulse(0, 50)
    end

    if batY < 0 then
      batPhysics.getBody():applyLinearImpulse(0, 50)
    end

    -- Prevent from flying left of screen
    if batX < 0 then
      batPhysics.getBody():applyLinearImpulse(25, 0)
    end

    if batX < -15 then
      batPhysics.getBody():applyLinearImpulse(25, 0)
    end

    -- Fixed x position of the bat
    -- batPhysics.getBody():setX(batX)

    -- Update according to physics model
    batX = batPhysics.getBody():getX()
    batY = batPhysics.getBody():getY()
    batRotation = batPhysics.getBody():getAngle()

    -- Make rotation value always between 0 and 6.28320
    if (batRotation > 6.28319) then
      batRotation = 0
      batPhysics.getBody():setAngle(0)
    end
    if (batRotation < 0) then
      batRotation = 6.28320
      batPhysics.getBody():setAngle(6.28320)
    end

    -- Check velocity in Y direction
    local _, velocityY = batPhysics.getBody():getLinearVelocity()

    -- If moving down
    if (velocityY > 0) then
      -- Check if bat head is pointing right
      if (batRotation >= 4.71 and batRotation <= 6.28320) or (batRotation >= 0 and batRotation < 1.22) then
        batPhysics.getBody():applyTorque(500)
      end
      -- Check if bat head is pointing left
      if batRotation > 1.22 and batRotation < 4.71 then
        batPhysics.getBody():applyTorque(-500)
      end
    end

    -- If moving up
    if (velocityY < 0) then
      -- Check if bat head is pointing up
      if (batRotation >= 3.14 and batRotation <= 6.28320) then
        batPhysics.getBody():applyTorque(1000)
      end
      -- Check if bat head is pointing down
      if batRotation >= 0 and batRotation < 3.14 then
        batPhysics.getBody():applyTorque(-1000)
      end
    end -- if

    -- Check is bat under the screen
    if (batY > batDeathPositionY) then
      bat.batIsDead = true

      local joints = batPhysics.getBody():getJoints()
      for _, joint in pairs(joints) do
        joint:destroy()
      end
    end

    -- If bat is dead start counting down to respawn
    if (bat.batIsDead) then
      batRespawnCounter = batRespawnCounter - dt
    end

    -- If respawn counter is 0 change bat position to starting position
    if math.floor(batRespawnCounter) == 0 then
      bat.batIsDead = false
      batY = 100
      batPhysics.getBody():setLinearVelocity(0, 0)
      batPhysics.getBody():setY(100)
      batPhysics.getBody():setX(250)
      batPhysics.getBody():setAngle(0)
      batRespawnCounterLevel = batRespawnCounterLevel + 1
      batRespawnCounter = batRespawnCounterLevel
    end
  end -- Bat.update

  bat.draw = function()
    -- Set color used for drawing
    -- love.graphics.setColor(red, green, blue, alfa)
    love.graphics.setColor(1, 1, 1)

    -- Draw a drawable object into the screen
    -- love.graphics.draw(drawable, [quad], x, y, rotation, scaleFactorX, scaleFactorY, originOffsetX, originOffsetY)
    love.graphics.draw(
      batImage,
      batCurrentQuad,
      batX,
      batY,
      batRotation,
      batScale,
      batScale,
      250,
      250
    )

    batPhysics.draw()

    if (bat.batIsDead) then
      love.graphics.setColor(0, 0, 0)
      love.graphics.print(math.floor(batRespawnCounter), 200, 300, 0, 5, 5)
    end
  end -- bat.draw

  bat.keypressedReturn = function()
    -- When dead, cannot fly up
    if (bat.batIsDead) then
      return
    end

    -- Add "jump" upwards to physics body
    -- body.applyForce(fx, fy)
    batPhysics.getBody():setLinearVelocity(0, 0)
    batPhysics.getBody():applyLinearImpulse(8, -200)


    -- @todo Add nice comment
    if (batRotation > 3.14 and batRotation <= 6.28320) then
      local absoluteRotation = batRotation - 3.14
      batPhysics.getBody():applyAngularImpulse(250 * absoluteRotation)
    end
    if batRotation >= 0 and batRotation < 3.14 then
      batPhysics.getBody():applyAngularImpulse(-250 * batRotation)
    end

    -- Change quads when flying up with the bat
    timer.script(function(wait)
      batCurrentQuad = batQuads[2]
      wait(0.15)
      batCurrentQuad = batQuads[3]
      wait(0.15)
      batCurrentQuad = batQuads[4]
      wait(0.08)
      batCurrentQuad = batQuads[3]
      wait(0.08)
      batCurrentQuad = batQuads[2]
      wait(0.08)
      batCurrentQuad = batQuads[1]
    end)
  end

  bat.reset = function()
    bat.batIsDead = false
    batPhysics.getBody():setLinearVelocity(0, 0)
    batPhysics.getBody():setX(250)
    batPhysics.getBody():setY(200)
    batPhysics.getBody():setAngle(-0.6)
  end

  return bat
end
