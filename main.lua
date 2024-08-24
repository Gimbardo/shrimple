local shader_code = [[
#define NUM_LIGHTS 32

struct Light {
    vec2 position;
    vec3 diffuse;
    float power;
};

extern Light lights[NUM_LIGHTS];
extern int num_lights;
extern vec2 screen;

const float constant = 1.0;
const float linear = 0.09;
const float quadratic = 0.032;

vec4 effect(vec4 color, Image image, vec2 uvs, vec2 screen_coords) {
    vec4 pixel = Texel(image, uvs);

    return pixel * color;
}
]]

function love.load()

    anim8 = require 'libraries/anim8/anim8'

    sprites = {
        shrimp = love.graphics.newImage("sprites/shrimp.png"),
        bg = love.graphics.newImage("sprites/bg.jpg")
    }

    local grid = anim8.newGrid(32, 32, sprites.shrimp:getWidth(), sprites.shrimp:getHeight(), nil, nil, 1)

    animations = {
        idle = anim8.newAnimation(grid('1-5', 1), 0.2),
        swim = anim8.newAnimation(grid('1-9', 2), 0.1)
    }

    shader = love.graphics.newShader(shader_code)

    buttons = {}
    hot_button = nil
    game = nil
    local grid_x_max = 5
    local grid_y_max = 5
    btn_margin = 16 -- both margins between buttons and from screen
    btn_width = 160
    btn_height = 120

    love.window.setMode(
        (btn_width*grid_x_max)+(btn_margin*(grid_x_max+1)),
        (btn_height*grid_y_max)+(btn_margin*(grid_y_max+1)))
    love.window.setTitle("Shrimple")

    table.insert(buttons, newButton(
        "Demo",
        function()
            game = require "minigames/demo/demo"
        end,
        love.graphics.newImage("sprites/buttons/demo.png"),
        0,0
    ))
    table.insert(buttons, newButton(
        "Trampoline\nShrimp",
        function()
            game = require "minigames/trampoline/trampoline"
        end,
        love.graphics.newImage("sprites/buttons/trampoline.png"),
        0,1,
        {1, 1, 1},
        26
    ))
    table.insert(buttons, newButton(
        "Quit",
        function()
            love.event.quit(0)
        end,
        love.graphics.newImage("sprites/buttons/quit.jpg"),
        4,4,
        {1, 1, 1}
    ))
end

function love.update(dt)
    if game then
        game:update(dt)
        return
    end

    local mouse_x, mouse_y = love.mouse.getPosition()
    hot_button = nil

    for i, b in ipairs(buttons) do
        hot = mouse_x > b.x_coords and mouse_x < b.x_coords + b.width and
                    mouse_y > b.y_coords and mouse_y < b.y_coords + b.height
        if hot then
            hot_button = b
            b.color = b.hotColor
        else
            b.color = b.defaultColor
        end
    end

    animations.idle:update(dt)
    animations.swim:update(dt)
end

function love.mousepressed(x, y, button, istouch, mouse, presses)
    if game and game.mousepressed then
        game:mousepressed(x, y, button, istouch, mouse, presses)
        return
    end
    if button == 1 and hot_button then
        hot_button.fn()
    end
end

function love.draw()
    if game then
        game:draw()
        return
    end
    love.graphics.draw(sprites.bg, 0, 0, nil, 2)
    love.graphics.setShader(shader)

    local window_width = love.graphics.getWidth()
    local window_height = love.graphics.getHeight()
    local buttons_width = window_width/3
    local buttons_height = 60


    for i, button in ipairs(buttons) do
        local font = love.graphics.newFont(button.fontSize)
        love.graphics.setColor(unpack(button.color))

        love.graphics.draw(button.img, button.x_coords, button.y_coords, nil, button.scale_x, button.scale_y)

        love.graphics.setColor(unpack(button.textColor))
        love.graphics.setFont(font)
        local text_width = font:getWidth(button.text)
        local text_height = font:getHeight(button.text)
        local n_lines = select(2, button.text:gsub('\n', '\n')) + 1
        love.graphics.printf(button.text,
                            button.x_coords,
                            button.y_coords - (text_height*0.5*n_lines) + (button.height/2),
                            button.width, "center")
    end
    love.graphics.setColor(1, 1, 1)
    --animations.idle:draw(sprites.shrimp, (window_width/2)-(sprites.shrimp:getWidth()/5), (window_height/4), nil, 3)
    love.graphics.setShader()
end

function newButton(text, fn, img, x, y, textColor, fontSize)
    scale_x = btn_width / img:getWidth()
    scale_y = btn_height / img:getHeight()
    btn = {
        text = text,
        fn = fn,
        hot = false,
        img = img,
        x = x,
        y = y,
        width = img:getWidth()*scale_x,
        height = img:getHeight()*scale_y,
        scale_x = scale_x,
        scale_y = scale_y,
        color = {1, 1, 1},
        defaultColor = {1, 1, 1},
        hotColor = {0.8, 0.8, 0.9},
        textColor = textColor or { 0, 0, 0 },
        fontSize = fontSize or 32,
    }
    btn.x_coords = btn_margin + (btn.x * (btn.width + btn_margin))
    btn.y_coords = btn_margin + (btn.y * (btn.height + btn_margin))
    return btn
end
