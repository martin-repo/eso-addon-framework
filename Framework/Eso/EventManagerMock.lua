---Register an event handler.
---@param receiverName string # Receiver name. Must be globally unique for each registration.
---@param event Event # One of the values from Event class.
---@param eventHandler fun(eventCode:number, ...) # Event handler that will be called whenever the event triggers.
function EsoAddonFramework_Framework_Eso_EventManager:RegisterForEvent(receiverName, event, eventHandler) end

---Unregister an event handler.
---@param receiverName string # Receiver name. Must be the same that was used in RegisterForEvent(...).
---@param event Event # One of the values from Event class. Must be the same that was used in RegisterForEvent(...).
function EsoAddonFramework_Framework_Eso_EventManager:UnregisterForEvent(receiverName, event) end

---Adds a filter for a registered event handler.
---@param receiverName string # Receiver name. Must be the same that was used in RegisterForEvent(...).
---@param event Event # One of the values from Event class. Must be the same that was used in RegisterForEvent(...).
---@param filterType RegisterForEventFilterType # One of the values from RegisterForEventFilterType class.
---@param filter any # Filter value. The type and meaning depends on the filterType.
function EsoAddonFramework_Framework_Eso_EventManager:AddFilterForEvent(receiverName, event, filterType, filter) end
