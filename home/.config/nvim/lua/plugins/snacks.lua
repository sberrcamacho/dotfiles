-- snacks.nvim: picker, explorer, terminal, notifications, indent guides, buffer delete, zoom
-- Each terminal keeps its own session by `count`: 1 = float, 2 = bottom (VS Code style), 3 = side (AI chat)
local function term(position, count, size)
  return function()
    Snacks.terminal.toggle(nil, { count = count, win = vim.tbl_extend("force", { position = position }, size or {}) })
  end
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      explorer = { enabled = true, replace_netrw = true },
      indent = { enabled = true, animate = { enabled = false } },
      input = { enabled = true },
      notifier = { enabled = true },
      picker = { enabled = true, sources = { explorer = { hidden = true } } },
      quickfile = { enabled = true },
      scope = { enabled = true },
      statuscolumn = { enabled = true }, -- clean line numbers + signs + folds in one column
      words = { enabled = true },
      terminal = { win = { style = "terminal", wo = { winbar = "" } } }, -- no "N: title" bar on split terminals
      styles = { notification = { wo = { wrap = true } } },
    },
    keys = {
      -- Find
      { "<leader><space>", function() Snacks.picker.smart() end, desc = "Smart Find Files" },
      { "<leader>ff", function() Snacks.picker.files() end, desc = "Find Files" },
      { "<leader>fg", function() Snacks.picker.grep() end, desc = "Grep" },
      { "<leader>fw", function() Snacks.picker.grep_word() end, desc = "Grep Word", mode = { "n", "x" } },
      { "<leader>fr", function() Snacks.picker.recent() end, desc = "Recent Files" },
      { "<leader>fb", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>,", function() Snacks.picker.buffers() end, desc = "Buffers" },
      { "<leader>fh", function() Snacks.picker.help() end, desc = "Help Pages" },
      { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      { "<leader>fd", function() Snacks.picker.diagnostics() end, desc = "Diagnostics" },
      { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Config Files" },
      { "<leader>fn", function() Snacks.picker.notifications() end, desc = "Notification History" },
      { "<leader>fR", function() Snacks.picker.resume() end, desc = "Resume Last Picker" },
      { "<leader>/", function() Snacks.picker.lines() end, desc = "Search Buffer Lines" },
      { "<leader>:", function() Snacks.picker.command_history() end, desc = "Command History" },
      { "<leader>e", function() Snacks.explorer() end, desc = "File Explorer" },

      -- Git
      { "<leader>gl", function() Snacks.picker.git_log() end, desc = "Git Log" },
      { "<leader>gS", function() Snacks.picker.git_status() end, desc = "Git Status" },
      { "<leader>gd", function() Snacks.picker.git_diff() end, desc = "Git Diff (Hunks)" },
      { "<leader>go", function() Snacks.gitbrowse() end, desc = "Open in Browser", mode = { "n", "v" } },

      -- Buffers / windows
      { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
      { "<leader>bo", function() Snacks.bufdelete.other() end, desc = "Delete Other Buffers" },
      { "<leader>wm", function() Snacks.zen.zoom() end, desc = "Toggle Maximize" },
      { "<leader>z", function() Snacks.zen() end, desc = "Zen Mode" },

      -- Terminal
      { "<C-\\>", term("float", 1), mode = { "n", "t" }, desc = "Terminal (float)" },
      { "<leader>tt", term("float", 1), desc = "Terminal (float)" },
      -- <C-/> arrives as <C-_> in most terminals, so map both
      { "<C-/>", term("bottom", 2, { height = 0.3 }), mode = { "n", "t" }, desc = "Terminal (bottom)" },
      { "<C-_>", term("bottom", 2, { height = 0.3 }), mode = { "n", "t" }, desc = "which_key_ignore" },
      { "<leader>th", term("bottom", 2, { height = 0.3 }), desc = "Terminal (bottom)" },
      { "<leader>tv", term("right", 3, { width = 0.4 }), desc = "Terminal (side, 40% - AI chat)" },

      -- Misc
      { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss Notifications" },
      { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference", mode = { "n", "t" } },
      { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference", mode = { "n", "t" } },
    },
    init = function()
      vim.api.nvim_create_autocmd("User", {
        pattern = "VeryLazy",
        callback = function()
          Snacks.toggle.option("wrap", { name = "Wrap" }):map("<leader>uw")
          Snacks.toggle.option("relativenumber", { name = "Relative Number" }):map("<leader>uL")
          Snacks.toggle.diagnostics():map("<leader>ud")
          Snacks.toggle.inlay_hints():map("<leader>uh")
          Snacks.toggle.indent():map("<leader>ug")
        end,
      })
    end,
  },
}
