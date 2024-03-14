local servers = {
    dockerls = {},
    -- graphql = {},
    -- tsserver = {},
    html = {},
    -- jsonls = {
    --   schemas = require('schemastore').json.schemas(),
    -- },
    eslint = {},
    marksman = {},
    -- rust_analyzer = {
    --   ['rust-analyzer'] = {
    --     assist = {
    --       importEnforceGranularity = true,
    --       importPrefix = 'create',
    --     },
    --     cargo = {
    --       allFeatures = true,
    --       loadOutDirsFromCheck = true,
    --       runBuildScripts = true,
    --     },
    --     -- Add clippy lints for Rust.
    --     checkOnSave = {
    --       allFeatures = true,
    --       command = 'clippy',
    --       extraArgs = { '--no-deps' },
    --     },
    --     procMacro = {
    --       enable = true,
    --       ignored = {
    --         ['async-trait'] = { 'async_trait' },
    --         ['napi-derive'] = { 'napi' },
    --         ['async-recursion'] = { 'async_recursion' },
    --       },
    --     },
    --   },
    -- },
    -- clangd = {},
    pyright = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = 'workspace',
                useLibraryCodeForTypes = true,
            },
        },
    },
    sqlls = {},
    yamlls = {
        yaml = {
            completion = true,
            format = {
                enable = true,
                proseWrap = 'never',
                printWidth = 200,
            },
            keyOrdering = false,
            -- schemaStore = {
            --     enable = true,
            --     url = 'https://www.schemastore.org/api/json/catalog.json',
            -- },
            -- schemas = require('schemastore').yaml.schemas(),
            validate = true,
        },
    },
    bashls = {
        filetypes = { 'sh', 'zsh' },
    },
    gopls = {
        analyses = {
            unusedparams = true,
            --     unusedvariable = true,
            --     useany = true,
            shadow = true,
        },
        -- codelenses = {
        --     generate = true,
        --     gc_details = true,
        --     regenerate_cgo = true,
        --     tidy = true,
        --     upgrade_dependency = true,
        --     vendor = true,
        -- },
        experimentalPostfixCompletions = true,
        -- gofumpt = true,
        -- linksInHover = false,
        staticcheck = true,
        usePlaceholders = true,
        hints = {
            -- https://github.com/golang/tools/blob/master/gopls/doc/inlayHints.md
            assignVariableTypes = true,
            compositeLiteralFields = true,
            compositeLiteralTypes = true,
            constantValues = true,

            functionTypeParameters = true,
            parameterNames = true,
            rangeVariableTypes = true,
        },
    },
    lua_ls = {},
    Lua = {
        diagnostics = {
            globals = { 'vim' },
            -- neededFileStatus = true,
            -- ['codestyle-check'] = 'Any',
        },
        -- hint = {
        --     enable = true,
        -- },
        -- completion = {
        --     callSnippet = 'Replace',
        -- },
        -- format = {
        --     enable = true,
        --     defaultConfig = {
        --         indent_style = 'space',
        --         indent_size = '2',
        --     },
        -- },
        -- runtime = {
        --     version = 'LuaJIT',
        -- },
        -- workspace = {
        --     checkThirdParty = false,
        --     library = {
        --         [vim.fn.expand('$VIMRUNTIME/lua')] = true,
        --         [vim.fn.expand('$VIMRUNTIME/lua/vim/lsp')] = true,
        --     },
        --     maxPreload = 10000,
        --     preloadFileSize = 10000,
        -- },
        -- telemetry = { enable = false },
    },
}

return servers