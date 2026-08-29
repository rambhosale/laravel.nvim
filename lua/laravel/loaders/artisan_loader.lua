local Class = require("laravel.utils.class")
local Error = require("laravel.utils.error")

local paths = {
  "app/Console",
  "routes",
}

---@class laravel.dto.artisan_command
---@field name string

---@class laravel.loaders.artisan_loader
---@field api laravel.services.api
---@field watcher laravel.core.watcher
---@field items laravel.dto.artisan_command[]
---@field loaded boolean
local ArtisanLoader = Class({
  api = "laravel.services.api",
  watcher = "laravel.core.watcher",
}, { items = {}, loaded = false })

---@return laravel.dto.artisan_command[], laravel.error
function ArtisanLoader:load()
  if self.loaded then
    return self.items
  end

  local _load = function()
    local result, err = self.api:run("artisan list --format=json")

    if err then
      self.loaded = false
      self.items = {}
      return {}, Error:new("Failed to get command list"):wrap(err)
    end

    if result:failed() then
      self.loaded = false
      self.items = {}
      return {}, Error:new("Failed to load artisan commands: " .. result:prettyErrors())
    end

    self.loaded = true
    self.items = vim
      .iter(result:json().commands or {})
      :filter(function(command)
        return not command.hidden
      end)
      :totable()

    return self.items
  end

  self.watcher.register(paths, ".*.php$", _load)

  return _load()
end

return ArtisanLoader
