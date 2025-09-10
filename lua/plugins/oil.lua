return {
  "stevearc/oil.nvim",
  ---@module 'oil'
  ---@type oil.SetupOpts
  -- Personal type, ignore warning.
  ---@diagnostic disable-next-line: assign-type-mismatch
  category = meta_h.categories.editor,
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- use if you prefer nvim-web-devicons
  opts = {
    keymaps = {
      ["<A-j>"] = "actions.select",
    },
    view_options = {
      show_hidden = true,
    }
  },
  keys = { { "<leader>e", "<cmd>Oil --float<CR>", desc = "Open explorer" } },
  --
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
