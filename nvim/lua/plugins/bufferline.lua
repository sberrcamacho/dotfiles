-- Built-in plugin
return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    opts.options.separator_style = "slope"
    opts.options.show_close_icon = false
    opts.options.show_buffer_close_icons = false

    return opts
  end,
}
