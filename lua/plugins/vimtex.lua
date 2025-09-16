return {
  {
    "lervag/vimtex",
    category = meta_h.categories.editor,
    init = function()
      vim.g.tex_flavor = "latex"
      vim.g.vimtex_view_method = "zathura"
      vim.g.vimtex_compiler_latexmk_engines = {
        _ = "-lualatex",
      }
    end,
  },
}
