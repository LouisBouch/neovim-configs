return {
  "smoka7/hop.nvim",
  -- Latest version has highlighting issues.
  version = "=2.7.0",
  category = meta_h.categories.editor,
  lazy = false,
  opts = function()
    -- Done within a function because require("hop.hint") is unavailable before.
    local opts = {
      keys = "asdghklqwertyuiopzxcvbnmfj",
      multi_windows = false,
      distance_method = require("hop.hint").readwise_distance,
      virtual_cursor = true,
      yank_register = "+",
    }
    return opts
  end,
  config = function(_, opts)
    local hop = require("hop")
    local hop_yank = require("hop-yank")
    -- -- THIS METHOD IS A CUSTOM FIX
    -- It allows for the pasting of text before a targeted character.
    -- It is essentially a copy-paste from the docs with an added
    -- `target.cursor.col = target.cursor.col - 1` to ensure text is pasted before the target.
    local paste_before_char1 = function(opts_temp)
      local jump_target = require("hop.jump_target")
      local jump_regex = require("hop.jump_regex")

      opts_temp = setmetatable(opts_temp or {}, { __index = hop_yank.opts })

      local c = hop.get_input_pattern("Paste 1 char", 1)
      if not c or c == "" then
        return
      end

      hop.hint_with_regex(
        jump_regex.regex_by_case_searching(c, true, opts_temp),
        opts_temp,
        function(jt)
          local target = jt

          if target == nil then
            return
          end

          jump_target.move_jump_target(target, 0, opts_temp.hint_offset)
          target.cursor.col = target.cursor.col - 1
          require("hop-yank.yank").paste_from(target, opts_temp.yank_register)
        end
      )
    end
    hop_yank.paste_before_char1 = paste_before_char1
    hop.setup(opts)
  end,
  keys = {
    -- Commands to hop lines
    {
      mode = { "n", "v" },
      "<C-j>",
      function()
        require("hop").hint_vertical({
          direction = require("hop.hint").HintDirection.AFTER_CURSOR,
        })
      end,
      desc = "Hop down to a line",
    },
    {
      mode = { "n", "v" },
      "<C-k>",
      function()
        require("hop").hint_vertical({
          direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
        })
      end,
      desc = "Hop up to a line",
    },
    -- Remaps f, F, t and T
    {
      mode = { "n", "v" },
      "<A-f>",
      function()
        require("hop").hint_char1({
          direction = require("hop.hint").HintDirection.AFTER_CURSOR,
        })
      end,
      desc = "Searches for one character forward in the file with hop (likfe f)",
    },
    {
      mode = { "n", "v" },
      "<A-F>",
      function()
        require("hop").hint_char1({
          direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
        })
      end,
      desc = "Searches for one character backward in the file with hop (like F)",
    },
    {
      mode = { "n", "v" },
      "<A-t>",
      function()
        require("hop").hint_char1({
          direction = require("hop.hint").HintDirection.AFTER_CURSOR,
          hint_offset = -1,
        })
      end,
      desc = "Searches for one character forward in the file with hop (like t)",
    },
    {
      mode = { "n", "v" },
      "<A-T>",
      function()
        require("hop").hint_char1({
          direction = require("hop.hint").HintDirection.BEFORE_CURSOR,
          hint_offset = 1,
        })
      end,
      desc = "Searches for one character backward in the file with hop (like T)",
    },
    -- Target yank/paste
    {
      mode = { "n", "v" },
      "<A-y>",
      function()
        ---@diagnostic disable-next-line: missing-parameter
        require("hop-yank").yank_char1()
        -- The warning comes from an error within neovim's api.
        -- getreg should accept 3 parameters
        -- TODO: create an issue?
        ---@diagnostic disable-next-line: redundant-parameter
        local reg = vim.fn.getreg("+", 0, true)
        vim.fn.setreg("+", reg, "v")
      end,
      desc = "Yank from afar",
    },
    {
      mode = { "n", "v" },
      "<A-p>",
      function()
        ---@diagnostic disable-next-line: missing-parameter
        require("hop-yank").paste_char1()
      end,
      desc = "Paste from afar",
    },
    {
      mode = { "n", "v" },
      "<A-P>",
      function()
        require("hop-yank").paste_before_char1({})
      end,
      desc = "Paste-before from afar",
    },
  },
}
