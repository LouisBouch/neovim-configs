local M = {
  type = "codelldb",
  request = "launch",
  name = "Launch file",
  program = function()
    vim.b.debg_last_cfg = vim.b.debg_last_cfg
      or {path = vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")}
    return vim.b.debg_last_cfg.path
  end,
  cwd = "${workspaceFolder}",
  stopOnEntry = false,
}
return M
