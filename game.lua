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
function HitBox:new()
	local cb = {}			  	-- our new object
	setmetatable(cb, HitBox)	-- make HitBox handle lookup
	return cb
end

function detect_collision(hit_box_1, hit_box_2)
	if hit_box_1.x1 > hit_box_2.x2 then return false end -- 1 is right of 2
	if hit_box_1.x2 < hit_box_2.x1 then return false end -- 1 is left of 2
	if hit_box_1.y1 > hit_box_2.y2 then return false end -- 1 is under 2
	if hit_box_1.y2 < hit_box_2.y1 then return false end -- 1 is above 2
	return true -- if all else fails, there has been collision
end

function TIC()
	Screen.clear()

end
