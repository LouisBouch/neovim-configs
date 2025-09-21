return {
  "rcarriga/nvim-dap-ui",
  -- version = "^4",
  category = meta_h.categories.dap,
  lazy = false,
  dependencies = {
    "nvim-neotest/nvim-nio",
    "mfussenegger/nvim-dap",
  },
  config = function()
    local dap, dapui = require("dap"), require("dapui")
    dapui.setup()
    -- Open/close dap-ui on dap events
    dap.listeners.before.attach.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.launch.dapui_config = function()
      dapui.open()
    end
    dap.listeners.before.event_terminated.dapui_config = function()
      dapui.close()
    end
    dap.listeners.before.event_exited.dapui_config = function()
      dapui.close()
    end
  end,
  keys = {
    {
      "<leader>du",
      function()
        if require("dap").session() then
          require("dapui").open()
        end
      end,
      desc = "Open dapui session",
    },
  },
}
