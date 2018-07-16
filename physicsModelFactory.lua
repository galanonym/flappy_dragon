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
      imageScale
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

      -- fixture = love.physics.newFixture( body, shape, density )
      physicsData.fixtures[key] = love.physics.newFixture(physicsData.body, physicsData.shapes[key])
    end
  end -- physicsModel.load

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
