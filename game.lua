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

function TIC()
	Screen.clear()
	a = Keyboard:new(1)
	b = Keyboard:new(2)
	if a:w_key() then
		print(a.test,84,84)
	end

	if b:a_key() then
		print(b.test,100,100)
	end
end

