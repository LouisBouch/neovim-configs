return {
  {
    "folke/lazydev.nvim",
    ft = "lua", -- only load on lua files
    version = "^1",
    category = meta_h.categories.lsp,
    opts = {
      library = {
        -- Load luvit types when the `vim.uv` word is found
        { path = "${3rd}/luv/library", words = { "vim%.uv" } },
        { path = "snacks.nvim", words = { "Snacks" } },
      },
    },
  },
}
