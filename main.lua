push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200 

function love.load()
    love.graphics.setDefaultFilter('nearest', 'nearest')

    love.window.setTitle('Pong')

    math.randomseed(os.time())

    smallFont = love.graphics.newFont('Assets/font.ttf', 8)
    largeFont = love.graphics.newFont('Assets/font.ttf', 16)
    scoreFont = love.graphics.newFont('Assets/font.ttf', 32)
    love.graphics.setFont(smallFont)

    sounds = {
        ['paddle_hit'] = love.audio.newSource('Assets/Hit_Hurt2.wav', 'static'),
        ['score'] = love.audio.newSource('Assets/Pickup_Coin.wav', 'static'),
        ['wall_hit'] = love.audio.newSource('Assets/Explosion.wav', 'static')
    }

    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true
    })

    player1Score = 0
    player2Score = 0

    player1 = Paddle(10, 30, 5, 20)
    player2 = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT -30, 5, 20)

    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

end

function love.resize(w, h)
    push:resize(w, h)
end

function love.update(dt)
    if gameState == 'serve' then
        ball.dy = math.random(-50, 50)
        if servingPlayer == 1 then
            ball.dx = math.random(140, 200)
        else
            ball.dx = -math.random(140, 200)
        end
    elseif gameState == 'play' then
        if ball:collides(player1) then
            ball.dx = -ball.dx * 1.03
            ball.x = player1.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['Hit_Hurt2']:play()
        end
        if ball:collides(player2) then
            ball.dx = -ball.dx * 1.03
            ball.x = player2.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['Hit_Hurt2']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['Explosion']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['Explosion']:play()
        end

        --insert score part in here and delete this comment after

    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    
    
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            
            gameState = 'serve'

            ball:reset()

            --insert score part here and delete this comment after
        end 
    end

end

function love.draw()
    push:apply('start')

    love.graphics.clear(79/255, 98/255, 122/255, 1)

    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 -50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
    love.graphics.setFont(smallFont)

    player1:render()
    player2:render()

    ball:render()

    displayFPS()

    push:apply('end')
end

--insert function displayScore()

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end