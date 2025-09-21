return {
  "stevearc/conform.nvim",
  version = "^9",
  category = meta_h.categories.formatting,
  lazy = false,
  config = function()
    local conform = require("conform")
    local formatters_by_ft = require("langs.tools").formatters_by_ft
    conform.setup({
      formatters_by_ft = formatters_by_ft,
      format_on_save = function(_)
        -- Only format on save on specific configurations
        if
          vim.b.autoformat or (vim.b.autoformat == nil and vim.g.autoformat)
        then
          return {
            timeout_ms = 500,
            lsp_format = "fallback",
          }
        end
      end,
    })
    -- Don't auto format
    vim.g.autoformat = false

    -- Load extra configs per formatter. Suchs files are found in lua/langs/formatter/[myformatter]
    local formatters = require("langs.tools").formatters
    for _, f in ipairs(formatters) do
      local ok, cfg = pcall(require, "langs.formatting." .. f)
      if ok then
        conform.formatters[f] = cfg
      end
    end
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
