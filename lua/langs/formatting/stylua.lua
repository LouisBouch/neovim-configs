local M = {
  -- use Neovim's stylua values if no workspace configs are set
  append_args = function(_, _)
    local root =
      vim.fs.find({ ".stylua.toml", "stylua.toml" }, { upward = true })[1]
    if root ~= nil then
      return {}
    else
      return {
        "--config-path",
        vim.fn.stdpath("config") .. "/stylua.toml",
      }
    end
  end,
}

return M
