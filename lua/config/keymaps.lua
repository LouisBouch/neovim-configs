-- -- REGUlAR KEY MAPPINGS

---A keymap object containing all fields necessary for applying a keymap.
---@class Keymap
---@field mode string|string[] Mode "short-name" (see nvim_set_keymap or map-modes).
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
        callback = function(event)
          local opts = keymap.opts or {}
          opts.buffer = event.buf
          vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, opts)
        end,
      })
    else
      -- For when the keymap has not been defined for specific filetypes.
      vim.keymap.set(keymap.mode, keymap.lhs, keymap.rhs, keymap.opts or {})
    end
  end
end

---List of key mappings
---@type Keymap[]
local mappings = {
  { mode = { "n", "v" }, lhs = "<Space>", rhs = "<Nop>" },

  -- Extra deleting commands
  { mode = { "i", "c", "t" }, lhs = "<C-l>", rhs = "<Del>" },
  { mode = { "i", "c", "t" }, lhs = "<C-h>", rhs = "<BS>" },
  {
    mode = { "i" },
    lhs = "<C-d>",
    rhs = "<Space><Esc>ce",
    opts = { desc = "Simulates ctrl-delete" },
  },

  -- Movement
  { mode = { "n", "v" }, lhs = "<C-d>", rhs = "<C-d>zz" },
  { mode = { "n", "v" }, lhs = "<C-u>", rhs = "<C-u>zz" },
  { mode = { "n", "v" }, lhs = "j", rhs = "gj" },
  { mode = { "n", "v" }, lhs = "k", rhs = "gk" },
  { mode = { "n", "v" }, lhs = "<A-w>", rhs = "100<c-w>+100<c-w>>" }, -- Full size window

  -- Exit terminal mode
  {
    mode = { "t" },
    lhs = "<A-c>",
    rhs = [[<C-\><C-n>]],
    opts = { desc = "Normal mode within terminal" },
  },

  -- Extra enter mapping
  { mode = { "n", "v", "i", "o", "c", "t" }, lhs = "<A-j>", rhs = "<Enter>" },

  -- Revamping deletion to act like actual deletion and not cutting.
  -- Add special cutting binding.
  { mode = { "n", "v" }, lhs = "x", rhs = '"_x' },
  { mode = { "n", "v" }, lhs = "X", rhs = '"_X' },
  { mode = { "n", "v" }, lhs = "c", rhs = '"_c' },
  { mode = { "n", "v" }, lhs = "C", rhs = '"_C' },
  { mode = { "n", "v" }, lhs = "d", rhs = '"_d' },
  { mode = { "n", "v" }, lhs = "D", rhs = '"_D' },
  { mode = { "n", "v" }, lhs = "s", rhs = '"_s' },
  { mode = { "n", "v" }, lhs = "S", rhs = '"_S' },

  {
    mode = { "v" },
    lhs = "p",
    rhs = "P",
    opts = { desc = "Don't yank text being replaced" },
  },
  {
    mode = { "v" },
    lhs = "P",
    rhs = "p",
    opts = { desc = "Yank text being replaced" },
  },

  { mode = { "n", "v" }, lhs = "m", rhs = "d" },
  { mode = { "n", "v" }, lhs = "M", rhs = "D" },
  { mode = { "n", "v" }, lhs = "gm", rhs = "m" },
}
applyKeymaps(mappings)
