--
-- This is free and unencumbered software released into the public domain.
-- 
-- Anyone is free to copy, modify, publish, use, compile, sell, or
-- distribute this software, either in source code form or as a compiled
-- binary, for any purpose, commercial or non-commercial, and by any
-- means.
-- 
-- In jurisdictions that recognize copyright laws, the author or authors
-- of this software dedicate any and all copyright interest in the
-- software to the public domain. We make this dedication for the benefit
-- of the public at large and to the detriment of our heirs and
-- successors. We intend this dedication to be an overt act of
-- relinquishment in perpetuity of all present and future rights to this
-- software under copyright law.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
-- MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
-- IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
-- OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
-- ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
-- 
-- For more information, please refer to <http://unlicense.org/>
--

--
-- Title:"Dead" Effect AddOn
-- Author: David Jolly 2017 (majestic53@gmail.com)
--
-- Attributions:
--    Sound effect originated from: https://www.youtube.com/user/XboxAddictionz
--

--
-- Configuration
--

local DeadGfxFadeDelta = 0.05;   -- fade timestep (0 - 1)
local DeadGfxFadeInit = 1;   -- initial frame opacity (0 - 1)
local DeadGfxFadeTime = 1;   -- maximum fade time (in seconds)
local DeadGfxFontInherits = "PVPInfoTextFont";   -- font type
local DeadGfxFontLayer = "BACKGROUND";   -- frame layer
local DeadGfxFontName = nil;   -- font name
local DeadGfxHeight = 300;   -- frame height
local DeadGfxMessage = "DEAD";   -- frame text
local DeadGfxRelativeTo = "CENTER";   -- frame position
local DeadGfxRelativeX = 0;   -- frame x coordinate
local DeadGfxRelativeY = 200;   -- frame y coordinate
local DeadGfxShowMessage = true;   -- display frame
local DeadGfxWidth = 300;   -- frame width

local DeadSfxEventDelta = 0.5;   -- event delay (in seconds) 
local DeadSfxEventMajor = "COMBAT_LOG_EVENT_UNFILTERED";   -- event type
local DeadSfxEventMinor = "UNIT_DIED";   -- event subtype
local DeadSfxPath = "Interface\\AddOns\\dead\\dead.mp3";   -- sound effect file path
local DeadSfxTarget = "target";   -- target type
local DeadSfxType = "SFX";   -- sound effect type

--
-- Globals
--

local DeadGfxFrame = CreateFrame("Frame");   -- graphics frame
local DeadGfxFadeTimer = 0;   -- fade timer

local DeadSfxFrame = CreateFrame("Frame");   -- sound effect frame

--
-- Helper Routines
--

function TriggerDeadGfx(message)
	DeadGfxFadeTimer = GetTime();   -- initialize fade timer
	DeadGfxFrame:ClearAllPoints();   -- initialize frame
	DeadGfxFrame:SetHeight(DeadGfxHeight);
	DeadGfxFrame:SetWidth(DeadGfxWidth);
	DeadGfxFrame:SetScript("OnUpdate", OnDeadGfx);
	DeadGfxFrame:Hide();
	DeadGfxFrame.text = DeadGfxFrame:CreateFontString(DeadGfxFontName, DeadGfxFontLayer, DeadGfxFontInherits);
	DeadGfxFrame.text:SetAllPoints();
	DeadGfxFrame:SetPoint(DeadGfxRelativeTo, DeadGfxRelativeX, DeadGfxRelativeY);
	DeadGfxFrame.text:SetText(message);
	DeadGfxFrame:SetAlpha(DeadGfxFadeInit);
	DeadGfxFrame:Show();   -- show frame
end

function TriggerDeadSfx()

	if(DeadGfxShowMessage == true) then   -- show message?
		TriggerDeadGfx(DeadGfxMessage);   -- trigger frame
	end

	PlaySoundFile(DeadSfxPath, DeadSfxType);   -- play sound effect
end

--
-- Event Handlers
--

function OnDeadGfx(self, elapsed)

	if(DeadGfxFadeTimer < GetTime() - DeadGfxFadeTime) then   -- fade timeout not expired?
		local fade = DeadGfxFrame:GetAlpha();

		if(fade ~= 0) then   -- frame opacity non-zero?
			DeadGfxFrame:SetAlpha(fade - DeadGfxFadeDelta);   -- adjust frame opacity by fade timestep
		end
		
		if(fade == 0) then   -- frame opacity is zero?
			DeadGfxFrame:Hide();   -- hide frame
		end
	end
end

function OnDeadSfx(self, event, ...)
	local EventType = select(2, ...);
	
	if(EventType == DeadSfxEventMinor) then   -- event type matches?
		local TargetGuid = select(8, ...);
		local TargetName = select(9, ...);

		if(TargetGuid == UnitGUID(DeadSfxTarget)) then   -- event originated from target?
			C_Timer.After(DeadSfxEventDelta, function() TriggerDeadSfx(); end);   -- trigger sound
		end
	end
end

--
-- Initialization
--

DeadSfxFrame:RegisterUnitEvent(DeadSfxEventMajor);
DeadSfxFrame:SetScript("OnEvent", OnDeadSfx);