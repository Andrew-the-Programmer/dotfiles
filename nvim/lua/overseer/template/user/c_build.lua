return {
  name = "gcc build",
  builder = function()
    local file = vim.fn.expand("%:p")
    local name = vim.fn.expand("%:t:r")
    local cwd = vim.fn.getcwd()
    local bin = cwd .. "/bin/"
    local out = bin .. name .. ".out"

    vim.fn.mkdir(bin, "p")

    return {
      cmd = {
        "gcc",
        "-Wall",
        "-Wextra",
        "-Wpedantic",
        file,
        "-o",
        out,
      },
      cwd = cwd,
      components = { { "on_output_quickfix", open = true, focus=true }, "default" },
    }
  end,
  condition = {
    filetype = { "c" },
  },
}
