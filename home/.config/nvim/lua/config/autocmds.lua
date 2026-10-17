local au = vim.api.nvim_create_autocmd
local group = vim.api.nvim_create_augroup("user_config", { clear = true })

au("TextYankPost", {
  group = group,
  callback = function() vim.hl.on_yank() end,
})

-- Restore last cursor position when opening a file
au("BufReadPost", {
  group = group,
  callback = function(ev)
    local mark = vim.api.nvim_buf_get_mark(ev.buf, '"')
    if mark[1] > 0 and mark[1] <= vim.api.nvim_buf_line_count(ev.buf) then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- 2-space indent for web and lua
au("FileType", {
  group = group,
  pattern = { "html", "css", "scss", "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "yaml", "lua", "xml" },
  callback = function()
    vim.bo.shiftwidth = 2
    vim.bo.tabstop = 2
  end,
})

-- Equalize splits when the terminal is resized
au("VimResized", { group = group, command = "tabdo wincmd =" })
