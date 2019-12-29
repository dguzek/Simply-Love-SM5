local args = ...
local row = args[1]
local col = args[2]
local y_offset = args[3]

local af = Def.ActorFrame{
	Name="SongWheelShared",
	InitCommand=function(self) self:y(y_offset) end
}

-----------------------------------------------------------------
-- black background quad
af[#af+1] = Def.Quad{
	Name="SongWheelBackground",
	InitCommand=function(self) self:zoomto(_screen.w, _screen.h/2.25 - 3):diffuse(0,0,0,1):cropbottom(1) end,
	OnCommand=function(self)
		self:xy(_screen.cx, math.ceil((row.how_many-2)/2) * row.h + 36):finishtweening()
		    :accelerate(0.2):cropbottom(0)
			:diffusealpha(.75)
	end,
	SwitchFocusToGroupsMessageCommand=function(self) self:smooth(0.3):cropright(1) end,
	SwitchFocusToSongsMessageCommand=function(self) 	self:smooth(.3):cropright(0) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:smooth(0.3):cropright(1) end
}

-- rainbow glowing border top
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w, 1):diffuse(1,1,1,0):xy(_screen.cx, _screen.cy+30 + _screen.h/(row.how_many-2)*-0.5):faderight(10):rainbow() end,
	OnCommand=function(self) self:sleep(0.3):diffusealpha(0.75):queuecommand("FadeMe") end,
	FadeMeCommand=function(self) self:accelerate(1.5):faderight(0):accelerate(1.5):fadeleft(10):sleep(0):diffusealpha(0):fadeleft(0):sleep(1.5):faderight(10):diffusealpha(0.75):queuecommand("FadeMe") end,
	SwitchFocusToGroupsMessageCommand=function(self) self:visible(false) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:visible(false) end,
	SwitchFocusToSongsMessageCommand==function(self) self:visible(true) end
}

-- rainbow glowing border bottom
af[#af+1] = Def.Quad{
	InitCommand=function(self) self:zoomto(_screen.w, 1):diffuse(1,1,1,0):xy(_screen.cx, _screen.cy+30 + _screen.h/(row.how_many-2) * 0.5):faderight(10):rainbow() end,
	OnCommand=function(self) self:sleep(0.3):diffusealpha(0.75):queuecommand("FadeMe") end,
	FadeMeCommand=function(self) self:accelerate(1.5):faderight(0):accelerate(1.5):fadeleft(10):sleep(0):diffusealpha(0):fadeleft(0):sleep(1.5):faderight(10):diffusealpha(0.75):queuecommand("FadeMe") end,
	SwitchFocusToGroupsMessageCommand=function(self) self:visible(false) end,
	SwitchFocusToSingleSongMessageCommand=function(self) self:visible(false) end,
	SwitchFocusToSongsMessageCommand==function(self) self:visible(true) end
}

-----------------------------------------------------------------
--[[ text - turned off for now

af[#af+1] = Def.ActorFrame{
	Name="CurrentSongInfoAF",
	InitCommand=function(self) self:y( row.h * 2 + 10 ):x( col.w + 80):diffusealpha(0) end,
	OnCommand=function(self) self:sleep(0.15):linear(0.15):diffusealpha(1) end,

	SwitchFocusToGroupsMessageCommand=function(self)
		self:visible(false):runcommandsonleaves(function(leaf) if leaf.settext then leaf:settext("") end end)
	end,
	CloseThisFolderHasFocusMessageCommand=function(self)
		self:runcommandsonleaves(function(leaf) if leaf.settext then leaf:settext("") end end)
	end,
	SwitchFocusToSongsMessageCommand=function(self)
		self:visible(true):linear(0.2):zoom(1):y(row.h*2+10):x(col.w+80)
		self:runcommandsonleaves(function(leaf) leaf:diffuse(1,1,1,1) end)
	end,
	SwitchFocusToSingleSongMessageCommand=function(self)
		self:linear(0.2):zoom(0.9):xy(col.w+WideScale(20,65), row.h+43)
		self:runcommandsonleaves(function(leaf) leaf:diffuse(1,1,1,1) end)
	end,

	-- main title
	Def.BitmapText{
		Font="Common Normal",
		Name="Title",
		InitCommand=function(self) self:zoom(1.3):diffuse(Color.White):horizalign(left):y(-45):maxwidth(300) end,
		CurrentSongChangedMessageCommand=function(self, params)
			if params.song then
				self:settext( params.song:GetDisplayMainTitle() )
			end
		end,
	},

	-- artist
	Def.BitmapText{
		Font="Common Normal",
		Name="Artist",
		InitCommand=function(self) self:zoom(0.85):diffuse(Color.White):y(-20):horizalign(left) end,
		CurrentSongChangedMessageCommand=function(self, params)
			if params.song then
				self:settext( THEME:GetString("ScreenSelectMusic", "Artist") .. ": " .. params.song:GetDisplayArtist() )
			end
		end,
	},

	Def.ActorFrame{
		InitCommand=function(self) self:y(25) end,

		-- BPM
		Def.BitmapText{
			Font="Common Normal",
			Name="BPM",
			InitCommand=function(self) self:zoom(0.65):diffuse(Color.White):y(0):horizalign(left) end,
			CurrentSongChangedMessageCommand=function(self, params)
				if params.song then
					self:settext( THEME:GetString("ScreenSelectMusic", "BPM") .. ": " .. GetDisplayBPMs() )
				end
			end,
		},
		-- length
		Def.BitmapText{
			Font="Common Normal",
			Name="Length",
			InitCommand=function(self) self:zoom(0.65):diffuse(Color.White):y(14):horizalign(left) end,
	 		CurrentSongChangedMessageCommand=function(self, params)
				if params.song then
		 			self:settext( THEME:GetString("ScreenSelectMusic", "Length") .. ": " .. SecondsToMMSS(params.song:MusicLengthSeconds()):gsub("^0*","") )
				end
	 		end,
		},
		-- genre
		Def.BitmapText{
			Font="Common Normal",
			Name="Genre",
			InitCommand=function(self)
				self:zoom(0.65):diffuse(Color.White):y(28):horizalign(left)
			end,
			CurrentSongChangedMessageCommand=function(self, params)
				if params.song and params.song:GetGenre() ~= "" then --don't need to display this if there's no genre listed
					self:settext( THEME:GetString("ScreenSelectMusic", "Genre") .. ": " .. params.song:GetGenre() )
				else self:settext("")
				end
			end,
		},
	}
}

--]]

return af