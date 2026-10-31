--[[
	/*******************************************************************************
	Midnight Labs | Roblox Division
	Driven by technology. Built through creativity.

	@project    SmartBoot System
	@version    1.0.0
	@license    All Rights Reserved
	@copyright  (c) 2026 Midnight Labs 
	@authors    @Midnight_Labs


	This software and associated documentation files are proprietary and confidential.
	Unauthorized copying, modification, or distribution is strictly prohibited.
	******************************************************************************/
]]

local Config={
	Enabled=true,
	DebugLogs=true,

	SmartLight={
		Enabled=true,

		PoweredOff={
			Enabled=true,
			Color={255,255,0},
			OnDelay=.15,
			OffDelay=.15,
			Material="Neon"
		},

		Status1={
			Enabled=true,
			Color={0,249,0},
			OnDelay=1,
			OffDelay=1,
			Material="Neon"
		},

		Status2={
			Enabled=true,
			Color={255,251,0},
			OnDelay=1,
			OffDelay=1,
			Material="Neon"
		},

		Status3={
			Enabled=true,
			Color={255,38,0},
			OnDelay=1,
			OffDelay=1,
			Material="Neon"
		}
	},

	Centegix={
		Enabled=true,

		Status1={
			Enabled=true,
			Color={0,255,0},
			FlashTime=.1,
			Delay=1
		},

		Status2={
			Enabled=true,
			Color={217,48,215},
			FlashTime=.1,
			Delay=1
		},

		Status3={
			Enabled=true,
			Color={255,60,63},
			FlashTime=.1,
			Delay=1
		}
	},
	Sounds={
		Enabled=true,
		Tone=script.Parent.Parent.Legacy.DemoPanel.SoundFile.Countdown,
		Ready=nil,
		SecureMode=script.Parent.Parent.Legacy.DemoPanel.SoundFile.Secure,
		Lockdown=script.Parent.Parent.Legacy.DemoPanel.SoundFile.Lockdown,
		AllClear=script.Parent.Parent.Legacy.DemoPanel.SoundFile.AllClear,
		Lock=script.Parent.Parent.Legacy.DemoPanel.SoundFile.TriggerSound,
		Countdown=script.Parent.Parent.Legacy.DemoPanel.SoundFile.Countdown,
	},
	StatusEvents={
		Ready=true,
		SecureMode=true,
		Lockdown=true,
		AllClear=true,
		ResetDelay=10
	},

	Webhook={
		Enabled=true,
		URL="",
		RoleID="",
		PanelID="",
		PlaceName=""
	},

	AssistanceWebhook={
		Enabled=true,
		URL="",
		RoleID="",
		PanelID="",
		PlaceName=""
	}
}

return Config
