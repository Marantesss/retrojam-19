-------------------------------------------------
------------------- Singleton -------------------
----------------- TIC-80 SCREEN -----------------
-------------------------------------------------
cam = {
    x,y
}
Stage = {
    stage, old_stage
}

Stage.__index = Stage
function Stage:new()
	local h = {}			  	        -- our new object
    setmetatable(h, Stage)	            -- make Stage handle lookup
    h.stage = "room"
    return h
end
function Stage:whereIsStage() 
    self.old_stage = self.stage
    if Game.cam.x >= 60*8 and Game.cam.x < 90*8 and Game.cam.y >= 51*8 and Game.cam.y < 68*8 then
        self.stage = "death"
    elseif Game.cam.x == 0 and Game.cam.x == 0 then
        self.stage = "room"
    elseif Game.cam.x >= 240 and Game.cam.x < 720 and Game.cam.y >= 0 and Game.cam.y < 272 or Game.cam.x >= 720 and Game.cam.x < 960 and Game.cam.y >= 0 and Game.cam.y < 136 then
        self.stage = "street"
    elseif Game.cam.x >= 720 and Game.cam.x < 960 and Game.cam.y >= 0 and Game.cam.y < 136 then
        self.stage = "dry_cleaners"
    end

    if(self.old_stage ~= self.stage) then
        Game:reset_enemies()
    end
end

Screen = {
	width = 240, height = 136,		-- 240x136 display
    refresh_rate = 60, 				-- 60Hz refresh rate
    pixels_per_square = 8,          -- pixels per sprite square
    transparent_color = 12,         -- palette color ID for transparency
    -- MAPS
    -- room
    stage_0_0 = {x1 = 0, y1 = 0, x2 = 30 * 8 - 1, y2 = 17 * 8 - 1},
    -- top street
    stage_1_0 = {x1 = 30 * 8 * 1, y1 = 0, x2 = 30 * 8 * 2 - 1, y2 = 17 * 8 - 1},
    stage_2_0 = {x1 = 30 * 8 * 2, y1 = 0, x2 = 30 * 8 * 3 - 1, y2 = 17 * 8 - 1},
    stage_3_0 = {x1 = 30 * 8 * 3, y1 = 0, x2 = 30 * 8 * 4 - 1, y2 = 17 * 8 - 1},
    -- dry cleaners
    stage_4_0 = {x1 = 30 * 8 * 4, y1 = 0, x2 = 30 * 8 * 5 - 1, y2 = 17 * 8 - 1},
    -- middle street
    stage_1_1 = {x1 = 30 * 8 * 1, y1 = 17 * 8 * 1, x2 = 30 * 8 * 2 - 1, y2 = 17 * 8 * 2 - 1},
    stage_2_2 = {x1 = 30 * 8 * 2, y1 = 17 * 8 * 1, x2 = 30 * 8 * 3 - 1, y2 = 17 * 8 * 2 - 1},
    stage_3_3 = {x1 = 30 * 8 * 3, y1 = 17 * 8 * 1, x2 = 30 * 8 * 4 - 1, y2 = 17 * 8 * 2 - 1}
    -- bank
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
--------------- SANITY & BATTERY ----------------
-------------------------------------------------
Bar = {
    x, y,
    sprite_index,
    width, height,
    title, level 
}
-- CONSTRUCTOR --
Bar.__index = Bar
function Bar:new(title, x)
	local b = {}			-- our new object
    setmetatable(b, Bar)	-- make Bar handle lookup
    b.x = x
    b.y = 0
    b.width = 1
    b.height = 1
    b.title = title
    b.sprite_index = 1
    b.level = 10
	return b
end
-- METHODS --
function Bar:draw()
    for i=0, self.level - 1 do
        spr(self.sprite_index,self.x+i*8,self.y,-1,1,0,0,self.width,self.height)
    end
    print(self.title, self.x + 2, 2, 6)
    print(self.level * 10, self.x + 60, 2, 6)
end

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
	local h = {}			  	        -- our new object
    setmetatable(h, Header)	            -- make Header handle lookup
    h.sanity = Bar:new("Sanity", 100)   -- Sanity bar
    h.battery = Bar:new("Battery", 0)   -- Battery bar
	return h
end
-- METHODS --
function Header:update()
    self.sanity.level = Game.dong.sanity
    self.battery.level = Game.dong.battery
end

function Header:draw()
    if(Game.stage.stage ~= "death") then
    self.battery:draw() -- battery
    self.sanity:draw()  -- sanity
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
function HitBox:new(x1, y1, x2, y2)
	local hb = {}			  	-- our new object
    setmetatable(hb, HitBox)	-- make HitBox handle lookup
    hb.x1 = x1  -- top left coords
    hb.y1 = y1
    hb.x2 = x2  -- bottom right coords
    hb.y2 = y2
	return hb
end

-------------------------------------------------
------------------ SAFE SPACE -------------------
-------------------------------------------------
SafeSpace = {
    x, y,                           -- coordinates
    sprite_index, width, height,    -- sprite index and blocks
	hitbox                          -- collision
}
-- CONSTRUCTOR --
SafeSpace.__index = SafeSpace
function SafeSpace:new(x, y, sprite_index, width, height)
	local ss = {}			  	-- our new object
    setmetatable(ss, SafeSpace)	-- make SafeSpace handle lookup
    ss.x = x
    ss.y = y
    ss.width = width
    ss.height = height
    ss.sprite_index = sprite_index
    ss.hitbox = HitBox:new(ss.x, ss.y, ss.x + ss.width * Screen.pixels_per_square, ss.y + ss.height * Screen.pixels_per_square)
	return ss
end
-- METHODS --
function SafeSpace:draw()
    spr(self.sprite_index, self.x % Screen.width, self.y % Screen.height, Screen.transparent_color, 1, self.reflected, 0, self.width, self.height)
end

-------------------------------------------------
-------------------- ENEMY ----------------------
-------------------------------------------------
Enemy = {
    x, y,                         -- coords
    current_sprite_index,       -- Sprite indexes
    width, height,  -- sprite index and blocks
    hitbox,                       -- collision
    reflected,
    message_attacks
}

-- CONSTRUCTOR --
Enemy.__index = Enemy
function Enemy:new()
	local e = {}			  	    -- our new object
    setmetatable(e, Enemy)	        -- make Enemy handle lookup
    e.x = 144 * Screen.pixels_per_square
    e.y = 8 * Screen.pixels_per_square
    e.width = 2
    e.height = 4
    e.current_sprite_index = 360
    e.hitbox = HitBox:new(e.x, e.y, e.x + e.width * Screen.pixels_per_square, e.y + e.height * Screen.pixels_per_square)
    e.reflected = 0
    e.message_attacks = {}
    return e
end

-- METHODS --
function Enemy:draw()
    if(Game.stage.stage == "dry_cleaners") then
        if (0 + self.x // Screen.width * Screen.width == cam.x and 0 + (self.y // Screen.height * Screen.height) == cam.y) then
            -- draw enemy
            spr(self.current_sprite_index, self.x % Screen.width, self.y % Screen.height, Screen.transparent_color, 1, self.reflected, 0, self.width, self.height)
            -- draw bullets
            for _,  attack in pairs(self.message_attacks) do
                attack:draw()
            end
        end
    end
end

function Enemy:move()
    if Game.time % 4 == 0 and Game.stage.stage == "dry_cleaners" then -- move per 
        local new_x = self.x
        local new_y = self.y
        if Game.dong.x > self.x then  new_x = self.x + 1
        elseif Game.dong.x < self.x then new_x = self.x - 1 end 
        if Game.dong.y > self.y then new_y = self.y + 1 
        elseif Game.dong.y < self.y then new_y = self.y - 1 end 
       -- local new_x = self.x + math.random(-1,1)
       -- local new_y = self.y + math.random(-1,1)
        local offset_x = self.width * Screen.pixels_per_square;
        local offset_y = self.height * Screen.pixels_per_square;
        -- update reflected
        self.reflected = math.random(0,1)
        -- out of bounds
        if solid_tiles(new_x, new_y) then
            new_x = self.x new_y = self.y
            --print("ok",0,100)
        else
            self.x = new_x self.y = new_y 
        end
        -- update collision
        self.hitbox.x1 = new_x
        self.hitbox.y1 = new_y
        self.hitbox.x2 = new_x + offset_x
        self.hitbox.y2 = new_y + offset_y
    end
    -- spawn attack every 120 tics (2 seconds)
    if Game.time % 120 == 0 then
        self:fire()
    end
    -- spawn super attack every 300 tics (5 seconds)
    if (Game.time + 150) % 300 == 0 then
        self:super_fire()
    end
    -- animate
    -- change sprite
    if Game.time % 30 < 15 then self.current_sprite_index = 360
    else self.current_sprite_index = 362 end
    
    -- update attacks
    local it = 1
    while it <= #self.message_attacks do
        self.message_attacks[it]:update()
        -- attack out of bounds
        if Game:out_of_bounds(self.message_attacks[it].hitbox) then
            table.remove(self.message_attacks, it)
        else
            it = it + 1
        end
    end
end

function Enemy:fire()
    --get fire direction
    local distance = math.sqrt(math.pow(self.x - Game.dong.x, 2) + math.pow(self.y - Game.dong.y, 2))
    local vx = (Game.dong.x - self.x) / distance
    local vy = (Game.dong.y - self.y) / distance

    table.insert(self.message_attacks, MessagesAttack:new(self.x, self.y, vx, vy))
end

function Enemy:super_fire()
    table.insert(self.message_attacks, MessagesAttack:new(self.x, self.y, 1, 0))    -- right
    table.insert(self.message_attacks, MessagesAttack:new(self.x, self.y, -1, 0))   -- left
    table.insert(self.message_attacks, MessagesAttack:new(self.x, self.y, 0, -1))   -- up
    table.insert(self.message_attacks, MessagesAttack:new(self.x, self.y, 0, 1))    -- down
end

-------------------------------------------------
-------------------- ROAMER ---------------------
-------------------------------------------------
Roamer = {
    x, y,                         -- coords
    sprite_index, width, height,  -- sprite index and blocks
    hitbox,                       -- collision
    reflected
}

-- CONSTRUCTOR --
Roamer.__index = Roamer
function Roamer:new()
	local e = {}			  	    -- our new object
    setmetatable(e, Roamer)	        -- make Roamer handle lookup
    e.x = 49 * 8
    e.y = 7*8
    e.width = 2
    e.height = 2
    e.sprite_index = 264
    e.hitbox = HitBox:new(e.x, e.y, e.x + e.width * Screen.pixels_per_square, e.y + e.height * Screen.pixels_per_square)
    e.reflected = 0
    return e
end

-- METHODS --
function Roamer:draw()
    if(Game.stage.stage == "street") then
        if (0 + self.x // Screen.width * Screen.width == cam.x and 0 + (self.y // Screen.height * Screen.height) == cam.y) then
            -- draw enemy
            spr(self.sprite_index, self.x % Screen.width, self.y % Screen.height, Screen.transparent_color, 1, self.reflected, 0, self.width, self.height)
        end
    end
end

function Roamer:move()
    if Game.time % 4 == 0 and Game.stage.stage == "street"  then -- move per 
        local new_x = self.x
        local new_y = self.y
        if Game.dong.x > self.x then  new_x = self.x + 1
        elseif Game.dong.x < self.x then new_x = self.x - 1 end 
        if Game.dong.y > self.y then new_y = self.y + 1 
        elseif Game.dong.y < self.y then new_y = self.y - 1 end 
       -- local new_x = self.x + math.random(-1,1)
       -- local new_y = self.y + math.random(-1,1)
        local offset_x = self.width * Screen.pixels_per_square;
        local offset_y = self.height * Screen.pixels_per_square;
        -- update reflected
        self.reflected = math.random(0,1)
        -- out of bounds
        if solid_tiles(new_x, new_y) then
            new_x = self.x new_y = self.y
            --print("ok",0,100)
        else
            self.x = new_x self.y = new_y 
        end
        -- update collision
        self.hitbox.x1 = new_x
        self.hitbox.y1 = new_y
        self.hitbox.x2 = new_x + offset_x
        self.hitbox.y2 = new_y + offset_y
    end
end

-------------------------------------------------
---------------- ENEMY ATTACK -------------------
-------------------------------------------------
MessagesAttack = {
    x, y,                         -- coords
    vx, vy,                       -- speed
    sprite_index, width, height,  -- sprite index and blocks
    hitbox,                       -- collision
}
-- CONSTRUCTOR --
MessagesAttack.__index = MessagesAttack
function MessagesAttack:new(x, y, vx, vy)
	local ma = {}			  	        -- our new object
    setmetatable(ma, MessagesAttack)    -- make MessagesAttack handle lookup
    ma.x = x
    ma.y = y
    ma.vx = vx
    ma.vy = vy
    ma.width = 1
    ma.height = 1
    ma.sprite_index = 416
    ma.hitbox = HitBox:new(ma.x, ma.y, ma.x + ma.width * Screen.pixels_per_square, ma.y + ma.height * Screen.pixels_per_square)
	return ma
end
-- METHODS --
function MessagesAttack:update()
    local offset_x = self.width * Screen.pixels_per_square;
    local offset_y = self.height * Screen.pixels_per_square;
    
    self.x = self.x + self.vx
    self.y = self.y + self.vy
    
    self.hitbox.x1 = self.x
    self.hitbox.y1 = self.y
    self.hitbox.x2 = self.x + offset_x
    self.hitbox.y2 = self.y + offset_y
end

function MessagesAttack:draw()
    spr(self.sprite_index, self.x, self.y, -1, 1, 0, 0, self.width, self.height)
end

-------------------------------------------------
-------------- HeadphoneShield ------------------
-------------------------------------------------
HeadphoneShield = {
    x, y,                                       -- coords
    current_sprite_index,                       -- Sprite indexes
    width, height,                              -- sprite blocks
}
-- CONSTRUCTOR --
HeadphoneShield.__index = HeadphoneShield
function HeadphoneShield:new(x, y)
	local hs = {}
    setmetatable(hs, HeadphoneShield)
    hs.width = 4
    hs.height = 4
    hs.x = x - hs.width / 3.8 * Screen.pixels_per_square
    hs.y = y - hs.height / 3.8 * Screen.pixels_per_square
    hs.current_sprite_index = 356
	return hs
end

function HeadphoneShield:move(x, y)
    self.x = x - self.width / 3.8 * Screen.pixels_per_square
    self.y = y - self.height / 3.8 * Screen.pixels_per_square
end

function HeadphoneShield:draw()
    spr(self.current_sprite_index, self.x % Screen.width, self.y % Screen.height, Screen.transparent_color, 1, self.reflected, 0, self.width, self.height)
end

-------------------------------------------------
-------------------- Dong -----------------------
-------------------------------------------------
Dong = {  
    x, y,                                       -- coords
    current_sprite_index, sprite_indexes,       -- Sprite indexes
    width, height,                              -- sprite blocks
    hitbox,                                     -- collision
    reflected,                                  -- reflectd sprite
    sanity, battery,                            -- hp and shiled 
    headphones_on,                              -- headphones
    heaphone_shield                             -- protection
}
-- CONSTRUCTOR --
Dong.__index = Dong
function Dong:new()
	local h = {}
    setmetatable(h, Dong)
    h.x = 1*8
    h.y = 7*8
    h.width = 2
    h.height = 2
    h.current_sprite_index = 256
    h.sprite_indexes = {256, 258, 260, 262, 264}
    h.reflected = 0
    h.sanity = 10
    h.battery = 10
    h.headphones_on = false
    h.hitbox = HitBox:new(h.x, h.y, h.x + h.width * Screen.pixels_per_square, h.y + h.height * Screen.pixels_per_square)
    h.heaphone_shield = HeadphoneShield:new(h.x, h.y)
    return h
end
-- METHODS --
function Dong:draw()
    if Game.stage.stage ~= "death" then
    spr(self.current_sprite_index, self.x % Screen.width, self.y % Screen.height, Screen.transparent_color, 1, self.reflected, 0, self.width, self.height)

    if self.headphones_on then
        self.heaphone_shield:draw()
    end
end
end

function Dong:move()
    if(Mom.drew == 0 and Game.stage.stage ~= "death") then
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
    if solid_tiles(new_x, new_y) then
        new_x = self.x new_y = self.y
        --print("ok",0,100)
    else
      self.x = new_x self.y = new_y 
    end
    -- update headphones
    self.heaphone_shield:move(self.x, self.y)
    -- update collision
    self.hitbox.x1 = self.x
    self.hitbox.y1 = self.y
    self.hitbox.x2 = self.x + offset_x
    self.hitbox.y2 = self.y + offset_y

    -- animate
    if is_moving then
        -- change sprite
        if Game.time % 30 < 15 then self.current_sprite_index = 256
        else self.current_sprite_index = 258 end
    end
    -- headphone sprite
    if self.headphones_on then
        self.current_sprite_index = self.current_sprite_index + 4
    end
end
end

function Dong:action()
    if Keyboard.space_keyp() and self.battery > 0 then
        self.headphones_on = not(self.headphones_on)
    end
    -- if battery is over, take off headphones
    if self.battery == 0 then
        self.headphones_on = false
    end
    -- update headphone battery
    if Game.time % 60 == 0 then
        if Game.dong.headphones_on and Game.dong.battery > 0 then
            Game.dong.battery = Game.dong.battery - 1
        elseif not(Game.dong.headphones_on) and Game.dong.battery < 10 then
            Game.dong.battery = Game.dong.battery + 1
        end
    end
end

-------------------------------------------------
-------------------- MOM -----------------------
-------------------------------------------------
Mom = {id1 = 352, id2=354, x = 10*8, y = 8*8, xPosMinInteragir = 115, xPosMaxInteragir = 170, drew = 1, flag = 1, msgSize = 9,
msg={"Hello DONG,",
"why are you still in the bed?",
"I need you to go to laundry", 
"to take up some clothes",
"I also need you to go the bank",
"to withdraw ur bitcoin profits",
"Your crush is also waiting for you",
"I know that you like your personal space",
"as people will deplete your sanity",
"There safe points in which you can fill it"}}

function Mom:draw()
    --desenhar Mom
        if(cam.x == 0 and cam.y == 0) then 
        spr(Mom.id1,Mom.x, Mom.y,Screen.transparent_color, 1, 0, 0, 2, 2)  end
        if(Mom.drew == 1) then
            if a < Mom.msgSize + 1 then
                print(Mom.msg[a],8,96,0)
                print(Mom.msg[a+1],8,108,0)
                if(btnp(4) and (Mom.flag == 0) ) then
                    a=a+2 end
                Mom.flag = 0
            else 
                a = 1
                Mom.drew = 0
                Mom.flag = 1
            end
        end
end

-------------------------------------------------
------------------ Singleton --------------------
-------------------- GAME -----------------------
-------------------------------------------------
Game = {
    time = 0,               -- time passed
    dong = Dong:new(),      -- Dong
    enemies = {},           -- enemies array
    header = Header:new(),  -- Header with game information
    mom = Mom,
    safe_spaces = {},
    stage = Stage:new(),
    roamers = {},
    cam = cam
}
-- METHODS --
function Game:out_of_bounds(hit_box)
    if hit_box.x1 < 0 then return true end                  -- out of left side
	if hit_box.x2 > Screen.width-1 then return true end     -- out of right side
	if hit_box.y1 < 10 then return true end                 -- out of upper side
	if hit_box.y2 > Screen.height-1 then return true end    -- out of lower side
	return false -- if all else fails, hit_box is inside
end

function Game:reset_enemies()
    for enemy in pairs(self.enemies) do
        self.enemies [enemy] = nil
    end
    for enemy in pairs(self.roamers) do
        self.roamers [enemy] = nil
    end
    init()
end

function Game:enemy_collision()
    for _, enemy in pairs(self.enemies) do
        -- enemy collision
        if detect_collision(self.dong.hitbox, enemy.hitbox) and self.dong.sanity > 0 then
            if not(self.dong.headphones_on) then self.dong.sanity = self.dong.sanity - 1 end
        end
        -- word collision
        local it = 1
        while it <= #enemy.message_attacks do
            if detect_collision(self.dong.hitbox, enemy.message_attacks[it].hitbox) and self.dong.sanity > 0 then
                table.remove(enemy.message_attacks, it)
                if not(self.dong.headphones_on) then self.dong.sanity = self.dong.sanity - 1 end
            else
                it = it + 1
            end
        end
    end
    for _, enemy in pairs(self.roamers) do
        -- enemy collision
        if detect_collision(self.dong.hitbox, enemy.hitbox) and self.dong.sanity > 0 then
            if not(self.dong.headphones_on) then self.dong.sanity = self.dong.sanity - 1 end
        end
    end
end

function Game:update_enemies()
    for _, enemy in pairs(self.enemies) do
        enemy:move()
    end
    for _, roamer in pairs(self.roamers) do
        roamer:move()
    end
end

function Game:draw_enemies()
    for _, enemy in pairs(self.enemies) do
        enemy:draw()
    end
    for _, roamer in pairs(self.roamers) do
        roamer:draw()
    end
end

function Game:safe_space_collision()
    for _, safe_space in pairs(self.safe_spaces) do
        if detect_collision(self.dong.hitbox, safe_space.hitbox) and self.dong.sanity < 10 then
            self.dong.sanity = self.dong.sanity + 1
        end
    end
end

function Game:draw_safe_space()
    for _, safe_space in pairs(self.safe_spaces) do
        safe_space:draw()
    end
end

function Game:update()
    self.header:update()                -- header
    self.dong:move()                    -- dong
    self.dong:action()
    self:update_enemies()               -- enemy
    
    self:enemy_collision()              -- enemy collisions
    self:safe_space_collision()         -- safe space collision

    self.time = self.time + 1           -- Update time
end

function Game:draw()
    cam.x = 0 + (Game.dong.x // Screen.width * Screen.width)
    cam.y = 0 + (Game.dong.y // Screen.height * Screen.height)
    map(cam.x//8,cam.y//8)
    self.mom:draw()
    self.header:draw()                  -- header
    self.dong:draw()                    -- dong
    self:draw_enemies()                 -- enemy
    self:draw_safe_space()              -- safe space
    --self.safe_space:draw()              -- safe space
    if(cam.x == 0 and cam.y == 0) then
        print("Move",136,72,0)
		print("Shield",168,72,0)
        print("Skip",208,72,0)
    end
    if(Game.stage.stage == "death") then

        print("Press z to start your journey again",22,20,0)
        if(btnp(4)) then
            Game.dong = Dong:new()
        end
	end
end

-------------------------------------------------
-------------------- UTILS ----------------------
-------------------------------------------------
function tablelength(T)
    local length = 0
    for _ in pairs(T) do length = length + 1 end
    return length
end

function detect_collision(hit_box_1, hit_box_2)
	if hit_box_1.x1 > hit_box_2.x2 then return false end -- 1 is right of 2
	if hit_box_1.x2 < hit_box_2.x1 then return false end -- 1 is left of 2
	if hit_box_1.y1 > hit_box_2.y2 then return false end -- 1 is under 2
	if hit_box_1.y2 < hit_box_2.y1 then return false end -- 1 is above 2
	return true -- if all else fails, there has been collision
end

function solid_tiles(new_x, new_y)
    return isSolidTile(mget(new_x // 8,new_y // 8)) 
    or  isSolidTile(mget(new_x // 8,(new_y +16) // 8))
    or  isSolidTile(mget((new_x +8) // 8,new_y // 8))
    or  isSolidTile(mget((new_x +8) // 8 ,(new_y + 16) // 8)) 
end

a = 1
startSolidTile = 96
endSolidTile = 127
startSolidTile2 = 224
endSolidTile2 = 230
function isSolidTile(tile)
	if (tile >=  startSolidTile and  tile <= endSolidTile) or (tile >= startSolidTile2 and tile <= endSolidTile2) then
		return true
	end
	return false
end

function init()
    local washy = Enemy:new()
    table.insert(Game.enemies, washy)

    roamer1 = Roamer:new();
    table.insert(Game.roamers, roamer1)

    -- safe spaces
    local atm = SafeSpace:new(49 * Screen.pixels_per_square, 10 * Screen.pixels_per_square, 288, 2, 3)
    table.insert(Game.safe_spaces, atm)
end

init()
-------------------------------------------------
----------------- GAME LOOP ---------------------
-------------------------------------------------

function isDead()
    if(Game.dong.sanity == 0) then
        Game.dong.x = 60*8
        Game.dong.y = 51*8
    end
end

function TIC()
    Screen:clear()
    Game:update()
    Game:draw()
    Game.stage:whereIsStage()
    isDead()
end
