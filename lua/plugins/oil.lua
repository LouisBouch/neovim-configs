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
    },
    float = {
      -- Padding around the floating window
      padding = 2,
      -- optionally override the oil buffers window title with custom function: fun(winid: integer): string
      get_win_title = function(winid)
        local bufnr = vim.fn.winbufnr(winid)
        local cwd = vim.fn.getcwd(winid)
        local cur_path = require("oi").get_current_dir(bufnr)
        local rel_path = vim.fs.relpath(cwd, cur_path)
        rel_path = ((rel_path ~= nil) and "./" .. rel_path) or cur_path
        rel_path = rel_path:gsub("%.$", "")
        return rel_path
      end,
      -- preview_split: Split direction: "auto", "left", "right", "above", "below".
      preview_split = "auto",
    },
  },
  keys = {
    { "<leader>e", "<cmd>Oil --float<CR>", desc = "Open explorer" },
    {
      "<C-g>",
      function()
        print(vim.fn.getcwd(0))
      end,
    },
  },
  --
  -- Lazy loading is not recommended because it is very tricky to make it work correctly in all situations.
  lazy = false,
}
