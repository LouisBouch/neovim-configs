return {
  "stevearc/conform.nvim",
  version = "^9",
  category = meta_h.categories.formatting,
  lazy = false,
  config = function()
    local conform = require("conform")
    conform.setup({
      -- TODO: centralized list of formatters to use here and in mason.lua
      formatters_by_ft = {
        cpp = { "clang-format" },
        lua = { "stylua" },
        markdown = { "prettier" },
        css = { "prettier" },
        html = { "prettier" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        python = { "ruff" },
      },
      format_on_save = function(bufnr)
        -- Disable formatting when specified
        if
          vim.b.autoformat or (vim.b.autoformat == nil and vim.g.autoformat)
        then
          return {
            timeout_ms = 500,
            lsp_format = "fallback",
          }
        end
        return
      end,
    })
    -- Don't auto format
    vim.g.autoformat = false
  end,
  keys = {
    {
      "<leader>fo",
      function()
        require("conform").format({
          lsp_fallback = true,
          asunc = false,
          timeout = 500,
          quiet = false,
        })
      end,
      mode = { "n", "v" },
    },
  },
}
