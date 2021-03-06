--Distance Measuring Electronics v.1.2 by Rio --> Visual distance guage
DME = {}
DME.version = "1.2"
DMEtimer = Timer()

DME.distance = iup.text{
	size = "300x",
	padding = "50x50",
}

DMEPBH = iup.stationprogressbar{
	visible = "YES",
	active = "NO",
	minvalue = tonumber(DME.distance.value) or 200,
	maxvalue = (tonumber(DME.distance.value) or 200) *3,
	uppercolor = "0 255 0",
	lowercolor = "0 128 255",
	RASTERSIZE = "100x15",
	ORIENTATION = "VERTICAL",
	}

DMEPBL = iup.stationprogressbar{
	visible = "YES",
	active = "NO",
	minvalue = 0,
	maxvalue = tonumber(DME.distance.value) or 200,
	uppercolor = "0 255 0",
	lowercolor = "0 128 255",
	RASTERSIZE = "100x15",
	ORIENTATION = "VERTICAL",
	}

DMEbox = iup.hbox{
	DMEPBH,
	DMEPBL,
	MARGIN = "x60",
	}
	
local close = iup.button{
	title = 'Close',
	action = function(self)
		DMEdialog:hide()
	end,
}

local save = iup.button{ title = "Save", action = function(self)
		if DME.distance.value ~= "" then
			DMEPBL.maxvalue = tonumber(DME.distance.value)
			DMEPBH.minvalue = tonumber(DME.distance.value)
			DMEPBH.maxvalue = tonumber(DME.distance.value) * 3
			DMEwrite()
			DME.cmd()
		end
	end
}

DMEdialog = iup.dialog{
	iup.hbox{
		iup.vbox{
			iup.label{title = "Distance"},
			DME.distance,
			iup.hbox{
			save,
			close,
			},
		alignment = "ACENTER",
		},
	},
	EXPAND = "YES",
	RESIZE = "NO",
--	SIZE = 'QUARTERxQUARTER',
	TITLE = "Enter preferred Distance",
	TOPMOST = "YES",
	DEFAULTESC = close,
	DEFAULTENTER = save,
}

function DME.cmd ()
	print ("Welcome to DME")
	if DMEdialog.visible == "YES" then
		HideDialog(DMEdialog)
	else ShowDialog(DMEdialog, iup.CENTER, iup.CENTER)
	end
end

RegisterUserCommand('dme', DME.cmd)

function DME:OnEvent(event, data)
	if event == "PLAYER_ENTERED_GAME" then
		print ("DME v"..DME.version)
		DME.distance.value = gkini.ReadString("DME", "distance", "200")
		iup.Append(HUD.distancebar, DMEbox)
		DMEupdate()
	end
	
	if event == "PLAYER_LOGGED_OUT" then
		DMEtimer:Kill()
		DMEPBH.lowercolor = "0 128 255"
		DMEPBL.lowercolor = "0 128 255"
		iup.Refresh(HUD.distancebar)
	end
	
	if event == "TARGET_CHANGED" then
		DMEupdate()	
	end
	
	if event == "TARGET_HEALTH_UPDATE" then
		print("TARGET_HEALTH_UPDATE event encountered")
		print(GetTargetDistance())
	end
end

RegisterEvent(DME, "PLAYER_ENTERED_GAME")
RegisterEvent(DME, "PLAYER_LOGGED_OUT")
RegisterEvent(DME, "TARGET_CHANGED")
RegisterEvent(DME, "TERMINATE")

function DMEupdate()
	if GetTargetDistance() then
		DMEPBH.lowercolor = "255 0 0"
		DMEPBH.uppercolor = "0 255 0"
		DMEPBH.value = GetTargetDistance()
		DMEPBL.lowercolor = "0 255 0"
		DMEPBL.uppercolor = "255 0 0"
		DMEPBL.value = GetTargetDistance()
		DMEtimer:SetTimeout(20, function() DMEupdate() end)
	else
		if DMEtimer:IsActive() then DMEtimer:Kill() end
		DMEPBH.uppercolor = "0 128 255"
		DMEPBH.value = 0
		DMEPBL.lowercolor = "0 128 255"
		DMEPBL.value = 200
	end
	iup.Refresh(HUD.distancebar)
end

function DMEwrite()
	gkini.WriteString("DME", "distance", ""..tostring(DME.distance.value))
end