---@class KattECS.Components.Velocity: KattECS.Component
---@field position Vector3
local Position = {
    id = "position",
    functions = {
        ---@param self KattECS.Components.Velocity
        ---@param entity KattECS.Entity
        ---@return Vector3
        getPosition = function(self, entity)
            return self.position
        end,
        ---@param self KattECS.Components.Velocity
        ---@param entity KattECS.Entity
        ---@param position Vector3
        setPosition = function(self,entity, position)
            self.position:set(position)
        end,
    },
}

return function()
    return setmetatable({
        position = vec(0, 0, 0),
    }, {
        __type = "KattECS.Components.Position",
        __index = Position,
    })
end
