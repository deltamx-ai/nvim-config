-- The `lang.angular` extra registers `angularls = {}` with no root_dir, so
-- lspconfig falls back to single-file mode and attaches the Angular language
-- server to every TS/JS buffer -- including pure React projects (~/cws-react,
-- ~/workspace/ai/molecraft). Restrict it to real Angular workspaces.
--
-- Detection has to cover two shapes:
--   * Angular CLI workspaces -- angular.json / nx.json / project.json
--   * Vite/Analog-based Angular apps (~/workspace/ai/oneapp) -- no angular.json
--     at all, so fall back to reading @angular/core out of package.json.
--
-- Same contract as the oxc extra: only call `on_dir` when a root is found;
-- returning without calling it keeps the server detached.
local function angular_root(bufnr, on_dir)
  local root = vim.fs.root(bufnr, { "angular.json", "nx.json", "project.json" })
  if root then
    return on_dir(root)
  end

  local pkg_root = vim.fs.root(bufnr, "package.json")
  if not pkg_root then
    return
  end

  local ok, lines = pcall(vim.fn.readfile, pkg_root .. "/package.json")
  if not ok then
    return
  end

  local decoded, pkg = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not decoded or type(pkg) ~= "table" then
    return
  end

  local deps = vim.tbl_extend("keep", pkg.dependencies or {}, pkg.devDependencies or {})
  if deps["@angular/core"] then
    on_dir(pkg_root)
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        angularls = { root_dir = angular_root },
      },
    },
  },
}
