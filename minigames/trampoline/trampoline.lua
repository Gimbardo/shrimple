local Game = {}

love.window.setMode(800, 600, {borderless= true})
love.window.setTitle("Trampoline")

function Game:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    
    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 600, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass("shrimp")
    world:addCollisionClass("wall")
    world:addCollisionClass("trampoline")

    shrimp = world:newRectangleCollider(400, 300, 40, 40, {
        collision_class = "shrimp"
    })

    platforms = {}
    trampolines = {}

    createWall(0, 0, 100, 600)
    createWall(700, 0, 100, 600)
    createTrampoline(100, 500, 600, 20)

    return o
end

function Game:update(dt)

    if shrimp:enter("trampoline") then
        shrimp:applyLinearImpulse(0, -2000)
        shrimp:applyAngularImpulse(1000, 0)
    end

    world:update(dt)
end

function Game:draw()
    world:draw()
end

function Game:mousepressed(x, y, button, istouch, presses)
    
end

function createWall(x, y, width, height)
    local platform = world:newRectangleCollider(x, y, width, height, {
        collision_class = "wall"
    })
    platform:setType('static')
    table.insert(platforms, platform)
end

function createTrampoline(x, y, width, height)
    local platform = world:newRectangleCollider(x, y, width, height, {
        collision_class = "trampoline"
    })
    platform:setType('static')
    table.insert(trampolines, platform)
end

return Game:new(nil)
