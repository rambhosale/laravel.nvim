local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

local paths = {
  "routes",
}

---@class laravel.loaders.routes_loader
---@field api laravel.services.api
---@field options laravel.core.options_manager
---@field mapper laravel.mappers.route_mapper
---@field watcher laravel.core.watcher
---@field items laravel.dto.artisan_routes[]
---@field loaded boolean
local RoutesLoader = Class({
  api = "laravel.services.api",
  options = "laravel.core.options_manager",
  mapper = "laravel.mappers.route_mapper",
  watcher = "laravel.core.watcher",
}, { items = {}, loaded = false })

---@return laravel.dto.artisan_routes[], laravel.error
function RoutesLoader:load()
  if self.loaded then
    return self.items
  end

  local _load = function()
    local result, err = self.api:run(self.options.get("loaders.route_info.command", "artisan route:list --json"))

    if err then
      self.loaded = false
      self.items = {}
      return {}, Error:new("Failed to load routes"):wrap(err)
    end

    if result:failed() then
      self.loaded = false
      self.items = {}
      return {}, Error:new("Failed to load routes " .. result:prettyErrors())
    end

    self.loaded = true
    self.items = vim.tbl_map(self.mapper.map, result:json() or {})

    return self.items
  end

  self.watcher.register(paths, ".*.php$", _load)

  return _load()
end

return RoutesLoader
