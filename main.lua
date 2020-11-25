-- Author: Colton Ogden

--the word 'require' is used to get the properties of the other files and use
--it in the main file
push = require 'push'
Class = require 'class'

require 'Paddle'
require 'Ball'

--width and height of the screen 
WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

--virtual width and virtual height has the same resoulution, either in a small 
--or large screen
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 120 

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

    playerScore = 0
    botScore = 0

    servingPlayer = 1
    winningPlayer = 0

    --position of the paddles virtually
    player = Paddle(10, 30, 5, 20)
    bot = Paddle(VIRTUAL_WIDTH - 10, VIRTUAL_HEIGHT -30, 5, 20)

    --position of the ball virtually
    ball = Ball(VIRTUAL_WIDTH / 2 - 2, VIRTUAL_HEIGHT / 2 - 2, 4, 4)

    gameState = 'start'
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
        if ball:collides(player) then
            ball.dx = -ball.dx * 1.05
            ball.x = player.x + 5

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end
        if ball:collides(bot) then
            ball.dx = -ball.dx * 1.05
            ball.x = bot.x - 4

            if ball.dy < 0 then
                ball.dy = -math.random(10, 150)
            else
                ball.dy = math.random(10, 150)
            end

            sounds['paddle_hit']:play()
        end

        if ball.y <= 0 then
            ball.y = 0
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
            sounds['wall_hit']:play()
        end

        if ball.x < 0 then
            servingPlayer = 1
            botScore = botScore + 1
            sounds['score']:play()

            if botScore == 10 then
                winningPlayer = 2
                gameState = 'done'
            else
                gameState = 'serve'
                
                ball:reset()
            end
        end

        if ball.x > VIRTUAL_WIDTH then
            servingPlayer = 2
            playerScore = playerScore + 1
            sounds['score']:play()

            if playerScore == 10 then
                winningPlayer = 1
                gameState = 'done'
            else
                gameState = 'serve'
                ball:reset()
            end
        end
    end
    
    --for the paddle controlled by the player (left paddle)
    if love.keyboard.isDown('w') then
        player.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player.dy = PADDLE_SPEED
    else
        player.dy = 0
    end

    --for the paddle contolled by AI (right paddle)
    if gameState == 'play' then
        if ball.y > bot.y and ball.y + ball.height < bot.y  + bot.height then 
            bot.dy = 0
        elseif bot.y > ball.y + ball.height then
            bot.dy = -PADDLE_SPEED
        elseif bot.y + bot.height < ball.y then
        bot.dy = PADDLE_SPEED
        end
    else
        bot.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player:update(dt)
    bot:update(dt)
end

function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        if gameState == 'start' then
            gameState = 'serve'
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == "play" then
            gameState = 'pause'
            ball:reset()
        elseif gameState == 'pause' then
            gameState = 'serve'
        elseif gameState == 'done' then
            gameState = 'serve'

            ball:reset()

            
            playerScore = 0
            botScore = 0

            
            if winningPlayer == 1 then
                servingPlayer = 2
            else
                servingPlayer = 1
            end
        end 
    end
end

function love.draw()
    push:apply('start')

    --for the background color 
    love.graphics.clear(79/255, 98/255, 122/255, 1)

    if gameState == 'start' then
        love.graphics.setFont(smallFont)
        love.graphics.printf('Welcome to Pong!', 0, 10, VIRTUAL_WIDTH, 'center')
        love.graphics.printf('Press Enter to begin!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'serve' then
        love.graphics.setFont(smallFont)
        if servingPlayer == 1 then
            love.graphics.printf("Player's serve", 0, 10, VIRTUAL_WIDTH, 'center')
        else 
            love.graphics.printf("Bot's serve", 0, 10, VIRTUAL_WIDTH, 'center')
        end
        love.graphics.printf('Press Enter to serve!', 0, 20, VIRTUAL_WIDTH, 'center')
    elseif gameState == 'play' then
    elseif gameState == 'done' then
        love.graphics.setFont(largeFont)
        if winningPlayer == 1 then
            love.graphics.printf("Player wins", 0, 10, VIRTUAL_WIDTH, 'center')
        else 
            love.graphics.printf("Bot wins", 0, 10, VIRTUAL_WIDTH, 'center')
        end
        love.graphics.printf('Press Enter to restart!', 0, 30, VIRTUAL_WIDTH, 'center')
    end

    displayScore()

    player:render()
    bot:render()

    ball:render()
    
    displayFPS()
    
    push:apply('end')
end

function displayScore()
    love.graphics.setFont(scoreFont)
    love.graphics.print(tostring(playerScore), VIRTUAL_WIDTH / 2 - 50, VIRTUAL_HEIGHT / 3)
    love.graphics.print(tostring(botScore), VIRTUAL_WIDTH / 2 + 30, VIRTUAL_HEIGHT / 3)
end

function displayFPS()
    love.graphics.setFont(smallFont)
    love.graphics.setColor(0, 255, 0, 255)
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), 10, 10)
    love.graphics.setColor(255, 255, 255, 255)
end