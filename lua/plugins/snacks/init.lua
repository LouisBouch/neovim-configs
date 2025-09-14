-- Contains folke/snacks related plugin configurations
return {
  { import = "plugins.snacks" },
  {
    "folke/snacks.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      toggle = { enabled = false },
      words = { enabled = false },
      statuscolumn = { enabled = false },
      scroll = { enabled = false },
      quickfile = { enabled = false },
      notifier = { enabled = false },
      lazygit = { enabled = false },
      input = { enabled = false },
      image = { enabled = false },
      dashboard = { enabled = false },
      bigfile = { enabled = false },
      terminal = { enabled = false },
    },
  },
}
