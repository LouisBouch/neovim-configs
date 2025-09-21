return {
  "mfussenegger/nvim-dap",
  category = meta_h.categories.dap,
  version = "^1",
  config = function()
    local dap = require("dap")

    -- Keymaps
    vim.keymap.set("n", "<Left>", function()
      dap.step_out()
    end, { desc = "Step out" })

    vim.keymap.set("n", "<Right>", function()
      dap.step_into()
    end, { desc = "Step into" })

    vim.keymap.set("n", "<Down>", function()
      dap.step_over()
    end, { desc = "Step over" })

    vim.keymap.set("n", "<S-Right>", function()
      dap.continue()
    end, { desc = "Resume debugger" })

    vim.keymap.set("n", "<leader>db", function()
      dap.toggle_breakpoint()
    end, { desc = "Toggle breakpoint" })

    vim.keymap.set("n", "<leader>dB", function()
      dap.set_breakpoint()
    end, { desc = "Set breakpoint" })

    vim.keymap.set("n", "<leader>dc", function()
      dap.run_to_cursor()
    end, { desc = "Run to cursor" })

    vim.keymap.set("n", "<Leader>dl", function()
      dap.run_last()
    end, { desc = "Run last" })

    vim.keymap.set({ "n", "v" }, "<Leader>dh", function()
      require("dap.ui.widgets").hover()
    end)

    vim.keymap.set("n", "<Leader>dp", function()
      dap.set_breakpoint(nil, nil, vim.fn.input("Log point message: "))
    end)

    vim.keymap.set("n", "<Leader>dr", function()
      vim.b.debg_last_cfg = nil
      if vim.b.debg_last_cfg == nil then
        print("Successfully reset debugging configurations")
      end
    end, { desc = "Reset debugger configs" })

    vim.keymap.set("n", "<Leader>dt", function()
      dap.terminate()
      require("dapui").close()
    end, { desc = "Terminate" })

    vim.keymap.set("n", "<Leader>dD", function()
      dap.disconnect()
      require("dapui").close()
    end, { desc = "Disconnect debugger" })

    -- Define breakingpoint style
    vim.fn.sign_define(
      "DapBreakpoint",
      { text = " ", texthl = "", linehl = "", numhl = "" }
    )
    vim.fn.sign_define(
      "DapLogPoint",
      { text = " ", texthl = "", linehl = "", numhl = "" }
    )
    vim.fn.sign_define(
      "DapBreakpointCondition",
      { text = " ", texthl = "", linehl = "", numhl = "" }
    )
    vim.fn.sign_define(
      "DapStopped",
      { text = "→", texthl = "", linehl = "", numhl = "" }
    )
    vim.fn.sign_define(
      "DapBreakpointRejected",
      { text = " ", texthl = "", linehl = "", numhl = "" }
    )
    -- Debuggers are usually setup here, but may be configurated
    -- with their own plugin (like jdtls).

    -- Setup debugger adapters
    -- See: h dap-adapter
    local debug_adps = require("langs.tools").debug_adps
    for _, f in ipairs(debug_adps) do
      local ok, cfg = pcall(require, "langs.dap.adapter_configs." .. f)
      if ok then
        dap.adapters[f] = cfg
      end
    end
    -- Setup debugee configs
    -- See: h dap-configuration
    local fts = require("langs.tools").fts
    for _, ft in ipairs(fts) do
      local ok, cfg = pcall(require, "langs.dap.debugee_configs." .. ft)
      if ok then
        dap.configurations[ft] = { cfg }
      end
    end
  end,
}
