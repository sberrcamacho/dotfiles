return {
  {
    "mason-org/mason.nvim",
    cmd = "Mason",
    keys = { { "<leader>cm", "<cmd>Mason<cr>", desc = "Mason" } },
    opts = {},
  },
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
      "saghen/blink.cmp",
    },
    config = function()
      vim.diagnostic.config({
        severity_sort = true,
        float = { border = "rounded" },
        virtual_text = { spacing = 2, prefix = "●" },
        signs = {
          text = {
            [vim.diagnostic.severity.ERROR] = "\u{f057}",
            [vim.diagnostic.severity.WARN] = "\u{f071}",
            [vim.diagnostic.severity.INFO] = "\u{f05a}",
            [vim.diagnostic.severity.HINT] = "\u{f0eb}",
          },
        },
      })

      -- Completion capabilities for every server
      vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

      -- kotlin-language-server crashes when initializationOptions is empty ([])
      vim.lsp.config("kotlin_language_server", {
        init_options = { storagePath = vim.fn.stdpath("cache") .. "/kotlin-ls" },
      })

      -- pyright: use the nearest virtualenv so pip-installed libraries resolve.
      -- Order: $VIRTUAL_ENV, then a .venv/venv/env folder in the file's directory or any parent.
      vim.lsp.config("pyright", {
        on_init = function(client)
          local config = client.config
          local candidates = {}
          if vim.env.VIRTUAL_ENV then table.insert(candidates, vim.env.VIRTUAL_ENV) end
          local start = vim.fs.dirname(vim.api.nvim_buf_get_name(0))
          if start == "" or start == nil then start = config.root_dir or vim.fn.getcwd() end
          local found = vim.fs.find({ ".venv", "venv", "env" }, { path = start, upward = true, type = "directory" })
          vim.list_extend(candidates, found)
          for _, venv in ipairs(candidates) do
            local py = venv .. "/bin/python"
            if vim.uv.fs_stat(py) then
              client.settings = vim.tbl_deep_extend("force", client.settings or {}, {
                python = { pythonPath = py },
              })
              client:notify("workspace/didChangeConfiguration", { settings = client.settings })
              return
            end
          end
        end,
      })

      -- Keymaps when a server attaches
      vim.api.nvim_create_autocmd("LspAttach", {
        group = vim.api.nvim_create_augroup("user_lsp_attach", { clear = true }),
        callback = function(ev)
          local function m(lhs, rhs, desc)
            -- nowait: don't wait for nvim's built-in grr/gra/grn
            vim.keymap.set("n", lhs, rhs, { buffer = ev.buf, desc = desc, nowait = true })
          end
          m("gd", function() Snacks.picker.lsp_definitions() end, "Goto Definition")
          m("gD", function() Snacks.picker.lsp_declarations() end, "Goto Declaration")
          m("gr", function() Snacks.picker.lsp_references() end, "References")
          m("gI", function() Snacks.picker.lsp_implementations() end, "Goto Implementation")
          m("gy", function() Snacks.picker.lsp_type_definitions() end, "Goto Type Definition")
          m("K", vim.lsp.buf.hover, "Hover")
          m("<leader>ss", function() Snacks.picker.lsp_symbols() end, "LSP Symbols")
          m("<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, "LSP Workspace Symbols")
          m("<leader>ca", vim.lsp.buf.code_action, "Code Action")
          m("<leader>cr", vim.lsp.buf.rename, "Rename")
          m("<leader>cR", function() Snacks.rename.rename_file() end, "Rename File")
        end,
      })

      require("mason-lspconfig").setup({
        ensure_installed = {
          "pyright", "ruff",
          "ts_ls", "html", "cssls", "emmet_language_server", "eslint",
          "jdtls", "kotlin_language_server", "lemminx",
          "lua_ls",
        },
        -- jdtls is started by nvim-jdtls (see java.lua)
        automatic_enable = { exclude = { "jdtls" } },
      })

      require("mason-tool-installer").setup({
        ensure_installed = { "prettier", "stylua", "ktlint" },
      })
    end,
  },
  {
    -- Neovim API completion/types when editing this config
    "folke/lazydev.nvim",
    ft = "lua",
    opts = { library = { { path = "snacks.nvim", words = { "Snacks" } } } },
  },
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = { "rafamadriz/friendly-snippets" }, -- snippet collection (python, java, kotlin, html, js/ts, css...)
    opts = {
      appearance = { nerd_font_variant = "mono" },
      keymap = {
        preset = "default",
        ["<Tab>"] = { "select_next", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<CR>"] = { "accept", "fallback" },
        ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
      },
      -- JetBrains-like popup: icon | label (+ detail) | kind, first item preselected,
      -- Enter accepts, docs shown in a side window, parameter hints while typing calls.
      completion = {
        list = { selection = { preselect = true, auto_insert = false } },
        accept = { auto_brackets = { enabled = true } },
        menu = {
          border = "rounded",
          scrollbar = false,
          max_height = 12,
          draw = {
            padding = { 1, 1 },
            gap = 1,
            columns = {
              { "kind_icon" },
              { "label", "label_description", gap = 1 },
              { "kind" },
            },
            treesitter = { "lsp" },
            components = {
              kind = { highlight = "Comment" },
              label_description = { highlight = "Comment" },
            },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = { border = "rounded", max_width = 80 },
        },
        ghost_text = { enabled = false },
      },
      signature = { enabled = true, window = { border = "rounded" } },
      -- retry with simplified syntax when vim.snippet rejects a snippet (see config/snippets.lua)
      snippets = { expand = function(snippet) require("config.snippets").expand(snippet) end },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          snippets = {
            opts = {
              -- react-native.json defines dozens of style snippets sharing one prefix (e.g. 15x "bor")
              filter_snippets = function(_, file) return not file:find("react%-native", 1, false) end,
            },
            -- the collection repeats some prefixes across files (react.json / react-es7.json...):
            -- keep only the first snippet per prefix and drop the "current time" variable snippet
            transform_items = function(_, items)
              local seen, out = {}, {}
              for _, item in ipairs(items) do
                local text = item.insertText or ""
                if not seen[item.label] and not text:find("${CURRENT_HOUR}", 1, true) then
                  seen[item.label] = true
                  out[#out + 1] = item
                end
              end
              return out
            end,
          },
          lazydev = { name = "LazyDev", module = "lazydev.integrations.blink", score_offset = 100 },
        },
      },
    },
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    keys = {
      { "<leader>cf", function() require("conform").format({ lsp_format = "fallback" }) end, desc = "Format" },
    },
    opts = {
      formatters_by_ft = {
        python = { "ruff_format", "ruff_organize_imports" },
        lua = { "stylua" },
        kotlin = { "ktlint" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        json = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
      },
      format_on_save = { timeout_ms = 2000, lsp_format = "fallback" },
    },
  },
}
