local diagnostics_provider = {}

---@param app LaravelApp
function diagnostics_provider:register(app)
  app:bindIf("view_diagnostics", "laravel.services.diagnostics.views", { tags = { "diagnostics" } })
end

---@param app LaravelApp
function diagnostics_provider:boot(app)
  local group = vim.api.nvim_create_augroup("laravel.diagnostics", {})
  vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost" }, {
    pattern = { "*.php" },
    group = group,
    callback = function(ev)
      if not app("env"):is_active() then
        return
      end
      for _, diagnostic in ipairs(app:makeByTag("diagnostics")) do
        diagnostic:handle(ev.buf)
      end
    end,
  })
end

return diagnostics_provider
