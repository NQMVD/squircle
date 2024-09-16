mem = require'memoize'
stat = require'statistical'
lume = require'lume'
-- needs to be on path
loveframes = require'loveframes'

squircle_radius = 5
angle_res = 0.01
num_squircles = 1

-- TODO add ui for toggles and sliders
-- on/off memoization
-- n slider
-- amount slider for testing fps and mem

function love.conf(t)
  t.window.msaa = 8
  t.window.resizable = true
end

function love.load()
  love.graphics.setBackgroundColor(0.1, 0.1, 0.1)
  love.graphics.setLineWidth(2)
end

function love.update(dt)
  -- suit.layout:reset(10,50,10,10)
  -- n
  -- suit.Label(string.format("n = %d",squircle_radius.value), { align="left" }, suit.layout:col(200, 20))
  -- suit.Slider(squircle_radius, suit.layout:col())
  -- suit.layout:row()
  -- num of squircles
  -- suit.Label(string.format("n = %d",squircle_radius.value), { align="left" }, suit.layout:col(200, 20))
  -- suit.Slider(squircle_radius, suit.layout:col())
  -- suit.layout:row()

  -- suit.layout:reset(10,500,10,10)
end

function love.draw()
  -- stats
  local memoryUsed = collectgarbage("count")
  local stats = string.format("FPS: %d / MEM: %d KB", love.timer.getFPS(), math.floor(memoryUsed))
  love.graphics.print(stats, 10, 10)
  
  -- squircles
  -- love.graphics.rectangle("line", 100, 100, 200, 200, 30)
  love.graphics.setColor(0.2, 0.2, 0.2)
  draw_squircle("fill", 300, 100, 200, squircle_radius.value)
  love.graphics.setColor(0.9, 0.9, 0.9)
  draw_squircle("line", 300, 100, 200, squircle_radius.value)

  -- suit.draw()
end

function get_squircle_coord(w, n, angle)
  return
    (math.pow(math.abs(math.cos(angle)), 2/n) * lume.sign(math.cos(angle))),
    (math.pow(math.abs(math.sin(angle)), 2/n) * lume.sign(math.sin(angle)))
end

mem_squircle_coord = mem(get_squircle_coord)

function get_squircle(w, n)
  local vertices = {}
  for angle=0, math.pi*2, angle_res do
    local x, y = get_squircle_coord(w, n, angle)
    x = x * (w/2)
    y = y * (w/2)
    table.insert(vertices, x)
    table.insert(vertices, y)
  end
  return vertices
end

mem_squircle = mem(get_squircle)

function draw_squircle(mode, x, y, w, n)
  local vertices = get_squircle(w, n)
  -- love.graphics.print("Min/Max: " .. stat.min(vertices) .. "/" .. stat.max(vertices), 10, 30)

  love.graphics.translate(x + w/2,y + w/2)
  love.graphics.polygon(mode, vertices)
  love.graphics.translate(-(x+(w/2)), -(y+(w/2)))
end
