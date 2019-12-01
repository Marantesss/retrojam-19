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
    h.sanity = Bar:new()
    h.battery = Bar:new()
	return h
end

-------------------------------------------------
-------------------- SANITY --------------------
-------------------------------------------------
Bar = {
    x, y,
    sprite_index, width, height,
    level
}
-- CONSTRUCTOR --
Bar.__index = Bar
function Bar:new()
	local b = {}			  	-- our new object
    setmetatable(b, Bar)	-- make Bar handle lookup
    b.x = 0
    b.y = 0
    b.width = 1
    b.height = 1
    b.sprite_index = 6
    b.level = 10
	return b
end
-- METHODS --
function Bar:draw()
    for i=1, self.level do
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
    hitbox  ,                      -- collision
    messagesAttack
}
MessagesAttack = {
    x ,y,                         -- coords
    sprite_index, width, height,  -- sprite index and blocks
    hitbox,                       -- collision
    old_x, old_y,                 -- old posiiton
    was_moving,                   -- was moving
    go_out_x, go_out_y            -- to go outbounds

}
MessagesAttack.__index = MessagesAttack
function MessagesAttack:new(x,y)
	local e = {}			  	    -- our new object
    setmetatable(e, MessagesAttack)	        -- make MessagesAttack handle lookup
    e.x = x
    e.y = y
    e.width = 1
    e.height = 1
    e.sprite_index = 416
    e.hitbox = HitBox:new(e.x, e.y, e.x + e.width * Screen.pixels_per_square, e.y + e.height * Screen.pixels_per_square)
    e.old_x = x
    e.old_y = y
    e.was_moving = false
    e.go_out_x = false
    e.go_out_y = false
	return e
end

-- CONSTRUCTOR --
Enemy.__index = Enemy
function Enemy:new()
	local e = {}			  	    -- our new object
    setmetatable(e, Enemy)	        -- make Enemy handle lookup
    e.x = math.random(0, Screen.width)
    e.y = math.random(0, Screen.height)
    e.width = 2
    e.height = 2
    e.sprite_index = 1
    e.hitbox = HitBox:new(e.x, e.y, e.x + e.width * Screen.pixels_per_square, e.y + e.height * Screen.pixels_per_square)
    e.messagesAttack = MessagesAttack:new(e.x,e.y)
    return e
end
-- METHODS --
function Enemy:draw()
    spr(self.sprite_index, self.x, self.y, -1, 1, 0, 0, self.width, self.height)
end

function Enemy:move()
    if Game.time % 4 == 0 then -- move per 
        local new_x = self.x
        local new_y = self.y
        --if Game.hero.x > self.x then  new_x = self.x + 1
        --elseif Game.hero.x < self.x then new_x = self.x - 1 end 
        --if Game.hero.y > self.y then new_y = self.y + 1 
        --elseif Game.hero.y < self.y then new_y = self.y - 1 end 
       -- local new_x = self.x + math.random(-1,1)
       -- local new_y = self.y + math.random(-1,1)
        local offset_x = self.width * Screen.pixels_per_square;
        local offset_y = self.height * Screen.pixels_per_square;
        -- out of bounds
        if new_x > 0 and new_x + offset_x < Screen.width then self.x = new_x end
        if new_y > 0 and new_y + offset_y < Screen.height then self.y = new_y end
        -- update collision
        self.hitbox.x1 = new_x
        self.hitbox.y1 = new_y
        self.hitbox.x2 = new_x + offset_x
        self.hitbox.y2 = new_y + offset_y
    end
end

function MessagesAttack:move()
    print(self.go_out_x,0,100)
    print(self.go_out_y,0,110)
    print(self.old_x,0,120)
    print(self.x,20,120)
    print(self.old_y,0,130)
    print(self.y,20,130)
    print(Game.hero.y, 40,120)
    print(Game.hero.x, 40,130)
    --if Game.time % 2 == 0 then
        local new_x = self.x 
        local new_y = self.y
        if self.go_out_x then if self.old_x >= self.x then new_x = self.x-1 else new_x = self.x +1 end end
        if self.go_out_y then if self.old_y >= self.y then new_y = self.y-1 else new_y = self.y +1 end end
        if Game.hero.x >= self.x and not self.go_out_x then  new_x = self.x + 1 self.go_out_x = true
        elseif Game.hero.x < self.x and not self.go_out_x then new_x = self.x - 1 self.go_out_x = true end 
        if Game.hero.y >= self.y and not self.go_out_y then new_y = self.y + 1 self.go_out_y = true
        elseif Game.hero.y < self.y and not self.go_out_y then new_y = self.y - 1 self.go_out_y = true end 
        local offset_x = self.width * Screen.pixels_per_square;
        local offset_y = self.height * Screen.pixels_per_square;
        if (new_x > 0 or new_x < 0) and new_x + offset_x < Screen.width then self.x = new_x else resetMessagesAttack(self) end
        if (new_y > 0 or new_y < 0) and new_y + offset_y < Screen.height then self.y = new_y else resetMessagesAttack(self) end
        self.hitbox.x1 = new_x
        self.hitbox.y1 = new_y
        self.hitbox.x2 = new_x + offset_x
        self.hitbox.y2 = new_y + offset_y
   -- end
end

function resetMessagesAttack(self) 
    self.x = Game.enemy.x
    self.y = Game.enemy.y
    self.old_x = Game.enemy.x
    self.old_y = Game.enemy.y
    self.go_out_x = false
    self.go_out_y = false
end

function MessagesAttack:draw()
    spr(self.sprite_index, self.x, self.y, -1, 1, 0, 0, self.width, self.height)
end

-------------------------------------------------
-------------------- HERO -----------------------
-------------------------------------------------
Hero = {  
    x, y,                         -- coords
    sprite_index, width, height,  -- sprite index and blocks
    hitbox                        -- collision
}
-- CONSTRUCTOR --
Hero.__index = Hero
function Hero:new()
	local h = {}
    setmetatable(h, Hero)
    h.x = math.random(0, Screen.width)
    h.y = math.random(0, Screen.height)
    h.width = 2
    h.height = 2
    h.sprite_index = 3
    h.hitbox = HitBox:new(h.x, h.y, h.x + h.width * Screen.pixels_per_square, h.y + h.height * Screen.pixels_per_square)
	return h
end
-- METHODS --
function Hero:draw()
    spr(self.sprite_index, self.x, self.y, -1, 1, 0, 0, self.width, self.height)
end

function Hero:move()
    local new_x = self.x
    local new_y = self.y
    local offset_x = self.width * Screen.pixels_per_square
    local offset_y = self.height * Screen.pixels_per_square
    -- movement
    if Keyboard.a_key() then new_x = self.x - 1 end
    if Keyboard.d_key() then new_x = self.x + 1 end
    if Keyboard.s_key() then new_y = self.y + 1 end
    if Keyboard.w_key() then new_y = self.y - 1 end
    -- out of bounds
    if new_x > 0 and new_x + offset_x < Screen.width then self.x = new_x end
    if new_y > 0 and new_y + offset_y < Screen.height then self.y = new_y end
    -- update collision
    self.hitbox.x1 = new_x
    self.hitbox.y1 = new_y
    self.hitbox.x2 = new_x + offset_x
    self.hitbox.y2 = new_y + offset_y
end

function Hero:punch()
    if Keyboard.space_key() then
        spr(self.sprite_index, self.x, self.y, -1, 1, 0, 0, 3, 2)
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
    hero = Hero:new(),      -- hero
    enemy = Enemy:new(),    -- enemies array EVENTUALLY
    header = Header:new(),   -- Header with game information
}

-------------------------------------------------
----------------- GAME LOOP ---------------------
-------------------------------------------------
function TIC()
    Game.time = Game.time + 1
    print(Game.time, 20, 20)
    Screen:clear()
    Game.hero:move()
    Game.hero:draw()
    Game.hero:punch()
    if detect_collision(Game.hero.hitbox, Game.enemy.hitbox) then
        print("ouch")
        -- do stuff
    end
    Game.enemy:move()
    Game.enemy:draw()
    Game.enemy.messagesAttack:move()
    Game.enemy.messagesAttack:draw()
    if detect_collision(Game.hero.hitbox, Game.enemy.messagesAttack.hitbox) then
        print("hi")
        -- do stuff
    end
end
