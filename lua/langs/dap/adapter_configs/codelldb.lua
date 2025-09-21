local codelldb_path = os.getenv("HOME")
  .. "/.local/share/"
  .. (os.getenv("NVIM_APPNAME") or "nvim")
  .. "/mason/packages/codelldb/extension/adapter/codelldb"

local M = {
  type = "server",
  port = "${port}",
  executable = {
    command = codelldb_path,
    args = { "--port", "${port}" },
  },
  showDisassembly = "never",
}
return M
