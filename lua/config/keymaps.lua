-- -- REGUlAR KEY MAPPINGS

---A keymap object containing all fields necessary for applying a keymap.
---@class Keymap
---@field mode string|string[] Mode "short-name" (see |nvim_set_keymap()|), or a list thereof.
---@field lhs string           Left-hand side {lhs} of the mapping.
---@field rhs string|function  Right-hand side {rhs} of the mapping, can be a Lua function.
---@field ft? string|string[]  Filetypes for which the command is set.
---@field opts? vim.keymap.set.Opts Optional parameters:
---    "<noremap>" disables |recursive_mapping|, like |:noremap|
---    "<desc>" human-readable description.
---    "<callback>" Lua function called in place of {rhs}.
---    "<replace_keycodes>" (boolean) When "expr" is true, replace
---    "<buffer>"
---    "<nowait>"
---    "<silent>"
---    "<script>"
---    "<expr>"
---    "<unique>"
---    "<remap>"

---List of key mappings
---@type Keymap[]
local mappings = {
  -- Normal mode
  -- Visual mode
  -- Insert mode
  { mode = "i", lhs = "<C-l>", rhs = "<Del>" },
  -- All modes
  { mode = "", lhs = "<Space>", rhs = "<Nop>" },
}
---Create mappings
---@param keymaps Keymap[]
local function applyKeymaps(keymaps)
  -- Autocommand group for autocommands that create file specific keymaps.
  vim.api.nvim_create_augroup("ft_keymaps", { clear = true })
  for _, keymap in ipairs(keymaps) do
    if keymap.ft ~= nil then
    -- For when the keymap has been defined for specific filetypes.
      vim.api.nvim_create_autocmd("FileType", {
        pattern = keymap.ft,
        group = "ft_keymaps",
        callback = function()
          vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts or {})
        end,
      })
    else
    -- For when the keymap has not been defined for specific filetypes.
      vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts or {})
    end
  end
end
applyKeymaps(mappings)
