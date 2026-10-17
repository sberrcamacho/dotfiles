return {
  {
    "mfussenegger/nvim-jdtls",
    ft = "java",
    config = function()
      local function start()
        local jdtls_bin = vim.fn.exepath("jdtls")
        if jdtls_bin == "" then
          vim.notify("jdtls is not installed (run :Mason)", vim.log.levels.WARN)
          return
        end
        local root = vim.fs.root(0, { "gradlew", "mvnw", "pom.xml", "build.gradle", "build.gradle.kts", ".git" })
          or vim.fn.getcwd()
        local workspace = vim.fn.stdpath("cache") .. "/jdtls/" .. vim.fn.fnamemodify(root, ":p:h:t")
        require("jdtls").start_or_attach({
          cmd = { jdtls_bin, "-data", workspace },
          root_dir = root,
          capabilities = require("blink.cmp").get_lsp_capabilities(),
        })
      end

      vim.api.nvim_create_autocmd("FileType", {
        group = vim.api.nvim_create_augroup("user_jdtls", { clear = true }),
        pattern = "java",
        callback = start,
      })
      start() -- current buffer is already java (plugin loads on ft=java)
    end,
  },
}
