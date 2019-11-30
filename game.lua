-- Singleton
-- TIC-80 Screen
Screen = {
	-- 240x136 display
	width = 240, height = 136,
	-- 60Hz refresh rate
	refresh_rate = 60,
}

-- clear screen
function Screen:clear() cls() end

-- TIC-80 Keyboard
Keyboard = {
	-- ATTRIBUTES --
	test = 1
}

-- CONSTRUCTOR --
Keyboard.__index = Keyboard
function Keyboard:new(test)
	local kb = {}             	-- our new object
	setmetatable(kb, Keyboard)  -- make Account handle lookup
	kb.test = test      		-- initialize our object
	return kb
end

-- METHODS -- 
-- W
function Keyboard:w_key() return key(23) end
-- A
function Keyboard:a_key() return key(1) end
-- S
function Keyboard:s_key() return key(19) end
-- D
function Keyboard:d_key() return key(4) end
-- UP
function Keyboard:up_key() return key(58) end
-- DOWN
function Keyboard:down_key() return key(59) end
-- LEFT
function Keyboard:left_key() return key(60) end
-- RIGHT
function Keyboard:right_key() return key(61) end

Enemy = {
    x = math.random(0,240),
    y = math.random(0,136),
    draw = function (self)
                spr(1,self.x,self.y,-1,1,0,0,2,2)
            end,
    move = function (self)
                if time % 60 == 0 then
                    new_x = self.x + math.random(-1,1)
                    new_y = self.y + math.random(-1,1)
                    
                    if new_x > 0 and new_x < 240 then
                        self.x = new_x
                    end
                
                    if new_y > 0 and new_y < 136 then
                        self.y = new_y
                    end
                end
            end
}

Hero = {
    x = 120,
    y = 68,
    draw = function (self)
                spr(3,self.x,self.y,-1,1,0,0,2,2)
            end,
    move = function (self)
                new_x = 1000
                new_y = 1000

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
            end,
    punch = function (self)
        if key(48) then
            spr(3,self.x,self.y,-1,1,0,0,3,2)
        end
    end
}

time = 0

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

function TIC()
    time = time + 1
    cls()
    Hero:move()
    Hero:draw()
    Hero:punch()
    Enemy:move()
    Enemy:draw()
end

function punch()
    if key(48) then
        spr(3,0,0,-1,1,0,0,3,2)
    end
end
