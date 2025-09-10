return {
  "folke/noice.nvim",
  category = meta_h.categories.ui,
  event = "VeryLazy",
  -- enabled = false,
  opts = {
    cmdline = {
      view = "cmdline",
      format = {
        cmdline = false,
        search_down = false,
        search_up = false,
        filter = false,
        lua = false,
        help = false,
        input = false,
      },
    },
    messages = {
      view = "mini",
      view_error = "mini",
      view_warn = "mini",
      view_history = "messages",
      view_search = "virtualtext",
    },
    -- Everything bellow is disabled for now, until I know what they do.
    popupmenu = {
      enabled = false,
      view = "cmdline",
    },
    redirect = {
      enabled = false,
      view = "popup",
      filter = { event = "msg_show" },
    },
    notify = {
      enabled = false,
      view = "cmdline",
    },
    lsp = {
      enabled = false,
      override = {
        -- override the default lsp markdown formatter with Noice
        ["vim.lsp.util.convert_input_to_markdown_lines"] = false,
        -- override the lsp markdown formatter with Noice
        ["vim.lsp.util.stylize_markdown"] = false,
        -- override cmp documentation with Noice (needs the other options to work)
        ["cmp.entry.get_documentation"] = false,
      },
      hover = {
        enabled = false,
        silent = false, -- set to true to not show a message if hover is not available
        view = nil, -- when nil, use defaults from documentation
        ---@type NoiceViewOptions
        opts = {}, -- merged with defaults from documentation
      },
      signature = {
        enabled = false,
        auto_open = {
          enabled = true,
          trigger = true, -- Automatically show signature help when typing a trigger character from the LSP
          luasnip = true, -- Will open signature help when jumping to Luasnip insert nodes
          throttle = 50, -- Debounce lsp signature help request by 50ms
        },
        view = nil, -- when nil, use defaults from documentation
        ---@type NoiceViewOptions
        opts = {}, -- merged with defaults from documentation
      },
      message = {
        -- Messages shown by lsp servers
        enabled = false,
        view = "notify",
        opts = {},
      },
      -- defaults for hover and signature help
      documentation = {
        view = "hover",
        ---@type NoiceViewOptions
        opts = {
          lang = "markdown",
          replace = true,
          render = "plain",
          format = { "{message}" },
          win_options = { concealcursor = "n", conceallevel = 3 },
        },
      },
    },
    markdown = {
      enabled = false,
      hover = {
        ["|(%S-)|"] = vim.cmd.help, -- vim help links
        ["%[.-%]%((%S-)%)"] = require("noice.util").open, -- markdown links
      },
      highlights = {
        ["|%S-|"] = "@text.reference",
        ["@%S+"] = "@parameter",
        ["^%s*(Parameters:)"] = "@text.title",
        ["^%s*(Return:)"] = "@text.title",
        ["^%s*(See also:)"] = "@text.title",
        ["{%S-}"] = "@parameter",
      },
    },
    health = {
      checker = true, -- Disable if you don't want health checks to run
    },
    -- ---@type NoicePresets
    -- presets = {
    --   -- you can enable a preset by setting it to true, or a table that will override the preset config
    --   -- you can also add custom presets that you can enable/disable with enabled=true
    --   bottom_search = false, -- use a classic bottom cmdline for search
    --   command_palette = false, -- position the cmdline and popupmenu together
    --   long_message_to_split = false, -- long messages will be sent to a split
    --   inc_rename = false, -- enables an input dialog for inc-rename.nvim
    --   lsp_doc_border = false, -- add a border to hover docs and signature help
    -- },
    -- throttle = 1000 / 30, -- how frequently does Noice need to check for ui updates? This has no effect when in blocking mode.
    -- ---@type NoiceConfigViews
    -- views = {}, ---@see section on views
    -- ---@type NoiceRouteConfig[]
    -- routes = {}, --- @see section on routes
    -- ---@type table<string, NoiceFilter>
    -- status = {}, --- @see section on statusline components
    -- ---@type NoiceFormatOptions
    -- format = {}, --- @see section on formatting
  },
  dependencies = {
    "MunifTanjim/nui.nvim",
    -- OPTIONAL:
    --   `nvim-notify` is only needed, if you want to use the notification view.
    --   If not available, we use `mini` as the fallback
    "rcarriga/nvim-notify",
  },
}
