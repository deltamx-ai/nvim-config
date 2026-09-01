-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps: https://www.lazyvim.org/keymaps

local map = vim.keymap.set

-- Keep selection when indenting visual blocks
-- NOTE: mode "x" (not "v") on purpose -- "v" also covers select mode,
-- where a printable key should replace the selection (e.g. snippet tabstops).
map("x", "<", "<gv", { desc = "Indent Left" })
map("x", ">", ">gv", { desc = "Indent Right" })

-- Removed (LazyVim upstream already provides these):
--   <Esc>            -> lazyvim/config/keymaps.lua also runs snippet_stop() and
--                       passes <esc> through (expr mapping); overriding it here
--                       degraded normal mode and desynced it from insert/select.
--   <C-h/j/k/l>      -> identical to upstream window navigation maps.
