if true then return {} end -- WARN: REMOVE THIS LINE TO ACTIVATE THIS FILE

-- You can also add or configure plugins by creating files in this `plugins/` folder
-- PLEASE REMOVE THE EXAMPLES YOU HAVE NO INTEREST IN BEFORE ENABLING THIS FILE
-- Here are some examples:

---@type LazySpec
return {

  "folke/noice.nvim",
  event = "VeryLazy",
  dependencies = {
    "MunifTanjim/nui.nvim",
    "rcarriga/nvim-notify",
  },
  opts = {
    routes = {
      {
        -- Record all messages including `:echo` and LSP errors
        filter = { event = "msg_show" },
        opts = { skip = false },
      },
    },
    presets = {
      bottom_search = true,
      long_message_to_split = true,
    },
  },
} -- == Examples of Adding Plugins ==
