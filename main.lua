
function love.load()

    anim8 = require 'libraries/anim8/anim8'

    sprites = {
        shrimp = love.graphics.newImage("sprites/shrimp.png")
    }

    local grid = anim8.newGrid(32, 32, sprites.shrimp:getWidth(), sprites.shrimp:getHeight())

    animations = {
        idle = anim8.newAnimation(grid('1-5', 1), 0.2)
    }

    love.window.setMode(1000, 768)
    buttons = {}
    font = love.graphics.newFont(32)
    hot_button = nil
    game = nil
    table.insert(buttons, newButton(
        "Demo",
        function()
            game = require "minigames/demo/demo"
        end)
    )
    table.insert(buttons, newButton(
        "Quit",
        function()
            love.event.quit(0)
        end)
    )
end

function love.update(dt)
    if game then
        game:update(dt)
        return
    end
    animations.idle:update(dt)
end

function love.mousepressed(x, y, button, istouch, mouse, presses)
    if game then
        game:mousepressed(x, y, button, istouch, mouse, presses)
        return
    end
    if button == 1 and hot_button then
        hot_button.fn()
    end
end

function love.draw()
    love.graphics.draw(love.graphics.newImage("sprites/ocean.jpg"))
    if game then
        game:draw()
        return
    end
    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local buttons_width = window_width/3
    local buttons_height = 60
    local margin = 16
    local total_height = (buttons_height + margin) * #buttons
    local cursor_y = 0

    for i, button in ipairs(buttons) do
        local mouse_x, mouse_y = love.mouse.getPosition()
        local button_x = window_width/2 - buttons_width/2
        local button_y = (window_height/2) - (total_height/2) + cursor_y

        local button_color = {0.4, 0.4, 0.5}
        hot = mouse_x > button_x and mouse_x < button_x + buttons_width and
                    mouse_y > button_y and mouse_y < button_y + buttons_height
        if hot then
            hot_button = button
            button_color = { 0.8, 0.8, 0.9 }
        end

        love.graphics.setColor(unpack(button_color))
        love.graphics.rectangle("fill", button_x, button_y, buttons_width, buttons_height)

        love.graphics.setColor(0, 0, 0)
        love.graphics.setFont(font)
        local text_width = font:getWidth(button.text)
        local text_height = font:getHeight(button.text)
        love.graphics.print(button.text, (window_width/2) - (text_width*0.5), button_y + (text_height*0.5))

        cursor_y = cursor_y + (buttons_height + margin)
    end
    love.graphics.setColor(1, 1, 1)

    animations.idle:draw(sprites.shrimp, (window_width/2)-(sprites.shrimp:getWidth()/5), (window_height/4), nil, 3)
end

function newButton(text, fn)
    return {
        text = text,
        fn = fn,
        hot = false,
    }
end
