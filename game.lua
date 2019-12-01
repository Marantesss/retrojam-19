-------------------------------------------------
------------------- Singleton -------------------
----------------- TIC-80 SCREEN -----------------
-------------------------------------------------
Screen = {
	width = 240, height = 136,		-- 240x136 display
    refresh_rate = 60, 				-- 60Hz refresh rate
    pixels_per_square = 8           -- pixels per sprite square
}
-- clear screen
function Screen:clear() cls() end

-------------------------------------------------
------------------- Singleton -------------------
---------------- TIC-80 KEYBOARD ----------------
-------------------------------------------------
-- TIC-80 Keyboard
Keyboard = {}
-- WASD
function Keyboard:w_key() return key(23) end
function Keyboard:a_key() return key(1) end
function Keyboard:s_key() return key(19) end
function Keyboard:d_key() return key(4) end
-- ARROW KEYS
function Keyboard:up_key() return key(58) end
function Keyboard:down_key() return key(59) end
function Keyboard:left_key() return key(60) end
function Keyboard:right_key() return key(61) end
-- MISC
function Keyboard:space_key() return key(48) end
function Keyboard:space_keyp() return keyp(48) end

-------------------------------------------------
-------------------- HEADER ---------------------
-------------------------------------------------
Header = {
    sanity,     -- Sanity level 
    battery     -- Headphone battery level
}
-- CONSTRUCTOR --
Header.__index = Header
function Header:new()
	local h = {}			  	-- our new object
    setmetatable(h, Header)	-- make Header handle lookup
    h.sanity = Bar:new(100)
    h.battery = Bar:new(0)
	return h
end

function Header:update()
    self.sanity.level = Game.Dong.sanity
    self.battery.level = Game.Dong.battery
end

-------------------------------------------------
--------------- SANITY & BATTERY ----------------
-------------------------------------------------
Bar = {
    x, y,
    sprite_index, width, height,
    level
}
-- CONSTRUCTOR --
Bar.__index = Bar
function Bar:new(x)
	local b = {}			  	-- our new object
    setmetatable(b, Bar)	-- make Bar handle lookup
    b.x = x
    b.y = 0
    b.width = 1
    b.height = 1
    b.sprite_index = 1
    b.level = 10
	return b
end
-- METHODS --
function Bar:draw()
    for i=0, self.level - 1 do
        spr(self.sprite_index,self.x+i*8,self.y,-1,1,0,0,self.width,self.height)
    end
end

-------------------------------------------------
-------------------- HIT BOX --------------------
-------------------------------------------------
HitBox = {
	x1, y1, -- upper-left coordinates
	x2, y2	-- lower-right coordinates
}
-- CONSTRUCTOR --
HitBox.__index = HitBox
function HitBox:new(x1,x2,y1,y2)
	local hb = {}			  	-- our new object
    setmetatable(hb, HitBox)	-- make HitBox handle lookup
    hb.x1 = x1
    hb.x2 = x2
    hb.y1 = y1
    hb.y2 = y2
	return hb
end
-- METHODS
function detect_collision(hit_box_1, hit_box_2)
	if hit_box_1.x1 > hit_box_2.x2 then return false end -- 1 is right of 2
	if hit_box_1.x2 < hit_box_2.x1 then return false end -- 1 is left of 2
	if hit_box_1.y1 > hit_box_2.y2 then return false end -- 1 is under 2
	if hit_box_1.y2 < hit_box_2.y1 then return false end -- 1 is above 2
	return true -- if all else fails, there has been collision
end

-------------------------------------------------
-------------------- ENEMY ----------------------
-------------------------------------------------
Enemy = {
    x, y,                         -- coords
    sprite_index, width, height,  -- sprite index and blocks
    hitbox,                       -- collision
    reflected
}
-- CONSTRUCTOR --
Enemy.__index = Enemy
function Enemy:new()
	local e = {}			  	    -- our new object
    setmetatable(e, Enemy)	        -- make Enemy handle lookup
    e.x = math.random(0, Screen.width)
    e.y = math.random(8, Screen.height)
    e.width = 2
    e.height = 2
    e.sprite_index = 264
    e.hitbox = HitBox:new(e.x, e.y, e.x + e.width * Screen.pixels_per_square, e.y + e.height * Screen.pixels_per_square)
    e.reflected = 0
    return e
end
-- METHODS --
function Enemy:draw()
    spr(self.sprite_index, self.x, self.y, 12, 1, self.reflected, 0, self.width, self.height)
end

function Enemy:move()
    if Game.time % 60 == 0 then -- move per second
        local new_x = self.x + math.random(-1,1)
        local new_y = self.y + math.random(-1,1)
        local offset_x = self.width * Screen.pixels_per_square;
        local offset_y = self.height * Screen.pixels_per_square;
        -- update reflected
        self.reflected = math.random(0,1)
        -- out of bounds
        if new_x > 0 and new_x + offset_x < Screen.width then self.x = new_x end
        if new_y > 8 and new_y + offset_y < Screen.height then self.y = new_y end
        -- update collision
        self.hitbox.x1 = new_x
        self.hitbox.y1 = new_y
        self.hitbox.x2 = new_x + offset_x
        self.hitbox.y2 = new_y + offset_y
    end
end

-------------------------------------------------
-------------------- Dong -----------------------
-------------------------------------------------
Dong = {  
    x, y,                                       -- coords
    current_sprite_index, sprite_indexes,       -- Sprite indexes
    width, height,                              -- sprite blocks
    hitbox,                                     -- collision
    reflected,
    sanity,
    battery,
    headphone_on                                -- headphones
}
-- CONSTRUCTOR --
Dong.__index = Dong
function Dong:new()
	local h = {}
    setmetatable(h, Dong)
    h.x = Screen.width / 2
    h.y = Screen.height / 2
    h.width = 2
    h.height = 2
    h.current_sprite_index = 256
    h.sprite_indexes = {256, 258, 260, 262, 264}
    h.reflected = 0
    h.sanity = 10
    h.battery = 10
    h.headphone_on = false
    h.hitbox = HitBox:new(h.x, h.y, h.x + h.width * Screen.pixels_per_square, h.y + h.height * Screen.pixels_per_square)
	return h
end
-- METHODS --
function Dong:draw()
    spr(self.current_sprite_index, self.x, self.y, 12, 1, self.reflected, 0, self.width, self.height)
end

function Dong:move()
    local new_x = self.x
    local new_y = self.y
    local offset_x = self.width * Screen.pixels_per_square
    local offset_y = self.height * Screen.pixels_per_square
    local is_moving = false
    self.current_sprite_index = 256
    -- movement
    if Keyboard.a_key() then
        new_x = self.x - 1
        self.reflected = 1
        is_moving = true
    end
    if Keyboard.d_key() then
        new_x = self.x + 1
        self.reflected = 0
        is_moving = true
    end
    if Keyboard.s_key() then
        new_y = self.y + 1
        is_moving = true
    end
    if Keyboard.w_key() then
        new_y = self.y - 1
        is_moving = true
    end
    -- out of bounds
    if new_x > 0 and new_x + offset_x < Screen.width then self.x = new_x end
    if new_y > 10 and new_y + offset_y < Screen.height then self.y = new_y end
    -- update collision
    self.hitbox.x1 = new_x
    self.hitbox.y1 = new_y
    self.hitbox.x2 = new_x + offset_x
    self.hitbox.y2 = new_y + offset_y

    -- animate
    if is_moving then
        -- change sprite
        if Game.time % 30 < 15 then self.current_sprite_index = 256
        else self.current_sprite_index = 258 end
    end
    -- headphone
    if self.headphone_on then
        self.current_sprite_index = self.current_sprite_index + 4
    end
end

function Dong:action()
    if Keyboard.space_keyp() and self.battery > 0 then
        self.headphone_on = not(self.headphone_on)
    end

    if self.battery == 0 then
        self.headphone_on = false
    end
end

function tablelength(T)
    local length = 0
    for _ in pairs(T) do length = length + 1 end
    return length
end

-------------------------------------------------
------------------ Singleton --------------------
-------------------- GAME -----------------------
-------------------------------------------------
Game = {
    time = 0,               -- time passed
    Dong = Dong:new(),      -- Dong
    enemy = Enemy:new(),    -- enemies array EVENTUALLY
    header = Header:new()   -- Header with game information
}

-------------------------------------------------
----------------- GAME LOOP ---------------------
-------------------------------------------------
function TIC()
    Screen:clear()
    Game.header:update()
    Game.header.battery:draw()
    Game.header.sanity:draw()
    print("Battery:", 1, 2, 6)
    print(Game.Dong.battery*10, 48, 2, 6)
    print("Sanity:", 101, 2, 6)
    print(Game.Dong.sanity*10, 138, 2, 6)
    Game.Dong:move()
    Game.Dong:draw()
    Game.Dong:action()
    if Game.time % 60 == 0 then
        if Game.Dong.headphone_on and Game.Dong.battery > 0 then
            Game.Dong.battery = Game.Dong.battery - 1
        elseif not(Game.Dong.headphone_on) and Game.Dong.battery < 10 then
            Game.Dong.battery = Game.Dong.battery + 1
        end
    end
    if detect_collision(Game.Dong.hitbox, Game.enemy.hitbox) and Game.Dong.sanity > 0 then
        Game.Dong.sanity = Game.Dong.sanity - 1
    end
    Game.enemy:move()
    Game.enemy:draw()
    if detect_collision(Game.Dong.hitbox, Game.enemy.hitbox) and Game.Dong.sanity > 0 then
        Game.Dong.sanity = Game.Dong.sanity - 1
    end
    Game.time = Game.time + 1
end
