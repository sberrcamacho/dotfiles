return {
  {
    "projekt0n/github-nvim-theme",
    name = "github-theme",
    lazy = false,
    priority = 1000,
    config = function()
      require("github-theme").setup({ options = { transparent = true } })
      vim.cmd.colorscheme("github_dark_default")
      -- Visible borders between panes (explorer | editor | terminal) and around floats
      local function borders()
        local line = "#6e7681"
        vim.api.nvim_set_hl(0, "WinSeparator", { fg = line, bg = "NONE" })
        vim.api.nvim_set_hl(0, "FloatBorder", { fg = line, bg = "NONE" })
        vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = line })
        vim.api.nvim_set_hl(0, "BlinkCmpMenuBorder", { fg = line })
        vim.api.nvim_set_hl(0, "BlinkCmpDocBorder", { fg = line })
        -- blink.cmp menu keeps a solid bg by default; make it transparent like the rest
        vim.api.nvim_set_hl(0, "BlinkCmpMenu", { link = "NormalFloat" })
      end
      borders()
      vim.api.nvim_create_autocmd("ColorScheme", { callback = borders })
    end,
  },
  {
    -- Transparent statusline: two colored pills (mode, position), everything else plain text
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = function()
      -- Take the github theme, keep the colored mode pill (section a / z), flatten the rest
      local theme = "auto"
      local ok, t = pcall(require, "lualine.themes.github_dark_default")
      if ok then
        local plain = { fg = "#8b949e", bg = "NONE" }
        for _, mode in ipairs({ "normal", "insert", "visual", "replace", "command", "terminal", "inactive" }) do
          if t[mode] then
            t[mode].b, t[mode].c = plain, plain
            if mode == "inactive" then t[mode].a = plain end
          end
        end
        theme = t
      end

      local pill = { left = "\u{e0b6}", right = "\u{e0b4}" }
      local bright = { fg = "#c9d1d9" }
      local dim = { fg = "#6e7681" }

      local function lsp_names()
        local names = {}
        for _, c in ipairs(vim.lsp.get_clients({ bufnr = 0 })) do
          if c.name ~= "ruff" and c.name ~= "emmet_language_server" then names[#names + 1] = c.name end
        end
        return #names > 0 and ("\u{f085}  " .. table.concat(names, ", ")) or ""
      end

      return {
        options = {
          theme = theme,
          globalstatus = true,
          component_separators = "",
          section_separators = "",
        },
        sections = {
          lualine_a = { { "mode", icon = "\u{e62b}", separator = pill, padding = { left = 1, right = 1 } } },
          lualine_b = { { "branch", icon = "\u{e0a0}", color = dim, padding = { left = 2, right = 1 } } },
          lualine_c = {
            { "filetype", icon_only = true, separator = "", padding = { left = 1, right = 0 } },
            { "filename", path = 1, color = bright, symbols = { modified = " \u{25cf}", readonly = " \u{f023}", unnamed = "" } },
            { "diagnostics", symbols = { error = "\u{f057} ", warn = "\u{f071} ", info = "\u{f05a} ", hint = "\u{f0eb} " } },
          },
          lualine_x = {
            { "diff", symbols = { added = "\u{f067} ", modified = "\u{f040} ", removed = "\u{f068} " } },
            { lsp_names, color = dim },
          },
          lualine_y = { { "progress", color = dim } },
          lualine_z = { { "location", icon = "\u{f0c9}", separator = pill, padding = { left = 1, right = 1 } } },
        },
      }
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    dependencies = { "echasnovski/mini.icons" },
    opts = {
      preset = "helix",
      icons = { mappings = true },
      spec = {
        { "<leader>a", group = "android", icon = { icon = "󰀲", color = "green" } },
        { "<leader>b", group = "buffer", icon = { icon = "󰓩", color = "blue" } },
        { "<leader>c", group = "code", icon = { icon = "\u{f121}", color = "orange" } },
        { "<leader>f", group = "find", icon = { icon = "\u{f002}", color = "green" } },
        { "<leader>g", group = "git", icon = { icon = "󰊢", color = "orange" } },
        { "<leader>q", group = "session", icon = { icon = "󰆓", color = "purple" } },
        { "<leader>s", group = "symbols", icon = { icon = "\u{f12e}", color = "cyan" } },
        { "<leader>t", group = "terminal", icon = { icon = "\u{f120}", color = "red" } },
        { "<leader>u", group = "ui toggles", icon = { icon = "󰔡", color = "yellow" } },
        { "<leader>w", group = "windows", icon = { icon = "\u{f2d0}", color = "blue" } },
        { "<leader>x", group = "diagnostics/quickfix", icon = { icon = "󱖫", color = "green" } },
        { "<leader><tab>", group = "tabs", icon = { icon = "󰓪", color = "azure" } },
        { "gs", group = "surround", icon = { icon = "󰅪", color = "purple" } },
        { "<leader>e", icon = { icon = "󰙅", color = "yellow" } },
        { "<leader>z", icon = { icon = "󰚀", color = "purple" } },
        { "<leader>-", icon = { icon = "󰤼", color = "blue" } },
        { "<leader>|", icon = { icon = "󰤻", color = "blue" } },
        { "<leader>,", icon = { icon = "󰓩", color = "blue" } },
        { "<leader>/", icon = { icon = "\u{f002}", color = "green" } },
        { "<leader>:", icon = { icon = "\u{f017}", color = "yellow" } },
        { "<leader><space>", icon = { icon = "\u{f0b0}", color = "green" } },
      },
    },
    keys = {
      { "<leader>?", function() require("which-key").show({ global = false }) end, desc = "Buffer Keymaps" },
    },
  },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = { "MunifTanjim/nui.nvim" },
    opts = {
      lsp = {
        signature = { enabled = false }, -- blink.cmp already shows signature help; avoids two overlapping windows
        override = {
          ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
          ["vim.lsp.util.stylize_markdown"] = true,
        },
      },
      presets = {
        bottom_search = true,
        command_palette = true,
        long_message_to_split = true,
        lsp_doc_border = true,
      },
    },
  },
}
