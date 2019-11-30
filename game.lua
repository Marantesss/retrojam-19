-------------------------------------------------
------------------- Singleton -------------------
----------------- TIC-80 SCREEN -----------------
-------------------------------------------------
Screen = {
	-- 240x136 display
	width = 240, height = 136,
	-- 60Hz refresh rate
	refresh_rate = 60,
}
-- clear screen
function Screen:clear() cls() end

-------------------------------------------------
---------------- TIC-80 KEYBOARD ----------------
-------------------------------------------------
-- TIC-80 Keyboard
Keyboard = {}
-- CONSTRUCTOR --
Keyboard.__index = Keyboard
function Keyboard:new()
	local kb = {}             	-- our new object
	setmetatable(kb, Keyboard)  -- make Account handle lookup
	return kb
end
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

function TIC()
	Screen.clear()

end
