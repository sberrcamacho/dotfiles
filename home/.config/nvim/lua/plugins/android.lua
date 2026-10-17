-- Gradle/adb shortcuts for Android, run in a snacks terminal at the project root.
-- Uses ./gradlew when present, otherwise the global gradle.
local function project_root()
  return vim.fs.root(0, { "gradlew", "settings.gradle", "settings.gradle.kts", ".git" }) or vim.fn.getcwd()
end

local function run(cmd)
  local root = project_root()
  local gradle = vim.uv.fs_stat(root .. "/gradlew") and "./gradlew" or "gradle"
  Snacks.terminal.open(cmd:gsub("^gradle", gradle), {
    cwd = root,
    auto_close = false,
    win = { position = "bottom", height = 0.35 },
  })
end

-- Package name: read applicationId from app/build.gradle(.kts)
local function app_id()
  local root = project_root()
  for _, f in ipairs({ "app/build.gradle.kts", "app/build.gradle" }) do
    local fh = io.open(root .. "/" .. f)
    if fh then
      local txt = fh:read("*a")
      fh:close()
      local id = txt:match('applicationId%s*=?%s*["\']([^"\']+)["\']')
      if id then return id end
    end
  end
end

return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>ab", function() run("gradle assembleDebug") end, desc = "Build (assembleDebug)" },
      { "<leader>ai", function() run("gradle installDebug") end, desc = "Install (installDebug)" },
      { "<leader>ac", function() run("gradle clean") end, desc = "Clean" },
      { "<leader>at", function() run("gradle test") end, desc = "Unit Tests" },
      {
        "<leader>ar",
        function()
          local id = app_id()
          if not id then return vim.notify("applicationId not found", vim.log.levels.WARN) end
          run("gradle installDebug && adb shell monkey -p " .. id .. " -c android.intent.category.LAUNCHER 1")
        end,
        desc = "Install & Run",
      },
      { "<leader>al", function() run("adb logcat *:E") end, desc = "Logcat (Errors)" },
      { "<leader>ad", function() run("adb devices") end, desc = "List Devices" },
    },
  },
}
