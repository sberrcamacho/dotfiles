-- nvim-treesitter (main branch): needs the `tree-sitter` binary (tree-sitter-cli)
local parsers = {
  "python", "java", "kotlin", "html", "css", "javascript", "typescript", "tsx",
  "json", "xml", "lua", "vim", "vimdoc", "bash", "markdown", "markdown_inline", "yaml", "groovy",
}

return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    lazy = false,
    build = ":TSUpdate",
    config = function()
      local ts = require("nvim-treesitter")
      ts.setup()
      if vim.fn.executable("tree-sitter") == 1 then
        ts.install(parsers)
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_treesitter", { clear = true }),
        callback = function(ev)
          if pcall(vim.treesitter.start, ev.buf) then
            vim.bo[ev.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          end
        end,
      })
    end,
  },
}
