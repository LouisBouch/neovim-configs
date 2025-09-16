local custom_layout = {
  box = "vertical",
  width = 0.9,
  height = 0.9,
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
  local dformat = require("snacks.picker.format").file
  local dpreview = require("snacks.picker.preview").file
  local snacks = require("snacks")
  -- Buffer info
  local current_buf = vim.api.nvim_get_current_buf()
  local buf_path = vim.api.nvim_buf_get_name(current_buf)
  local buf_dir = buf_path == "" and vim.fn.getcwd()
    or vim.fn.fnamemodify(buf_path, ":h")
  -- Used to find which items to show in the picker
  local finder = function(opts, ctx)
    local cwd = vim.fn.getcwd()
    local current_dir = ctx.picker:cwd()
    local files = vim.fn.readdir(current_dir)
    local items = {
      {
        file = "",
        text = "",
        cwd = cwd,
        _path = current_dir .. "/",
        type = "directory",
      },
    }
    for i, v in ipairs(files) do
      -- local path = current_dir .. "/" .. v
      local path = current_dir == "/" and current_dir .. v
        or current_dir .. "/" .. v
      local stat = vim.uv.fs_stat(path)
      local type = nil
      local is_link = false
      if stat then
        type = stat.type
      end
      if vim.uv.fs_lstat(path).type == "link" then
        is_link = true
      end
      items[#items + 1] = {
        file = v,
        text = v,
        cwd = cwd,
        _path = path,
        type = type,
        is_link = is_link,
      }
    end
    -- Sort with directories first
    local type_prio = {
      directory = 0,
      file = 1,
    }
    table.sort(items, function(a, b)
      pa = type_prio[a.type] or 1
      pb = type_prio[b.type] or 1
      if pa ~= pb then
        return pa < pb
      end
      return a.file < b.file
    end)
    return items
  end
  -- Used to format entries
  local format = function(item, picker)
    local ret = dformat(item, picker)
    if item.is_link then
      local link = "-> " .. vim.uv.fs_readlink(item._path)
      local highlight = not item.type and "SnacksPickerLinkBroken"
        or "SnacksPickerPathHidden"
      ret[#ret + 1] = { link, highlight, virtual = true }
    end
    if item.type == "directory" then
      ret[1][1] = " "
      ret[1][2] = "SnacksPickerDirectory"
      ret[2][2] = "SnacksPickerDirectory"
      ret[2].field = "directory"
      if ret[2][1] == "" then
        ret[2][1] = "."
        local rel_path = vim.fs.relpath(vim.fn.getcwd(), picker:cwd())
        local path_print = (
          (rel_path and " ~/" .. rel_path) or " " .. picker:cwd()
        )
        ret[3] = { path_print, "SnacksPickerPathHidden", virtual = true }
      end
    end
    return ret
  end
  -- Used to populate preview window
  local preview = function(ctx)
    local item = ctx.item
    local picker = ctx.picker

    local ns = vim.api.nvim_create_namespace("snacks.picker.preview")
    if item.type == "directory" then
      ctx.preview:reset()
      ctx.preview:minimal()
      -- Create empty lines to populate later
      local picker_dir = picker:cwd()
      local item_dir = item._path:gsub("(.+)/$", "%1") -- Keeps slash if root

      picker:set_cwd(item_dir) -- Simulate being in the directory below

      local entries = finder(picker.opts, ctx)

      ctx.preview:set_lines(vim.split(string.rep("\n", #entries - 1), "\n"))
      for i, entry in pairs(entries) do
        local line = {}
        local f_entry = format(entry, picker)
        for col, text in ipairs(f_entry) do
          line[col] = { text[1], text[2] }
        end
        vim.api.nvim_buf_set_extmark(
          ctx.buf,
          ns,
          i - 1,
          0,
          { virt_text = line }
        )
      end
      picker:set_cwd(picker_dir) -- Reset directory
    else
      -- Default preview
      dpreview(ctx)
    end
  end
  -- Executed on confirm
  local confirm = function(picker, item)
    if not item or not item.type then
      return
    end
    local is_dir = item.type == "directory"
    if is_dir then
      local item_dir = item._path:gsub("(.+)/$", "%1") -- Keeps slash if root
      picker:set_cwd(item_dir)
      -- Clear pattern
      vim.api.nvim_buf_set_lines(picker.input.win.buf, 0, -1, false, { "" })
      picker:find()
    else
      local current_dir = vim.fn.fnamemodify(item._path, ":h")
      vim.api.nvim_set_current_win(picker.finder.filter.current_win)
      picker:close()
      vim.cmd("edit " .. item._path)
    end
  end
  require("snacks").picker.pick({
    cwd = buf_dir,
    win = {
      input = {
        keys = {
          ["<C-g>"] = { "to_parent", mode = { "n", "i" } },
          ["<C-s>"] = { "set_cwd", mode = { "n", "i" } },
          ["<C-t>"] = { "to_cwd", mode = { "n", "i" } },
        },
      },
      list = {
        keys = {
          ["<C-g>"] = { "to_parent", mode = { "n", "i" } },
          ["<C-s>"] = { "set_cwd", mode = { "n", "i" } },
          ["<C-t>"] = { "to_cwd", mode = { "n", "i" } },
        },
      },
    },
    layout = {
      preview = true,
      layout = custom_layout,
    },
    icons = {
      files = {
        enabled = true,
      },
    },
    preview = preview,
    finder = finder,
    format = format,
    confirm = confirm,
    actions = {
      to_parent = function(picker, item)
        local current_dir = picker:cwd():gsub("(.+)/$", "%1")
        local parent_dir = vim.fn.fnamemodify(current_dir, ":h")
        local prev_dir_name = vim.fn.fnamemodify(current_dir, ":t")
        picker:set_cwd(parent_dir)

        -- Select previous directory
        picker:find({
          on_done = function()
            local items = picker:items()
            for i, item in pairs(items) do
              if item.file == prev_dir_name then
                picker.list:view(item.idx)
                require("snacks.picker.actions").list_scroll_center(picker)
              end
            end
          end,
        })
      end,
      to_cwd = function(picker, item)
        local cwd = vim.fn.getcwd()
        picker:set_cwd(cwd)
        picker:find()
      end,
      set_cwd = function(picker, item)
        local current_dir = picker:cwd()
        vim.cmd("cd " .. current_dir)
        vim.notify("Set cwd to: " .. current_dir)
        -- Update first directory path with new cwd
        picker.list.dirty = true
        picker.list:render()

        -- Works too, but flashes
        -- local old_top = picker.list.top
        -- picker:find({on_done = function()
        --   picker.list:view(item.idx, old_top)
        -- end})
      end,
    },
  })
end
-- START
return {
  "folke/snacks.nvim",
  dependencies = { "folke/trouble.nvim" },
  opts = function(_, opts)
    return vim.tbl_deep_extend("force", opts or {}, {
      picker = {
        enabled = true,
        formatters = {
          file = {
            filename_first = true, -- display filename before the file path
            truncate = 50, -- truncate the file path to (roughly) this length
          },
        },
        actions = {
          copy_path = function(picker, item)
            vim.fn.setreg("+", item._path)
            vim.notify("Copied: " .. item._path)
          end,
          trouble_open = require("trouble.sources.snacks").actions.trouble_open,
        },
        win = {
          -- input window
          input = {
            keys = {
              ["<A-j>"] = { { "confirm" }, mode = { "n", "i" } },
              ["<C-y>"] = { "copy_path", mode = { "n", "i" } },
              ["<C-b>"] = { "trouble_open", mode = { "n", "i" } },
            },
          },
          list = {
            keys = {
              ["<A-j>"] = { { "confirm" }, mode = { "n", "i" } },
              ["<C-y>"] = { "copy_path", mode = { "n", "i" } },
              ["<C-b>"] = { "trouble_open", mode = { "n", "i" } },
            },
          },
        },
      },
    })
  end,
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
      "<leader>sr",
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
    {
      "<leader>sk",
      function()
        require("snacks").picker.keymaps()
      end,
      desc = "Keymaps",
    },
    {
      "<leader>sm",
      function()
        require("snacks").picker.marks()
      end,
      desc = "Marks",
    },
    {
      "<leader>sH",
      function()
        Snacks.picker.highlights()
      end,
      desc = "Highlights",
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
    -- Others
    {
      "<leader>tb",
      file_browser,
      desc = "Telescope-like file browser",
    },
  },
}
