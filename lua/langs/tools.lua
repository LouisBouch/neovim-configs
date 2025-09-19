-- -- IMPORTANT
-- Even though we usually think about programming languages when we code, neovim
-- only sees filetypes. For this reason, if you want to setup linting/formatting
-- and more for a specific language, you should set it up for its corresponding
-- filetype(s).
-- To see which filetype a buffer uses, run `:set filetype?`, or run
-- `:lua print(vim.filetype.match { filename = ".rs" })` with the actual file
-- extension and not ".rs".
-- For a list of filetypes, see [https://github.com/neovim/neovim/blob/master/runtime/lua/vim/filetype.lua#L2451]
-- Similarly, for a list of parsers, see [https://github.com/tree-sitter/tree-sitter/wiki/List-of-parsers]
--
-- Also, this here is only for listing the tools used. To access the configs for
-- each filetype, go to the corresponding ./lua/langs/...

---@class Tool
---@field mason_name string Name of the tool within Mason's registry
---@field plugin_name? string Name the plugin uses for the tool

---@class Filetype
---@field parser? string Tree-sitter parser
---@field formatters? Tool[] List of formatters
---@field linters? Tool[] List of linters
---@field lang_servs? Tool[] Language server(s) (Almost always just one)
---@field debug_adps? Tool[] Debug adapter(s) (Almost always just one)

local M = {}

-- List of language servers/debug adapters/... for each filetype
---@type table<string, Filetype>
M.ft_cfgs = {
  lua = { -- Lua, .lua
    parser = "lua",
    formatters = { { mason_name = "stylua" } },
    lang_servs = {
      { mason_name = "lua-language-server", plugin_name = "lua_ls" },
    },
  },
  rust = { -- Rust, .rs
    parser = "rust",
    lang_servs = { { mason_name = "rust-analyzer", plugin_name = "rust_analyzer" } },
  },
  c = { -- C, .c .h
    parser = "c",
  },
  cpp = { -- C++, .cpp .hpp
    parser = "cpp",
    formatters = { { mason_name = "clang-format" } },
    lang_servs = { { mason_name = "clangd" } },
  },
  markdown = { -- Markdown, .md
    parser = "markdown",
    formatters = { { mason_name = "prettier" } },
  },
  css = { -- CSS, .css
    parser = "css",
    formatters = { { mason_name = "prettier" } },
  },
  html = { -- HTML, .html
    parser = "html",
    formatters = { { mason_name = "prettier" } },
  },
  sql = { -- SQL, .sql
    parser = "sql",
  },
  java = {
    parser = "java",
  },
  javascript = { -- Javascript, .js
    parser = "javascript",
    formatters = { { mason_name = "prettier" } },
  },
  javascriptreact = { -- Javascript + jsx, .jsx
    parser = "tsx",
    formatters = { { mason_name = "prettier" } },
  },
  typescript = { -- Typescript, .ts
    parser = "typescript",
    formatters = { { mason_name = "prettier" } },
  },
  typescriptreact = { -- Typescript + tsx, .tsx
    parser = "tsx",
    formatters = { { mason_name = "prettier" } },
  },
  json = { --- Json, .json
    parser = "json",
    formatters = { { mason_name = "prettier" } },
  },
  python = { -- Python, .py
    parser = "python",
    formatters = { { mason_name = "ruff" } },
  },
  tex = { -- Latex, .tex
    parser = "latex",
    formatters = { { mason_name = "tex-fmt" } },
  },
  sh = { -- Bash, .sh
    parser = "bash",
  },
  vim = { -- Vimscript, .vim
    parser = "vim",
  },
}

--------------------------------------------------------------------------------
--------------------------------------------------------------------------------
--------------------------------------------------------------------------------

-- Helper method to add item in a set
local function add(t, i)
  if not t.set[i] then
    t.set[i] = true
    table.insert(t.list, i)
  end
end

-- Helper methods to fetch required values from fts
local function get_parsers(M)
  local parsers = { set = {}, list = {} }
  for _, info in pairs(M.ft_cfgs) do
    add(parsers, info.parser)
  end
  return parsers.list
end
---@alias ToolType "formatters" | "linters" | "lang_servs" | "debug_adps"

---@type table<ToolType, ToolType>
M.types = {
  formatters = "formatters",
  linters = "linters",
  lang_servs = "lang_servs",
  debug_adps = "debug_adps",
}

---Fetch the list of required tools.
---@param M table<string, Filetype> The table of file type
---@param tool_type ToolType Type of the tools (formatter, linter, ...)
---@param use_plugin_name boolean Whether to use the plugin name if available
---@return string[] A list containing the list of unique tool names
local function get_tools(M, tool_type, use_plugin_name)
  local tool_list = { set = {}, list = {} }
  for _, lists in pairs(M.ft_cfgs) do
    for _, l in pairs(lists[tool_type] or {}) do
      add(tool_list, use_plugin_name and l.plugin_name or l.mason_name)
    end
  end
  return tool_list.list
end

local function get_formatters_by_ft(M)
  local formatters_by_ft = {}
  for ft, lists in pairs(M.ft_cfgs) do
    local formatters = {}
    for _, f in pairs(lists.formatters or {}) do
      table.insert(formatters, f.plugin_name or f.mason_name)
    end
    if #formatters > 0 then
      formatters_by_ft[ft] = formatters
    end
  end
  return formatters_by_ft
end

local function get_fts(M)
  local fts = {}
  for ft, _ in pairs(M.ft_cfgs) do
    table.insert(fts, ft)
  end
  return fts
end

-- Merges multiple indexed tables
local function merge_tables(ts)
  local merged = {}
  for _, t in ipairs(ts) do
    for _, v in ipairs(t) do
      table.insert(merged, v)
    end
  end
  return merged
end

M.parsers = get_parsers(M)
M.fts = get_fts(M)



M.mason_formatters = get_tools(M, M.types.formatters, false)
M.mason_linters = get_tools(M, M.types.linters, false)
M.mason_lang_servs = get_tools(M, M.types.lang_servs, false)
M.mason_debug_adps = get_tools(M, M.types.debug_adps, false)
M.mason_all = merge_tables({
  M.mason_formatters,
  M.mason_linters,
  M.mason_lang_servs,
  M.mason_debug_adps,
})

M.formatters = get_tools(M, M.types.formatters, true)
M.linters = get_tools(M, M.types.linters, true)
M.lang_servs = get_tools(M, M.types.lang_servs, true)
M.debug_adps = get_tools(M, M.types.debug_adps, true)

M.formatters_by_ft = get_formatters_by_ft(M)
return M
