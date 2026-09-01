-- Options are automatically loaded before lazy.nvim startup
-- Default options: https://www.lazyvim.org/configuration/general

-- Basic editor preferences
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.mouse = "a"
vim.opt.clipboard = "unnamedplus"
vim.opt.expandtab = true
vim.opt.shiftwidth = 2
vim.opt.tabstop = 2
vim.opt.softtabstop = 2
vim.opt.wrap = false
vim.opt.scrolloff = 8
vim.opt.sidescrolloff = 8
vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.confirm = true

-- Search
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = true

-- Save undo history
vim.opt.undofile = true

-- Leader keys are set by LazyVim, but keep them explicit here
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

-- Only run prettier in projects that actually ship a prettier config,
-- so oxfmt can take over in the oxlint projects (see lua/plugins/formatting.lua).
vim.g.lazyvim_prettier_needs_config = true
