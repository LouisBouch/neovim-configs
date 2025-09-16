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
    opts = {
      ensure_installed = {
        -- LSP
        "lua-language-server", -- lspname: lua_ls
        -- DAP
        -- Linter
        -- Formatter
        "stylua",
        "clang-format",
        "prettier",
        "ruff",
      },
    },
  },
}
