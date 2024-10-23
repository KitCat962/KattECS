---@class KattECS.Entity
---@field id KattECS.Entity.ID
---@field componentMap KattECS.Component.Map
---@field componentList KattECS.Component.List

---@alias KattECS.Entity.ID string
---@alias KattECS.Entity.Map table<KattECS.Entity.ID, KattECS.Entity>
---@alias KattECS.Entity.List KattECS.Entity[]

---@class KattECS.Component
---@field id KattECS.Component.ID the unique id of this component
---@field requires KattECS.Component.ID[]? a list of all components that this component requires
---@field init fun(self: self, entity: KattECS.Entity)? a function that gets executed when the entity is created
---@field tick fun(self: self, entity: KattECS.Entity)? a function that gets executed every tick
---@field render fun(self:self, entity: KattECS.Entity, delta:number, context: Event.Render.context)? a function that gets executed every frame
---@field functions table<string, fun(self: self, entity: KattECS.Entity, ...:any):any> a list of functions that can be called from the entity

---@alias KattECS.Component.ID string
---@alias KattECS.Component.Map table<KattECS.Component.ID, KattECS.Component>
---@alias KattECS.Component.List KattECS.Component[]

---@class KattECS.API
local api = {
    ---@type KattECS.Entity.List
    entityList = {},
    entityMap = {},
    metatable = {
        __type = "KattECS.Entity",
        __index = function(t, i)
            ---@cast t KattECS.Entity
            for index = #t.componentList, 1, -1 do
                local component = t.componentList[index]
                if component.functions then
                    for name, fn in pairs(component.functions) do
                        if i == name then
                            return fn
                        end
                    end
                end
            end
        end,
    },
}

---@param id KattECS.Entity.ID a unique string identifier for this entity
---@param ... KattECS.Component
---@return KattECS.Entity
---@overload fun(components: KattECS.Component.List)
function api.newEntity(id, ...)
    if api.entityMap[id] then
        error("Conflicting entities! already have an entity with id " .. id, 2)
    end

    local entity = setmetatable({
        ---@type KattECS.Entity.ID
        id = id,
        ---@type KattECS.Component.List
        componentList = type(...) == "table" and ... or { ... },
        ---@type KattECS.Component.Map
        componentMap = {},
    }, api.metatable)
    for _, component in ipairs(entity.componentList) do
        if entity.componentMap[component.id] then
            error("Conflicting components! already have a component with id " .. component.id, 2)
        end

        if component.requires then
            for _, component_id in ipairs(component.requires) do
                if not entity.componentMap[component_id] then
                    error("Component " ..
                        component.id ..
                        " requires component " ..
                        component_id ..
                        " but it isnt on this entity. Make sure it is added before this component!",
                        2)
                end
            end
        end
        entity.componentMap[component.id] = component
        if component.init then
            component:init(entity)
        end
    end
    api.entityMap[id] = entity
    table.insert(api.entityList, entity)
    return entity
end

function events.tick()
    for _, entity in ipairs(api.entityList) do
        for _, component in ipairs(entity.componentList) do
            if component.tick then
                component:tick(entity)
            end
        end
    end
end

function events.render(delta, context)
    for _, entity in ipairs(api.entityList) do
        for _, component in ipairs(entity.componentList) do
            if component.render then
                component:render(entity, delta, context)
            end
        end
    end
end

return api
