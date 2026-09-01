-- LazyVim's `test.core` extra ships neotest with an empty `adapters` table --
-- it has no vitest/jest adapter of its own. oneapp and capa-demo both run
-- vitest, so wire that adapter up explicitly.
return {
  {
    "nvim-neotest/neotest",
    optional = true,
    dependencies = { "marilari88/neotest-vitest" },
    opts = { adapters = { "neotest-vitest" } },
  },
}
