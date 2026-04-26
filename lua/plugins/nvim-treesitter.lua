return {
  "nvim-treesitter/nvim-treesitter",
  branch = "main",
  category = meta_h.categories.treesitter,
  build = ":TSUpdate",
  config = function()
    local treesitter = require("nvim-treesitter")
    local ensure_installed = {
      "regex",
      "gitignore",
      "query",
    }
    -- Merge ensure installed with list of configured filetypes/languages
    treesitter.install(vim.tbl_deep_extend("force", ensure_installed, require("langs.tools").parsers))
  end,
}
