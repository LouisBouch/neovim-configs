---Contents of a formatted category
---@class Category
---@field category string Name of the category.
---@field desc string String used in the README file to describe it.
---Category object containing all possible types of plugins with their description
---@class Categories
---@field colorscheme Category
---@field ui Category
---@field coding Category
---@field editor Category
---@field formatting Category
---@field linting Category
---@field lsp Category
---@field treesitter Category
---@field other Category

---Defines possible categories for the plugins.
---The key represents the category and the value represents what title will be used in the README.
---Names are defined later to avoid having to type the category name twice.
---@type Categories
local cat_def = {
  colorscheme = {
    category = "",
    desc = "Colorschemes: Provide color palettes to be chosen from when opening a neovim sessions.",
  },
  ui = {
    category = "",
    desc = "UI: Enhance the user interface with features such as status line, buffer line, indentation guides, dashboard, and icons.",
  },
  coding = {
    category = "",
    desc = "Coding: Allow faster coding with features such as snippets, autocompletion, and more.",
  },
  editor = {
    category = "",
    desc = "Editor: Provide functionality like a file explorer, search and replace, fuzzy finding, git integration.",
  },
  lsp = {
    category = "",
    desc = "LSP: Configure the Language Server Protocol (LSP) client.",
  },
  formatting = {
    category = "",
    desc = "Formatting: Set up formatters using *conform.nvim*.",
  },
  linting = {
    category = "",
    desc = "Linting: Manage linters with the *nvim-lint* plugin.",
  },
  treesitter = {
    category = "",
    desc = "Treesitter: Provide advanced syntax highlighting and plugins that use Treesitter parsers.",
  },
  util = {
    category = "",
    desc = "Util: Contains utilities for session management, shared functionality, and other handy tools.",
  },
  other = {
    category = "",
    desc = "Others (mostly dependencies from other plugins)",
  },
}
---Given a list of category definitions, complete the categories.
---@param cats Categories
---@return Categories
local function format_categories(cats)
  local categories = {}
  for k, v in pairs(cats) do
    categories[k] = { category = k, desc = v.desc }
  end
  return categories
end
meta_h.categories = format_categories(cat_def)

-- Fill a table with the list of current plugins.
local function fill_table()
  local plugins = require("lazy.core.config").spec.plugins
  local plug_table = {}

  -- Gets general plugin info in a table
  for name, plug in pairs(plugins) do
    local mt_index = getmetatable(plug).__index
    -- General plugin info
    local plug_id = mt_index[1]
    local plug_category = mt_index.category or meta_h.categories.other
    local dep_ids = mt_index.dependencies or {}

    -- Build the table from the plugin info
    plug_table[plug_id] = {
      name = name,
      id = plug_id,
      dependencies = dep_ids,
      category = plug_category,
    }
  end
  -- Resolve dependencies (add their names)
  for _, plug in pairs(plug_table) do
    if next(plug.dependencies) ~= nil then
      local dependencies = {}
      for _, d_id in pairs(plug.dependencies) do
        local name = plug_table[d_id].name
        table.insert(dependencies, { id = d_id, name = name })
      end
      plug.dependencies = dependencies
    end
  end
  return plug_table
end
-- Given a table of plugins, separate it given the different categories.
local function add_table_categories(plug_table)
  local formatted_table = {}
  for _, plug in pairs(plug_table) do
    local plug_category = plug.category
    -- Build the table from the plugin info
    formatted_table[plug_category.category] = formatted_table[plug_category.category]
      or {}
    table.insert(formatted_table[plug_category.category], {
      name = plug.name,
      dependencies = plug.dependencies,
      id = plug.id,
    })
    -- Add category description
    formatted_table[plug_category.category].desc = plug_category.desc
  end
  return formatted_table
end

-- Formats the table of plugin to markdown.
-- Each consecutive item in the table is a markdown line.
local function to_md_table(plug_table)
  local formatted_lines = {}
  -- Given a plugin, convert it into a text entry
  local function to_entry(plugin)
    local pname = plugin.name
    local pid = plugin.id
    return string.format("[%s](https://github.com/%s)", pname, pid)
  end
  -- Converts a single category of plugins into the markdown table.
  local function category_to_md(plugins)
    local category_desc = plugins.desc
    -- The prefix for the category header.
    local prefix = "### "
    table.insert(formatted_lines, prefix .. category_desc)
    table.insert(formatted_lines, "")

    -- Sort category's plugins by name.
    table.sort(plugins, function(a, b)
      return a.name < b.name
    end)
    for _, plugin in ipairs(plugins) do
      -- Prefix for the plugin entry.
      prefix = "- "
      table.insert(formatted_lines, prefix .. to_entry(plugin))

      -- Sort plugin's dependencies by name.
      table.sort(plugin.dependencies, function(a, b)
        return a.name < b.name
      end)
      for _, dep in ipairs(plugin.dependencies) do
        -- Prefix for dependency entry.
        prefix = "  - "
        table.insert(formatted_lines, prefix .. to_entry(dep))
      end
    end
  end
  for category, plugins in pairs(plug_table) do
    -- Convert every regular category to markdown.
    if category ~= meta_h.categories.other.category then
      category_to_md(plugins)
      table.insert(formatted_lines, "")
    end
  end
  -- Handle the "other" category last for visual consistency.
  if plug_table.other ~= nil then
    category_to_md(plug_table.other)
  else
    -- Remove last newline if there is no "other" category.
    table.remove(formatted_lines)
  end
  return formatted_lines
end

-- Create a custom command when in the README.md file to automatically generate
-- part of it.
vim.api.nvim_create_augroup("meta", { clear = true })
vim.api.nvim_create_autocmd({ "BufRead" }, {
  group = "meta",
  pattern = vim.fn.stdpath("config") .. "/README.md",
  callback = function(event)
    vim.keymap.set("n", "<leader><Enter>", function()
      local plug_table = fill_table()
      local formatted_table = add_table_categories(plug_table)
      local md = to_md_table(formatted_table)
      vim.api.nvim_put(md, "l", true, false)
    end, { buffer = event.buf })
  end,
})
