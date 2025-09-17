return {
  "nvim-treesitter/nvim-treesitter",
  category = meta_h.categories.treesitter,
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter.configs")
    local ensure_installed = {
      "regex",
      "gitignore",
      "query",
    }
    -- Merge ensure installed with list of configured filetypes/languages
    ensure_installed = vim.tbl_deep_extend("force", ensure_installed, {})
    treesitter.setup({
      ensure_installed = ensure_installed,
      -- Enable syntax highlighting
      highlight = {
        enable = true,
        -- Disable treesitter for large files and specific languages
        disable = function(lang, buf)
          -- List of languages with disabled treesitter
          local disabled_languages = { -- set to true to disable
            ["lua"] = false,
          }
          local max_filesize = 100 * 1024 -- 100 KB
          local ok, stats =
            pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
          if ok and stats and stats.size > max_filesize then
            return true
          end
          if disabled_languages[lang] then
            return true
          end
        end,
        -- Remove vim syntax highlight
        additional_vim_regex_highlighting = false,
      },
      -- Enable indentation
      indent = { enable = true },
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "gnn", -- set to `false` to disable one of the mappings
          node_incremental = "grn",
          scope_incremental = false,
          node_decremental = "grm",
        },
      },
    })
  end,
}
