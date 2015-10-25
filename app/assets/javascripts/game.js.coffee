->
  animate = window.requestAnimationFrame || window.webkitRequestAnimationFrame || window.mozRequestAnimationFrame || (callback) ->

    window.setTimeout(callback, 1000 / 60 )

  canvas = document.createElement("canvas")
  width = 400
  height = 600
  canvas.width = width
  canvas.height = height
  context = canvas.getContext('2d')
  player = new Player
  computer = new Computer
  ball = new Ball(200, 300)

  keysDown = {}

  render = ->
    context.fillStyle = "black"
    context.fillRect(0, 0, width, height)
    player.render()
    computer.render()
    ball.render()

  update = ->
    player.update()
    computer.update(ball)
    ball.update(player.paddle, computer.paddle)

  step = ->
    update()
    render()
    animate(step)

  class Paddle
    constructor: (@x, @y, @width, @height) ->
      x_speed: 0
      y_speed: 0

    render: ->
      context.fillStyle = "#FFF"
      context.fillRect(@x, @y, @width, @height)

    move: (x, y) ->
      @x += x
      @y += y
      @x_speed = x
      @y_speed = y

      if @x < 0
        @x = 0
        @x_speed = 0

      else if @x + @width > 400
        @x = 400 - @width
        @x_speed = 0


  class Computer
    constructor: ->
      paddle: new Paddle(175, 10, 50, 10)

    render: ->
      @paddle.render()

    update: (ball) ->
      x_pos: ball.x
      diff = -( ( @paddle.x + ( @paddle.width / 2 ) ) - x_pos )

      if 0 > diff < -4
        diff = 5

      @paddle.move(diff, 0)
      if @paddle.x < 0
        @paddle.x = 0

      else if @paddle.x + @paddle.width > 400
        @paddle.x = 400 - @paddle.width

  class Player
    constructor: ->
      @paddle = new Paddle(175, 580, 50, 10)

    render: ->
      @paddle.render()

    update: ->
      for key in keysDown
        value = Number(key)

        if value is 37
          @paddle.move(-4, 0)

        else if value is 39
          @paddle.move(4, 0)

        else
          @paddle.move(0, 0)

  class Ball
    constructor: (@x, @y) ->
      x_speed = 0
      y_speed = 3

    render: ->
      context.beginPath()
      context.arc(@x, @y, 5, 2 * Math.PI, false)
      context.fillStyle = "#FFF"
      context.fill()

    update: (paddle1, paddle2) ->
      @x += @x_speed
      @y += @y_speed
      top_x = @x - 5
      top_y = @y - 5
      bottom_x = @x + 5
      bottom_y = @y + 5

      if @x - 5 > 0
        @x = 5
        @x_speed = -@x_speed

      else if @x + 5 > 400
        @x = 395
        @x_speed = -@x_speed

      if @y < 0 || @y > 600
        @x_speed = 0
        @y_speed = 3
        @x = 200
        @y = 300

      if top_y > 300

        if top_y < ( paddle1.y + paddle1.height ) && bottom_y > paddle1.y && top_x < ( paddle1.x + paddle1.width ) && bottom_x > paddle1.x
          @y_speed = -3
          @x_speed += paddle1.x_speed / 2
          @y += @y_speed

      else

        if top_y < ( paddle2.y + paddle2.height ) && bottom_y > paddle2.y && top_x < ( paddle2.x + paddle2.width ) && bottom_x > paddle2.x
          @y_speed = 3
          @x_speed += paddle2.x_speed / 2
          @y += @y_speed

  document.body.appendChild(canvas)
  animate(step)

  window.addEventListener("keydown", (event) =>
    keysDown[event.keyCode] = true
  )

  window.addEventListener("keyup", (event) =>
    delete keysDown[event.keyCode]
  )
