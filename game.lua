-------------------------------------------------
------------------- Singleton -------------------
----------------- TIC-80 SCREEN -----------------
-------------------------------------------------
Screen = {
	width = 240, height = 136,		-- 240x136 display
	refresh_rate = 60 				-- 60Hz refresh rate
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

-------------------------------------------------
-------------------- Hit Box --------------------
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

function detect_collision(hit_box_1, hit_box_2)
	if hit_box_1.x1 > hit_box_2.x2 then return false end -- 1 is right of 2
	if hit_box_1.x2 < hit_box_2.x1 then return false end -- 1 is left of 2
	if hit_box_1.y1 > hit_box_2.y2 then return false end -- 1 is under 2
	if hit_box_1.y2 < hit_box_2.y1 then return false end -- 1 is above 2
	return true -- if all else fails, there has-- Singleton
end

-------------------------------------------------
-------------------- Enemy ----------------------
-------------------------------------------------
Enemy = {
    x,
    y,
    width,
    height,
    hitbox
}
-- CONSTRUCTOR --
Enemy.__index = Enemy
function Enemy:new()
	local e = {}			  	-- our new object
    setmetatable(e, Enemy)	-- make Enemy handle lookup
    e.x = math.random(0,240)
    e.y = math.random(0,136)
    e.width = 2
    e.height = 2
    e.hitbox = HitBox:new(e.x,e.y,e.x+e.width,e.y+e.height)
	return e
end

function Enemy:draw()
    spr(1,self.x,self.y,-1,1,0,0,self.width,self.height)
end

function Enemy:move()
    if time % 60 == 0 then
        new_x = self.x + math.random(-1,1)
        new_y = self.y + math.random(-1,1)
        
        if new_x > 0 and new_x < 240 then
            self.x = new_x
        end
        
        if new_y > 0 and new_y < 136 then
            self.y = new_y
        end
    
        self.hitbox.x1 = new_x
        self.hitbox.y1 = new_y
        self.hitbox.x2 = new_x + self.width
        self.hitbox.y2 = new_y + self.height
    end
end

-------------------------------------------------
-------------------- Hero -----------------------
-------------------------------------------------
Hero = {  
    x,
    y,
    width,
    height,
    hitbox
}
-- CONSTRUCTOR --
Hero.__index = Hero
function Hero:new()
	local h = {}			  	-- our new object
    setmetatable(h, Hero)	-- make Hero handle lookup
    h.x = math.random(0,240)
    h.y = math.random(0,136)
    h.width = 2
    h.height = 2
    h.hitbox = HitBox:new(h.x,h.y,h.x+h.width,h.y+h.height)
	return h
end

function Hero:draw()
    spr(3,self.x,self.y,-1,1,0,0,self.width,self.height)
end

function Hero:move()
    new_x = self.x
    new_y = self.y

    if key(1) then
        new_x = self.x - 1
    end

    if key(4) then
        new_x = self.x + 1
    end

    if key(19) then
        new_y = self.y + 1
    end

    if key(23) then
        new_y = self.y - 1
    end

    if new_x > 0 and new_x < 240 then
        self.x = new_x
    end

    if new_y > 0 and new_y < 136 then
        self.y = new_y
    end

    self.hitbox.x1 = new_x
    self.hitbox.y1 = new_y
    self.hitbox.x2 = new_x + self.width
    self.hitbox.y2 = new_y + self.height
end

function Hero:punch()
    if key(48) then
        spr(3,self.x,self.y,-1,1,0,0,3,2)
    end
end

function tablelength(T)
    local length = 0
    for _ in pairs(T) do length = length + 1 end
    return length
end

time = 0
hero = Hero:new()
enemy = Enemy:new()

function TIC()
    time = time + 1
    Screen:clear()
    hero:move()
    hero:draw()
    hero:punch()
    if detect_collision(hero.hitbox,enemy.hitbox) then
        print("Ouch!",hero.x+20,hero.y)
    end
    enemy:move()
    enemy:draw()
    if detect_collision(hero.hitbox,enemy.hitbox) then
        print("Ouch!",enemy.x-30,enemy.y)
    end
    print(hero.hitbox.x1,0,110)
    print(enemy.hitbox.x2,30,110)
end
