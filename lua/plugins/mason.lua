return {
  {
    "mason-org/mason.nvim",
    version = "^2",
    category = meta_h.categories.util,
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗",
        },
      },
    },
  },
  -- To automatically install stuff from mason.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      local ensure_installed = require("langs.tools").mason_all
      local opts = {
        ensure_installed = ensure_installed,
      }
      require("mason-tool-installer").setup(opts)
    end,
  },
}
