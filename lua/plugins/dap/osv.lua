local active = false
return {
  "jbyuki/one-small-step-for-vimkind",
  dependencies = {
    "mfussenegger/nvim-dap",
  },
  category = meta_h.categories.dap,
  config = function()
    vim.keymap.set("n", "<leader>ds", function()
      if active then
        require("osv").stop()
      else
        require("osv").launch({ port = 8086 })
      end
      active = not active
    end, { desc = "Launch debugger on current neovim session" })
  end,
}
