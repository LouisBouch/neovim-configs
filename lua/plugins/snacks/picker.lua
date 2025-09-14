local custom_layout = {
  box = "vertical",
  width = 0.85,
  height = 0.85,
  {
    box = "vertical",
    border = "rounded",
    title = "{source} {live} {flags}",
    title_pos = "center",
    { win = "input", height = 1, border = "bottom" },
    { win = "list", border = "none" },
  },
  {
    win = "preview",
    border = "rounded",
    title = "{preview}",
  },
}
local function file_browser()
  local format = require("snacks.picker.format").file
  local snacks = require("snacks")
  return require("snacks").picker({
      layout = {
      preview = true,
      layout = custom_layout,
    },
    icons = {
      files = {
        enabled = true,
      }
    },
    finder = function(opts, ctx)
      local cwd= vim.fn.getcwd()
      local current_dir = ctx.picker:cwd()
      local files = vim.fn.readdir(current_dir)
      local items = {{file = "", text = "", cwd = cwd, _path = current_dir .. "/"}}
      for i, v in ipairs(files) do
        local path = current_dir .. "/" .. v
        items[#items + 1] = {file = v, text = v, cwd = cwd, _path = path}
      end
      return items
    end,
    format = function(item, picker)
      local stat = vim.uv.fs_stat(item._path)
      local is_dir = stat.type == "directory"
      local ret = format(item, picker)
      if is_dir then
        ret[1][1] = " "
        ret[1][2] = "SnacksPickerDirectory"
        ret[2][2] = "SnacksPickerDirectory"
        ret[2].field = "directory"
        if ret[2][1] == "" then
          ret[2][1] = "."
          ret[2][2] = "SnacksPickerDimmed"
          local rel_path = vim.fs.relpath(vim.fn.getcwd(), picker:cwd())
          ret[3] = {" ~/" .. rel_path,"SnacksPickerDimmed", virtual = true   }
        end
      end
      return ret
    end,
    confirm = function(picker, item)
      local is_dir = vim.uv.fs_stat(item._path).type == "directory"
      local current_dir = is_dir and item._path:gsub("/$", "") or vim.fn.fnamemodify(item._path, ":h")
      if is_dir then
        current_dir = current_dir == "" and "/" or current_dir
        picker:set_cwd(current_dir)
        picker:find()
      else
        vim.api.nvim_set_current_win(picker.finder.filter.current_win)
        picker:set_cwd(current_dir)
        picker:close()
        vim.cmd("edit " .. item._path)
      end
    end,
  })
end
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      enabled = true,
      formatters = {
        file = {
          filename_first = true, -- display filename before the file path
          truncate = 50, -- truncate the file path to (roughly) this length
        },
      },
      win = {
        -- input window
        input = {
          keys = {
            ["<A-j>"] = { {"confirm"}, mode = { "n", "i" } },
          },
        },
        list = {
          keys = {
            ["<A-j>"] = { {"confirm"}, mode = { "n", "i" } },
          },
        },
      },
    },
  },
  keys = {
    -- Find
    {
      "<leader>fr",
      function()
        require("snacks").picker.recent()
      end,
      desc = "Recent",
    },
    {
      "<leader>ff",
      function()
        require("snacks").picker.files()
      end,
      desc = "Find Files",
    },
    {
      "<leader>fb",
      function()
        require("snacks").picker.buffers()
      end,
      desc = "Buffers",
    },
    -- Grep
    {
      "<leader>sl",
      function()
        require("snacks").picker.lines()
      end,
      desc = "Buffer Lines",
    },
    {
      "<leader>sb",
      function()
        require("snacks").picker.grep_buffers()
      end,
      desc = "Grep Open Buffers",
    },
    {
      "<leader>sg",
      function()
        require("snacks").picker.grep()
      end,
      desc = "Grep",
    },
    -- Search
    {
      '<leader>sr',
      function()
        require("snacks").picker.registers()
      end,
      desc = "Registers",
    },
    {
      "<leader>sh",
      function()
        require("snacks").picker.help()
      end,
      desc = "Help Pages",
    },
        { "<leader>sH", function() Snacks.picker.highlights() end, desc = "Highlights" },
    {
      "<leader>sk",
      function()
        require("snacks").picker.keymaps()
      end,
      desc = "Keymaps",
    },
    -- LSP
    {
      "gd",
      function()
        require("snacks").picker.lsp_definitions()
      end,
      desc = "Goto Definition",
    },
    {
      "gD",
      function()
        require("snacks").picker.lsp_declarations()
      end,
      desc = "Goto Declaration",
    },
    {
      "gr",
      function()
        require("snacks").picker.lsp_references()
      end,
      nowait = true,
      desc = "References",
    },
    {
      "gI",
      function()
        require("snacks").picker.lsp_implementations()
      end,
      desc = "Goto Implementation",
    },
    {
      "gy",
      function()
        require("snacks").picker.lsp_type_definitions()
      end,
      desc = "Goto T[y]pe Definition",
    },
    {
      "<leader>ss",
      file_browser,
      desc = "Test",
    }
  },
}
