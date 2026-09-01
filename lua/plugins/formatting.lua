-- Formatter priority for JS/TS projects.
--
-- Two formatters are in play:
--   * prettier -- from the `formatting.prettier` extra (capa-demo has .prettierrc)
--   * oxfmt    -- from the `lang.typescript.oxc` extra (cws-react / molecraft use oxlint)
--
-- `vim.g.lazyvim_prettier_needs_config = true` (set in config/options.lua) makes
-- prettier's conform `condition` return false when the project has no prettier
-- config. Marking the lists `stop_after_first` then makes conform fall through
-- to oxfmt in exactly those projects.
return {
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts.formatters_by_ft = opts.formatters_by_ft or {}
      for _, ft in ipairs({
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "json",
        "jsonc",
        "css",
        "scss",
        "less",
        "html",
      }) do
        local list = opts.formatters_by_ft[ft]
        if type(list) == "table" then
          list.stop_after_first = true
        end
      end
    end,
  },
}
