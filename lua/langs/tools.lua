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
---@field name string Name of the tool used by the configs
---@field mason? {name?: string} If present, install tool with mason. No name means use default plugin name

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
    formatters = { { name = "stylua", mason = {} } },
    linters = { { name = "selene", mason = {} } },
    lang_servs = {
      { name = "lua_ls", mason = { name = "lua-language-server" } },
    },
    debug_adps = { { name = "osv_lua" } },
  },
  rust = { -- Rust, .rs
    parser = "rust",
    lang_servs = {
      { name = "rust_analyzer", mason = { name = "rust-analyzer" } },
    },
  },
  c = { -- C, .c .h
    parser = "c",
  },
  cpp = { -- C++, .cpp .hpp
    parser = "cpp",
    formatters = { { name = "clang-format", mason = {} } },
    lang_servs = { { name = "clangd", mason = {} } },
    debug_adps = { { name = "codelldb", mason = {} } },
  },
  markdown = { -- Markdown, .md
    parser = "markdown",
    formatters = { { name = "prettier", mason = {} } },
  },
  css = { -- CSS, .css
    parser = "css",
    formatters = { { name = "prettier", mason = {} } },
  },
  html = { -- HTML, .html
    parser = "html",
    formatters = { { name = "prettier", mason = {} } },
  },
  sql = { -- SQL, .sql
    parser = "sql",
  },
  java = {
    parser = "java",
  },
  javascript = { -- Javascript, .js
    parser = "javascript",
    formatters = { { name = "prettier", mason = {} } },
  },
  javascriptreact = { -- Javascript + jsx, .jsx
    parser = "tsx",
    formatters = { { name = "prettier", mason = {} } },
  },
  typescript = { -- Typescript, .ts
    parser = "typescript",
    formatters = { { name = "prettier", mason = {} } },
  },
  typescriptreact = { -- Typescript + tsx, .tsx
    parser = "tsx",
    formatters = { { name = "prettier", mason = {} } },
  },
  json = { --- Json, .json
    parser = "json",
    formatters = { { name = "prettier", mason = {} } },
  },
  python = { -- Python, .py
    parser = "python",
    formatters = { { name = "ruff", mason = {} } },
  },
  tex = { -- Latex, .tex
    parser = "latex",
    formatters = { { name = "tex-fmt", mason = {} } },
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
local function get_parsers(cfgs)
  local parsers = { set = {}, list = {} }
  for _, info in pairs(cfgs.ft_cfgs) do
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
---@param cfgs table<string, Filetype> The table of file type
---@param tool_type ToolType Type of the tools (formatter, linter, ...)
---@param use_mason_name boolean Whether to fetch the mason name if available
---@return string[] A list containing the list of unique tool names
local function get_tools(cfgs, tool_type, use_mason_name)
  local tool_list = { set = {}, list = {} }
  for _, lists in pairs(cfgs.ft_cfgs) do
    for _, l in pairs(lists[tool_type] or {}) do
      -- Ensures nothing is added if we require mason but mason is undefined.
      if not (use_mason_name and not l.mason) then
        add(tool_list, use_mason_name and (l.mason.name or l.name) or l.name)
      end
    end
  end
  return tool_list.list
end

local function get_tools_by_ft(cfgs, tool)
  local tools_by_ft = {}
  for ft, lists in pairs(cfgs.ft_cfgs) do
    local tools = {}
    for _, f in pairs(lists[tool] or {}) do
      table.insert(tools, f.name)
    end
    if #tools > 0 then
      tools_by_ft[ft] = tools
    end
  end
  return tools_by_ft
end

local function get_fts(cfgs)
  local fts = {}
  for ft, _ in pairs(cfgs.ft_cfgs) do
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

M.mason_formatters = get_tools(M, M.types.formatters, true)
M.mason_linters = get_tools(M, M.types.linters, true)
M.mason_lang_servs = get_tools(M, M.types.lang_servs, true)
M.mason_debug_adps = get_tools(M, M.types.debug_adps, true)
M.mason_all = merge_tables({
  M.mason_formatters,
  M.mason_linters,
  M.mason_lang_servs,
  M.mason_debug_adps,
})

M.formatters = get_tools(M, M.types.formatters, false)
M.linters = get_tools(M, M.types.linters, false)
M.lang_servs = get_tools(M, M.types.lang_servs, false)
M.debug_adps = get_tools(M, M.types.debug_adps, false)

M.formatters_by_ft = get_tools_by_ft(M, M.types.formatters)
M.linters_by_ft = get_tools_by_ft(M, M.types.linters)
return M
