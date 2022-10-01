LUAGUI_NAME = "More Shortcut Menus"
LUAGUI_AUTH = "Zurph / TopazTK"

--KH1 MSC
--Offset for storing Shortcuts: 0x2DE6214 (subtract this by the games offset)
--Shortcuts are stored in bytes; 
--0 = fire, 1 = blizzard, 2 = thunder, 3 = cure, 4 = gravity, 5 = stop, 6 = aero, 
--FF = no command.

local canExecute = false
local bounceBool = false
local offset = 0x3A0606

function _OnInit()
	if GAME_ID == 0xAF71841E and ENGINE_TYPE == "BACKEND" then
		ConsolePrint("Customize 5 shortcut menus using R3/L3 while in the pause menu. Access those shortcut menus using L1 + R3 / L3 to scroll between them, or L1+D-pad/L1+R2 in-game.")
		canExecute = true
	else
		ConsolePrint("MultiShortcutMenu Install: failed.")
	end
end

function _OnFrame()
	Shortcuts = 0x2DE6214-offset --Where the shortcuts are.
	SaveData = 0x2DE6294-offset --Where the other shortcuts will be stored, +0x80
	ReadInput = 0x233D034-offset
	
	if canExecute == true then
		_readMenu = ReadByte(SaveData)
		_readSave = ReadArray(Shortcuts, 0x03)
		_readLoad = ReadArray(SaveData + 0x01 + (0x03 * _readMenu), 0x03)
		if ReadInput & 0x0400 == 0x0400 then
			if bounceBool == false then
				if ReadInput & 0x02 == 0x02 and _readMenu < 4 then
					WriteByte(SaveData, _readMenu + 1) 
					bounceBool = true
				end
			if ReadInt(ReadInput) & 0x04 == 0x04 then --R3 pressed. Prevents input lockout. Scrolls DOWN
				WriteByte(SaveData, _readMenu - 1)
				bounceBool = true 
			end	
		end	
			if ReadInt(ReadInput) & 0x0F == 0x00 and bounceBool == true then
				bounceBool = false
			end
		end
		if ReadInt(ReadInput) & 0x0400 == 0x0400 then --Prevents input lockout, so you can glide without needing an additional if statements.
			if ReadInt(ReadInput) & 0x10 == 0x10 then --L1+Up
				WriteByte(SaveData, 0x0)
			elseif ReadInt(ReadInput) & 0x20 == 0x20 then --L1+Right
				WriteByte(SaveData, 0x1)
			elseif ReadInt(ReadInput) & 0x40 == 0x40 then --L1+Down
				WriteByte(SaveData, 0x2)
			elseif ReadInt(ReadInput) & 0x80 == 0x80 then --L1+Left
				WriteByte(SaveData, 0x3)
			elseif ReadInt(ReadInput) & 0x0600 == 0x0600 then --L1+R2. Requires 00 after the 0x06 as otherwise it won't swap properly.
				WriteByte(SaveData, 0x4)
			end
		end
	end
end