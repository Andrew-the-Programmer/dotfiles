return {
  "neovim/nvim-lspconfig",
  dependencies = {
    {
      "imroc/kubeschema.nvim",
      opts = {},
    },
  },
  opts = function(_, opts)
    -- set kubeschema's on_attach to yamlls's on_attach function
    opts.servers = vim.tbl_deep_extend("force", opts.servers or {}, {
      yamlls = {
        capabilities = {
          workspace = {
            didChangeConfiguration = {
              -- kubeschema.nvim relies on workspace.didChangeConfiguration to implement dynamic schema loading of yamlls.
              -- It is recommended to enable dynamicRegistration (it's also OK not to enable it, but warning logs will be
              -- generated from LspLog, but it will not affect the function of kubeschema.nvim)
              dynamicRegistration = true,
            },
          },
        },
        -- IMPORTANT!!! Set kubeschema's on_attch to yamlls so that kubeschema can dynamically and accurately match the
        -- corresponding schema file based on the yaml file content (APIVersion and Kind).
        on_attach = require("kubeschema").on_attach,
        on_new_config = function(new_config)
          new_config.settings.yaml = vim.tbl_deep_extend("force", new_config.settings.yaml or {}, {
            schemaStore = {
              enable = false,
            },
            -- Use other schemas from SchemaStore
            -- https://raw.githubusercontent.com/SchemaStore/schemastore/master/src/api/json/catalog.json
            schemas = require("schemastore").yaml.schemas({
              -- Optional ignore schemas from SchemaStore, each item is a schema name in SchemaStore's catalog.json
              ignore = {
                -- Rancher Fleet's fileMatch is 'fleet.yaml', which may conflict with the kubernetes yaml file of the same name.
                -- e.g. https://github.com/googleforgames/agones/blob/main/examples/fleet.yaml
                "Rancher Fleet",
              },
              -- Optional extra schemas to add to the schemas list
              extra = {
                {
                  name = "Example",
                  description = "Example YAML Schema",
                  fileMatch = "**/.example/job.yml",
                  url = "https://example.com/example-schema.json",
                },
              },
            }),
          })
        end,
      },
    })
  end,
}
