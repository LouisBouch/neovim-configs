return {
  "smoka7/hop.nvim",
  category = meta_h.categories.editor,
  -- Latest version has highlighting issues.
  version = "=2.7.0",
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
    local dirs = require("hop.hint").HintDirection
    local hop_yank = require("hop-yank")
    -- -- THIS METHOD IS A CUSTOM FIX
    -- It allows for the pasting of text before a targeted character.
    -- It is essentially a copy-paste from the docs with an added
    -- `target.cursor.col = target.cursor.col - 1` to ensure text is pasted before the target.
    local paste_before_char1 = function(opts_temp)
      -- local hop = require("hop")
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
    -- Remaps f, F, t and T
    vim.keymap.set({"n", "v"}, "<A-f>", function()
      hop.hint_char1({ direction = dirs.AFTER_CURSOR })
    end, {
      desc = "Searches for one character forward in the file with hop (likfe f)",
    })
    vim.keymap.set({"n", "v"}, "<A-F>", function()
      hop.hint_char1({ direction = dirs.BEFORE_CURSOR })
    end, {
      desc = "Searches for one character backward in the file with hop (like F)",
    })
    vim.keymap.set({"n", "v"}, "<A-t>", function()
      hop.hint_char1({ direction = dirs.AFTER_CURSOR, hint_offset = -1 })
    end, {
      desc = "Searches for one character forward in the file with hop (like t)",
    })
    vim.keymap.set({"n", "v"}, "<A-T>", function()
      hop.hint_char1({ direction = dirs.BEFORE_CURSOR, hint_offset = 1 })
    end, {
      desc = "Searches for one character backward in the file with hop (like T)",
    })

    -- Commands to hop lines
    vim.keymap.set({"n", "v"}, "<C-j>", function()
      hop.hint_vertical({ direction = dirs.AFTER_CURSOR })
    end, {
      desc = "Hop down to a line",
    })
    vim.keymap.set({"n", "v"}, "<C-k>", function()
      hop.hint_vertical({ direction = dirs.BEFORE_CURSOR })
    end, {
      desc = "Hop up to a line",
    })
    -- Target yank/paste
    vim.keymap.set({"n", "v"}, "<A-y>", function()
      hop_yank.yank_char1()
      -- The warning comes from an error within neovim's api.
      -- getreg should accept 3 parameters
      -- TODO: create an issue?
      ---@diagnostic disable-next-line: redundant-parameter
      local reg = vim.fn.getreg("+", 0, true)
      vim.fn.setreg("+", reg, "v")
    end, {
      desc = "Yank from afar",
    })
    vim.keymap.set({"n", "v"}, "<A-p>", function()
      hop_yank.paste_char1()
    end, {
      desc = "Paste from afar",
    })
    vim.keymap.set({"n", "v"}, "<A-P>", function()
      hop_yank.paste_before_char1({})
    end, {
      desc = "Paste-before from afar",
    })
    hop.setup(opts)
  end,
}
