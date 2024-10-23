---@class KattECS.Components.Velocity: KattECS.Component
---@field velocity Vector3
local Velocity = {
    id = "velocity",
    functions = {
        ---@param self KattECS.Components.Velocity
        ---@param entity KattECS.Entity
        ---@return Vector3
        getVelocity = function(self, entity)
            return self.velocity
        end,
        ---@param self KattECS.Components.Velocity
        ---@param entity KattECS.Entity
        ---@param velocity Vector3
        setVelocity = function(self,entity, velocity)
            self.velocity:set(velocity)
        end,
    },
}

return function()
    return setmetatable({
        velocity = vec(0, 0, 0),
    }, {
        __type = "KattECS.Components.Velocity",
        __index = Velocity,
    })
end
