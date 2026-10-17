return {
  {
    "folke/flash.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
      { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
      { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
    },
  },
  {
    "folke/trouble.nvim",
    cmd = "Trouble",
    opts = {},
    keys = {
      { "<leader>xx", "<cmd>Trouble diagnostics toggle<cr>", desc = "Diagnostics (Trouble)" },
      { "<leader>xX", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Buffer Diagnostics (Trouble)" },
      { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Quickfix List (Trouble)" },
      { "<leader>cs", "<cmd>Trouble symbols toggle focus=false<cr>", desc = "Symbols (Trouble)" },
    },
  },
  {
    "folke/todo-comments.nvim",
    event = "BufReadPost",
    opts = {},
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Prev Todo" },
      { "<leader>ft", function() Snacks.picker.todo_comments() end, desc = "Todo Comments" },
      { "<leader>xt", "<cmd>Trouble todo toggle<cr>", desc = "Todo (Trouble)" },
    },
  },
  {
    "folke/persistence.nvim",
    event = "BufReadPre",
    opts = {},
    keys = {
      { "<leader>qs", function() require("persistence").load() end, desc = "Restore Session" },
      { "<leader>qS", function() require("persistence").select() end, desc = "Select Session" },
      { "<leader>ql", function() require("persistence").load({ last = true }) end, desc = "Restore Last Session" },
      { "<leader>qd", function() require("persistence").stop() end, desc = "Don't Save Current Session" },
    },
  },
  {
    "lewis6991/gitsigns.nvim",
    event = "BufReadPost",
    opts = {
      signs = {
        add = { text = "▎" }, change = { text = "▎" }, delete = { text = "\u{2581}" },
        topdelete = { text = "\u{2594}" }, changedelete = { text = "▎" }, untracked = { text = "▎" },
      },
      on_attach = function(buf)
        local gs = require("gitsigns")
        local function m(lhs, rhs, desc) vim.keymap.set("n", lhs, rhs, { buffer = buf, desc = desc }) end
        m("]h", function() gs.nav_hunk("next") end, "Next Hunk")
        m("[h", function() gs.nav_hunk("prev") end, "Prev Hunk")
        m("<leader>gp", gs.preview_hunk, "Preview Hunk")
        m("<leader>gb", gs.blame_line, "Blame Line")
        m("<leader>gr", gs.reset_hunk, "Reset Hunk")
        m("<leader>gs", gs.stage_hunk, "Stage Hunk")
      end,
    },
  },
  {
    -- Extra text objects: ciq (inside any quote), dib (inside any bracket), vif (function body),
    -- cia (argument), dit (inside tag), vac (class)...  Works with c, d, y, v.
    "echasnovski/mini.ai",
    event = "VeryLazy",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" }, -- queries for @function / @class
    },
    opts = function()
      local ai = require("mini.ai")
      return {
        n_lines = 500,
        custom_textobjects = {
          o = ai.gen_spec.treesitter({ -- block, conditional, loop
            a = { "@block.outer", "@conditional.outer", "@loop.outer" },
            i = { "@block.inner", "@conditional.inner", "@loop.inner" },
          }),
          f = ai.gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }), -- function definition
          c = ai.gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
          u = ai.gen_spec.function_call(), -- function call: print(...)
          d = { "%f[%d]%d+" }, -- number
        },
      }
    end,
  },
  { "windwp/nvim-autopairs", event = "InsertEnter", opts = {} },
  {
    -- `gs` prefix so it doesn't clash with flash on `s`
    "echasnovski/mini.surround",
    event = "VeryLazy",
    opts = {
      mappings = {
        add = "gsa", delete = "gsd", find = "gsf", find_left = "gsF",
        highlight = "gsh", replace = "gsr", update_n_lines = "gsn",
      },
    },
  },
}
