-- physicsModel factory returns physicsModel, which have all physics data and methods
return function()
  local physicsModel = {}

  -- private variables
  local physicsData = {}
  physicsData.shapes = {}
  physicsData.fixtures = {}
  physicsData.polygons = {}

  -- private methods
  local toolTransformCoords

  physicsModel.load = function(
      polygons,
      world,
      startingBodyX,
      startingBodyY,
      originalImageWidth,
      originalImageHeight,
      imageScale,
      userDatas,
      density
    )

    -- define physics variables
    -- body = love.physics.newBody( world, x, y, type )
    physicsData.body = love.physics.newBody(world, startingBodyX, startingBodyY, 'dynamic')

    physicsData.polygons = polygons

    -- for loop adding shapes and fixtures to physicsData
    for key, polygonCoords in pairs(physicsData.polygons) do
      -- shape = love.physics.newPolygonShape( x1, y1, ,x2, y2, ...)
      -- 8 veritces at most, must be convex
      physicsData.shapes[key] = love.physics.newPolygonShape(
        toolTransformCoords(
          polygonCoords,
          originalImageWidth,
          originalImageHeight,
          imageScale
        )
      )

      -- set default damping -- recommended to be between 0 to 0.1
      -- fixture = love.physics.newFixture( body, shape, density )
      physicsData.fixtures[key] = love.physics.newFixture(physicsData.body, physicsData.shapes[key])

      -- update fixture with userData which is a name (string)
      physicsData.fixtures[key]:setUserData(userDatas[key])

      -- update fixture with custom density
      physicsData.fixtures[key]:setDensity(density)
    end

    physicsData.body:setAngularDamping(1.6)
    physicsData.body:setLinearDamping(0.6)
  end -- physicsModel.load

  physicsModel.update = function()
  end

  physicsModel.draw = function()
    love.graphics.setColor(0.28, 0.63, 0.05)
    for _, shape in pairs(physicsData.shapes) do
      -- Draws a polygon on the screen
      -- love.graphics.polygon(mode, vertices)
      -- mode [DrawMode] 'fill' or 'line', vertices - vertices of the polygon as a table
      -- love.graphics.polygon('fill', physicsData.body:getWorldPoints(shape:getPoints()))
    end
  end

  physicsModel.getBody = function()
    return physicsData.body
  end

  toolTransformCoords = function(coordsTableOriginal, width, height, scale)
    local coordsTable = {}
    for key, val in pairs(coordsTableOriginal) do
      if key % 2 == 1 then
        coordsTable[key] = (val - (width / 2)) * scale
      else
        coordsTable[key] = (val - (height / 2)) * scale
      end -- if
    end -- for
    return coordsTable
  end -- function

  return physicsModel
end
