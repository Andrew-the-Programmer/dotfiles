return {
  "stevearc/conform.nvim",
  optional = true,
  opts = function(_, opts)
    local formatters_by_ft = {
      python = { "isort", "black" },
      c = { "clang-format" },
      html = { "prettier" },
    }
    opts.formatters_by_ft = opts.formatters_by_ft or {}
    for ft, u in pairs(formatters_by_ft) do
      opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or {}
      for k, v in pairs(u) do
        if type(k) == "number" and k > 0 then
          table.insert(opts.formatters_by_ft[ft], v)
        else
          opts.formatters_by_ft[ft][k] = v
        end
      end
    end
  end,
}
