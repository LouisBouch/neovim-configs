return {
  "stevearc/conform.nvim",
  version = "^9",
  category = meta_h.categories.formatting,
  lazy = false,
  config = function()
    local conform = require("conform")
    formatters_by_ft = require("langs.tools").formatters_by_ft
    conform.setup({
      formatters_by_ft = formatters_by_ft,
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
          async = false,
          timeout = 500,
          quiet = false,
        })
      end,
      mode = { "n", "v" },
    },
  },
}
