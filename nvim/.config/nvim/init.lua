-- Ported from nixos-config (home/nvim.nix + home/nvim-init.lua). On NixOS the plugins, grammars and
-- language servers come from nixpkgs; here lazy.nvim installs the plugins, and servers/formatters are
-- installed by hand (see the README). Requires Neovim >= 0.11.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable",
    "https://github.com/folke/lazy.nvim.git", lazypath })
end
vim.opt.rtp:prepend(lazypath)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

require("lazy").setup({
  { "nvim-treesitter/nvim-treesitter", branch = "main", lazy = false, build = ":TSUpdate" },
  "neovim/nvim-lspconfig",
  "nvim-lua/plenary.nvim",
  { "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" } },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
  "lewis6991/gitsigns.nvim",
  "folke/which-key.nvim",
  "nvim-lualine/lualine.nvim",
  "stevearc/oil.nvim",
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },
  "mfussenegger/nvim-dap",
  "mfussenegger/nvim-dap-python",
  "christoomey/vim-tmux-navigator",
  "stevearc/conform.nvim",
  "echasnovski/mini.nvim",
  { "saghen/blink.cmp", version = "1.*" },
  "rafamadriz/friendly-snippets",
  "folke/flash.nvim",
  "folke/trouble.nvim",
  "folke/todo-comments.nvim",
  "lukas-reineke/indent-blankline.nvim",
  "nvim-tree/nvim-web-devicons",
  "kdheepak/lazygit.nvim",
  "folke/persistence.nvim",
  "MeanderingProgrammer/render-markdown.nvim",
}, { install = { colorscheme = { "catppuccin-mocha" } }, checker = { enabled = false } })

-- Tree-sitter parsers (Nix ships them all; here we install a useful set on first start).
pcall(function()
  require("nvim-treesitter").install({
    "lua", "vim", "vimdoc", "python", "rust", "javascript", "typescript", "tsx", "json", "yaml", "toml",
    "html", "css", "markdown", "markdown_inline", "bash", "fish", "nix", "sql", "regex", "diff", "gitcommit",
  })
end)

local o = vim.opt
o.number = true
o.relativenumber = false -- as in your old LazyVim options
o.signcolumn = "yes"
o.cursorline = true
o.termguicolors = true
o.mouse = "a"
o.clipboard = "unnamedplus" -- yank/paste via the system clipboard (OSC52 over SSH/tmux)
o.ignorecase = true
o.smartcase = true
o.undofile = true
o.updatetime = 250
o.scrolloff = 8
o.splitright = true
o.splitbelow = true
o.expandtab = true
o.shiftwidth = 2
o.tabstop = 2
o.completeopt = { "menu", "menuone", "noselect", "popup" }
o.wrap = false
o.breakindent = true
o.linebreak = true
o.confirm = true          -- ask instead of failing on :q with unsaved changes
o.inccommand = "split"    -- live preview of :s substitutions
o.timeoutlen = 400
o.list = true
o.listchars = { tab = "» ", trail = "·", nbsp = "␣" }
o.fillchars = { eob = " " }
o.winborder = "rounded"
o.pumheight = 12
o.sidescrolloff = 8
o.smartindent = true
o.swapfile = false

-- Catppuccin Mocha, transparent so the terminal's background shows through (as in the old setup).
pcall(function()
  require("catppuccin").setup({ flavour = "mocha", transparent_background = true })
end)
pcall(vim.cmd.colorscheme, "catppuccin-mocha")

-- Over SSH (e.g. Claude Code sessions in tmux) copy via OSC52 so yanks reach the local clipboard.
if vim.env.SSH_TTY then
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = require("vim.ui.clipboard.osc52").copy("+"), ["*"] = require("vim.ui.clipboard.osc52").copy("*") },
    paste = { ["+"] = function() return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") } end,
              ["*"] = function() return { vim.fn.split(vim.fn.getreg(""), "\n"), vim.fn.getregtype("") } end },
  }
end
pcall(function() require("lualine").setup({ options = { theme = "catppuccin-mocha" } }) end)
pcall(function() require("gitsigns").setup() end)
pcall(function() require("which-key").setup() end)
pcall(function() require("oil").setup() end)
pcall(function() require("telescope").load_extension("fzf") end)

-- Tree-sitter highlighting (parsers are provided by Nix).
vim.api.nvim_create_autocmd("FileType", {
  callback = function() pcall(vim.treesitter.start) end,
})

-- Language servers (neovim 0.11+ native API). Servers themselves come from extraPackages.
vim.lsp.enable({
  "lua_ls", "nil_ls", "pyright", "ruff", "rust_analyzer", "ts_ls",
  "jsonls", "html", "cssls", "marksman", "taplo", "yamlls", "bashls",
})
vim.lsp.config("lua_ls", { settings = { Lua = { diagnostics = { globals = { "vim" } } } } })

vim.diagnostic.config({ virtual_text = true, severity_sort = true })

-- LSP keymaps when a server attaches (completion is handled by blink.cmp below).
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(ev)
    local client = vim.lsp.get_client_by_id(ev.data.client_id)
    local map = function(keys, fn, desc)
      vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
    end
    map("gd", vim.lsp.buf.definition, "Go to definition")
    map("gr", vim.lsp.buf.references, "References")
    map("K", vim.lsp.buf.hover, "Hover docs")
    map("<leader>rn", vim.lsp.buf.rename, "Rename")
    map("<leader>ca", vim.lsp.buf.code_action, "Code action")
    map("gi", vim.lsp.buf.implementation, "Go to implementation")
    map("gy", vim.lsp.buf.type_definition, "Go to type definition")
    map("<leader>ss", function() require("telescope.builtin").lsp_document_symbols() end, "Document symbols")
    map("<leader>sS", function() require("telescope.builtin").lsp_dynamic_workspace_symbols() end, "Workspace symbols")
    if client and client:supports_method("textDocument/inlayHint") then
      map("<leader>th", function()
        vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled({ bufnr = ev.buf }), { bufnr = ev.buf })
      end, "Toggle inlay hints")
    end
  end,
})

-- Telescope + file browser keymaps.
local ok, tb = pcall(require, "telescope.builtin")
if ok then
  vim.keymap.set("n", "<leader><space>", tb.find_files, { desc = "Find files" })
  vim.keymap.set("n", "<leader>/", tb.live_grep, { desc = "Grep" })
  vim.keymap.set("n", "<leader>b", tb.buffers, { desc = "Buffers" })
  vim.keymap.set("n", "<leader>d", tb.diagnostics, { desc = "Diagnostics" })
end
vim.keymap.set("n", "-", "<cmd>Oil<cr>", { desc = "File browser" })
vim.keymap.set("n", "<leader>e", "<cmd>Oil<cr>", { desc = "File browser" })
vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<cr>")
if ok then
  vim.keymap.set("n", "<leader>fr", tb.oldfiles, { desc = "Recent files" })
  vim.keymap.set("n", "<leader>fg", tb.git_files, { desc = "Git files" })
  vim.keymap.set("n", "<leader>fh", tb.help_tags, { desc = "Help" })
  vim.keymap.set("n", "<leader>fk", tb.keymaps, { desc = "Keymaps" })
  vim.keymap.set("n", "<leader>fw", tb.grep_string, { desc = "Grep word under cursor" })
  vim.keymap.set("n", "<leader>fR", tb.resume, { desc = "Resume last picker" })
  vim.keymap.set("n", "<leader>gc", tb.git_commits, { desc = "Git commits" })
  vim.keymap.set("n", "<leader>gs", tb.git_status, { desc = "Git status" })
end

-- Everyday editing keys.
local map = vim.keymap.set
map({ "n", "i", "x", "s" }, "<C-s>", "<cmd>w<cr><esc>", { desc = "Save" })
map("n", "<S-h>", "<cmd>bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>bnext<cr>", { desc = "Next buffer" })
map("n", "<leader>x", "<cmd>bdelete<cr>", { desc = "Close buffer" })
map("n", "<leader>q", "<cmd>quit<cr>", { desc = "Quit window" })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("v", "<", "<gv", { desc = "Indent left (keep selection)" })
map("v", ">", ">gv", { desc = "Indent right (keep selection)" })
map("x", "J", ":m '>+1<cr>gv=gv", { desc = "Move selection down", silent = true })
map("x", "K", ":m '<-2<cr>gv=gv", { desc = "Move selection up", silent = true })
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n", "nzzzv")
map("n", "N", "Nzzzv")
map("x", "<leader>p", [["_dP]], { desc = "Paste without clobbering register" })
map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line diagnostics" })
map("n", "<leader>cq", vim.diagnostic.setloclist, { desc = "Diagnostics to loclist" })

-- Formatting: <leader>cf formats the buffer/selection with the Nix-provided formatter, falling back to the LSP.
pcall(function()
  require("conform").setup({
    formatters_by_ft = {
      lua = { "stylua" },
      nix = { "nixpkgs_fmt" },
      python = { "ruff_fix", "ruff_format" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      toml = { "taplo" },
      javascript = { "prettier" }, typescript = { "prettier" },
      javascriptreact = { "prettier" }, typescriptreact = { "prettier" },
      json = { "prettier" }, jsonc = { "prettier" }, yaml = { "prettier" },
      markdown = { "prettier" }, css = { "prettier" }, html = { "prettier" },
    },
    default_format_opts = { lsp_format = "fallback" },
  })
  map({ "n", "x" }, "<leader>cf", function() require("conform").format({ async = true }) end, { desc = "Format" })
end)

-- mini.nvim: autopairs, surround (gsa/gsd/gsr), extended a/i textobjects, quick comment-free niceties.
pcall(function()
  require("mini.pairs").setup()
  require("mini.surround").setup()
  require("mini.ai").setup()
end)

-- Completion (blink.cmp): Enter accepts, Tab/S-Tab move through the menu and snippet fields, Ctrl-Space opens it.
pcall(function()
  require("blink.cmp").setup({
    keymap = {
      preset = "enter",
      ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
      ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
    },
    completion = { documentation = { auto_show = true, auto_show_delay_ms = 300 } },
    sources = { default = { "lsp", "path", "snippets", "buffer" } },
    signature = { enabled = true },
  })
  vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })
end)

-- flash: `s` + 2 chars jumps anywhere visible; `S` selects treesitter nodes.
pcall(function()
  require("flash").setup()
  vim.keymap.set({ "n", "x", "o" }, "s", function() require("flash").jump() end, { desc = "Flash jump" })
  vim.keymap.set({ "n", "x", "o" }, "S", function() require("flash").treesitter() end, { desc = "Flash treesitter" })
end)

-- trouble: diagnostics / todo panels.
pcall(function()
  require("trouble").setup()
  vim.keymap.set("n", "<leader>tt", "<cmd>Trouble diagnostics toggle<cr>", { desc = "Diagnostics (workspace)" })
  vim.keymap.set("n", "<leader>tT", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", { desc = "Diagnostics (buffer)" })
  vim.keymap.set("n", "<leader>tr", "<cmd>Trouble lsp_references toggle<cr>", { desc = "References" })
  vim.keymap.set("n", "<leader>tq", "<cmd>Trouble qflist toggle<cr>", { desc = "Quickfix list" })
end)

-- todo-comments: ]t / [t jump between TODOs, <leader>tl lists them, <leader>ft searches them.
pcall(function()
  require("todo-comments").setup()
  vim.keymap.set("n", "]t", function() require("todo-comments").jump_next() end, { desc = "Next TODO" })
  vim.keymap.set("n", "[t", function() require("todo-comments").jump_prev() end, { desc = "Previous TODO" })
  vim.keymap.set("n", "<leader>tl", "<cmd>Trouble todo toggle<cr>", { desc = "TODO list" })
  vim.keymap.set("n", "<leader>ft", "<cmd>TodoTelescope<cr>", { desc = "Find TODOs" })
end)

-- indent guides.
pcall(function() require("ibl").setup({ scope = { enabled = false } }) end)
pcall(function() require("nvim-web-devicons").setup() end)

-- lazygit: full git UI in a floating window.
vim.keymap.set("n", "<leader>gg", "<cmd>LazyGit<cr>", { desc = "Lazygit" })

-- Sessions: saved automatically per directory on exit; <leader>Ss restores this directory's, <leader>Sl the last one.
o.sessionoptions = { "buffers", "curdir", "tabpages", "winsize", "help", "globals", "skiprtp", "folds" }
pcall(function()
  require("persistence").setup()
  vim.keymap.set("n", "<leader>Ss", function() require("persistence").load() end, { desc = "Restore session (this dir)" })
  vim.keymap.set("n", "<leader>Sl", function() require("persistence").load({ last = true }) end, { desc = "Restore last session" })
  vim.keymap.set("n", "<leader>Sd", function() require("persistence").stop() end, { desc = "Don't save this session" })
end)

-- Markdown rendering (headings, tables, code blocks, checkboxes).
pcall(function() require("render-markdown").setup() end)

-- which-key group labels.
pcall(function()
  require("which-key").add({
    { "<leader>f", group = "find" },
    { "<leader>g", group = "git" },
    { "<leader>s", group = "symbols" },
    { "<leader>c", group = "code" },
    { "<leader>t", group = "toggle / trouble" },
    { "<leader>S", group = "sessions" },
  })
end)

-- Small quality-of-life autocmds.
local aug = vim.api.nvim_create_augroup("user_qol", { clear = true })
vim.api.nvim_create_autocmd("TextYankPost", {
  group = aug, callback = function() vim.hl.on_yank({ timeout = 150 }) end,
})
vim.api.nvim_create_autocmd("BufReadPost", { -- reopen at the last cursor position
  group = aug,
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then pcall(vim.api.nvim_win_set_cursor, 0, mark) end
  end,
})
vim.api.nvim_create_autocmd({ "FocusGained", "BufEnter" }, { group = aug, command = "checktime" }) -- pick up external edits
vim.api.nvim_create_autocmd("VimResized", { group = aug, command = "wincmd =" })
vim.api.nvim_create_autocmd("FileType", {
  group = aug, pattern = { "python", "rust" }, callback = function() vim.bo.shiftwidth = 4; vim.bo.tabstop = 4 end,
})

-- Debugging, same keys as your old setup (VSCode-style).
local okd, dap = pcall(require, "dap")
if okd then
  vim.keymap.set("n", "<F5>", dap.continue, { desc = "DAP Continue" })
  vim.keymap.set("n", "<F9>", dap.toggle_breakpoint, { desc = "DAP Breakpoint" })
  vim.keymap.set("n", "<F10>", dap.step_over, { desc = "DAP Step Over" })
  vim.keymap.set("n", "<F11>", dap.step_into, { desc = "DAP Step Into" })
  vim.keymap.set("n", "<S-F11>", dap.step_out, { desc = "DAP Step Out" })
end

-- Python debugging: nvim-dap-python can run debugpy through uv (per-project venvs still work for the code itself).
pcall(function() require("dap-python").setup("uv") end)
