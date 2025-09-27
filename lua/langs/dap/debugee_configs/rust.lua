local M = require("langs.dap.debugee_configs.cpp")
M.program = function()
  vim.b.debg_last_cfg = vim.b.debg_last_cfg
    or {
      path = vim.fn.input(
        "Path to executable: ",
        vim.fn.getcwd() .. "/target/debug/",
        "file"
      ),
    }
  return vim.b.debg_last_cfg.path
end

return M
