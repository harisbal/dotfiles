return {
  {
    "mfussenegger/nvim-dap",
    keys = {
      -- F5: start/continue
      { "<F5>",    function() require("dap").continue() end,          desc = "DAP Continue" },

      -- F9: toggle breakpoint (like VSCode)
      { "<F9>",    function() require("dap").toggle_breakpoint() end, desc = "DAP Breakpoint" },

      -- F10: step over
      { "<F10>",   function() require("dap").step_over() end,         desc = "DAP Step Over" },

      -- F11: step into
      { "<F11>",   function() require("dap").step_into() end,         desc = "DAP Step Into" },

      -- Shift-F11: step out
      { "<S-F11>", function() require("dap").step_out() end,          desc = "DAP Step Out" },
    },
  },
}
