--#region Usings

--#region Framework usings
--#endregion

--#region Addon usings
--#endregion

--#endregion

-- Constants

-- Fields

-- Local functions

-- Constructor

---@param addonInfo AddonInfo
local function Constructor(addonInfo)
end

AddonExample_Ui_Bindings = { }
EsoAddonFramework_Framework_Bootstrapper.Register(Constructor)

-- Class functions

function AddonExample_Ui_Bindings.ShowSettings()
	Messenger.Publish(FrameworkMessageType.ShowSettings)
end