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

-- Terminal: pin the terminal identity to the global cwd.
-- NOTE: snacks.nvim keys terminals on { cmd, cwd, env, count }, and LazyVim's
-- default <C-/> passes cwd = LazyVim.root(), which is recomputed per buffer.
-- Jumping to a buffer under a different root therefore spawned a fresh shell
-- instead of reusing the open one -- expensive with a slow interactive zsh.
-- getcwd(-1, -1) is the global cwd, so it holds across buffers and :lcd.
local function focus_terminal()
  Snacks.terminal.focus(nil, { cwd = vim.fn.getcwd(-1, -1) })
end

map({ "n", "t" }, "<c-/>", focus_terminal, { desc = "Terminal (Global Dir)" })
map({ "n", "t" }, "<c-_>", focus_terminal, { desc = "which_key_ignore" })
