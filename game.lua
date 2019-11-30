-- Tic-80 Screen
Screen = {
	-- 240x136 display
	width = 240, height = 136,
	-- 60Hz refresh rate
	refresh_rate = 60,
}

-- Keyboard functions
Keyboard = {
	-- W
	w_key = function (self) return key(23) end,
	-- A
	a_key = function (self) return key(1) end,
	-- S
	s_key = function (self) return key(19) end,
	-- D
	d_key = function (self) return key(4) end,
	-- UP
	up_key = function (self) return key(58) end,
	-- DOWN
	down_key = function (self) return key(59) end,
	-- LEFT
	left_key = function (self) return key(60) end,
	-- RIGHT
	up_key = function (self) return key(61) end
}

function TIC()
	cls()
	a = Keyboard
	b = Keyboard
	if a:w_key() then
		print(Screen.width,84,84)
	end

	if b:a_key() then
		print(Screen.width,100,100)
	end
end
