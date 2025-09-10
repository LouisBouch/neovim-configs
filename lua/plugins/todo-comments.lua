return {
  "folke/todo-comments.nvim",
  category = meta_h.categories.editor,
  dependencies = { "nvim-lua/plenary.nvim" },
  opts = {},
  keys = {
    {
      -- TODO: use whatever picker I end up installing to show the list of todos
      -- instead of this builtin buffer.
      "<leader>xt",
      "<cmd>TodoQuickFix<cr>",
      desc = "List all todos (Todo Comments)",
    },
  }
}
