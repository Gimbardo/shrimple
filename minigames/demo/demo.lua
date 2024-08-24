local Game = {}

love.window.setMode(800, 600) --, {borderless= true}
love.window.setTitle("Demo")

function Game:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.target = {
        x = 300,
        y = 300,
        radius = 50
    }
    self.score = 0
    self.timer = 0
    self.game_state = 1

    self.sprites = {
        sky = love.graphics.newImage('minigames/demo/sprites/sky.png'),
        target = love.graphics.newImage('minigames/demo/sprites/target.png'),
        crosshair = love.graphics.newImage('minigames/demo/sprites/crosshairs.png')
    }
    return o
end

function Game:update(dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
    end
    if self.timer < 0 then
        self.timer = 0
        self.game_state = 1
    end
end

function Game:draw()
    love.graphics.draw(self.sprites.sky, 0, 0)
    love.graphics.setFont(love.graphics.newFont(30))
    love.graphics.setColor(1, 0, 0)
    love.graphics.print("Score: " .. self.score, 5, 5)

    love.graphics.print("Time: " .. math.ceil(self.timer), 300, 5)

    love.graphics.setColor(1, 1, 1)

    if self.game_state == 1 then
        love.graphics.printf("Click anywhere to begin!", 0, 250, love.graphics.getWidth(), 'center')
    end

    if self.game_state == 2 then
        love.graphics.draw(self.sprites.target, self.target.x-self.target.radius, self.target.y-self.target.radius)
    end
    love.graphics.draw(self.sprites.crosshair, love.mouse.getX()-20, love.mouse.getY()-20)
end

function Game:mousepressed(x, y, button, istouch, presses)
    if self.game_state == 1 then
        if button == 1 then
            self.game_state = 2
            self.timer = 10
            self.score = 0
        end
    elseif self.game_state == 2 then
        local distance = distanceBetween(self.target,{x=x, y=y})
        if self.target.radius >= distance then
            if button == 1 then
                self.score = self.score + 1
            elseif button == 2 then
                self.score = self.score + 2
                self.timer = self.timer - 1
            end
            setRandomXY(self.target)
        elseif self.score > 0 then
            self.score = self.score - 1
        end
    end
end

function setRandomXY(target)
    target.x = math.random(target.radius, love.graphics.getWidth()-target.radius)
    target.y = math.random(target.radius, love.graphics.getHeight()-target.radius)
end
  
function distanceBetween(target, object)
    return math.sqrt((target.x - object.x)^2 + (target.y - object.y)^2)
end

return Game:new(nil)
