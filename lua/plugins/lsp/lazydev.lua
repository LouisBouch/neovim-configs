return {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    version = "^1",
    category = meta_h.categories.lsp,
    opts = {
      -- Don't load when you have configs
      enabled = function(root_dir)
        return not vim.uv.fs_stat(root_dir .. "/.luarc.json")
      end,
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
        { "nvim-dap-ui" },
      },
    },
  },
}
