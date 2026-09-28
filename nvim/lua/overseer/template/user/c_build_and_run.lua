local function open_terminal_on_start()
  return {
    name = "open_terminal_on_start",
    on_start = function(self, task)
      vim.schedule(function()
        require("overseer").run_action(task, "open")
      end)
    end,
  }
end

return {
  name = "gcc build & run",
  builder = function()
    local file = vim.fn.expand("%:p")
    local name = vim.fn.expand("%:t:r")
    local cwd = vim.fn.getcwd()
    local bin = cwd .. "/bin/"
    local out = bin .. name .. ".out"

    vim.fn.mkdir(bin, "p")

    return {
      name = "run " .. name,
      cmd = { out },
      cwd = cwd,

      components = {
        {
          "dependencies",
          tasks = {
            {
              name = "gcc build " .. name,
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
              components = {
                { "on_output_quickfix", open = true },
                "default",
              },
            },
          },
          sequential = true,
        },
        open_terminal_on_start(),
        { "on_output_quickfix", set_diagnostics = true },
        "on_result_diagnostics",
        "default",
      },
    }
  end,
  condition = { filetype = { "c" } },
}
