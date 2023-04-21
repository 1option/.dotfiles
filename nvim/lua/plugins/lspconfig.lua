local lspconfig = require "lspconfig"

vim.g.coq_settings = { auto_start = "shut-up" }

local coq = require "coq"

local servers = {
  "tsserver",
  "jsonls",
  "cssls",
  "html",
  "emmet_ls",
  "lua_ls",
  "bashls",
  "clangd",
  "taplo",
}

for _, lsp in ipairs(servers) do
  if lsp == "lua_ls" then
    lspconfig.lua_ls.setup(coq.lsp_ensure_capabilities {
      settings = {
        Lua = {
          diagnostics = {
            globals = { "vim" }, -- "Global vim" warning
          },
        },
      },
    })
  elseif lsp == "clangd" then
    lspconfig.clangd.setup(coq.lsp_ensure_capabilities {
      cmd = { "clangd-14" },
    })
  else
    lspconfig[lsp].setup(coq.lsp_ensure_capabilities())
  end
end

vim.keymap.set("n", "[d", vim.diagnostic.goto_prev)
vim.keymap.set("n", "]d", vim.diagnostic.goto_next)
vim.keymap.set("n", "<Space>of", vim.diagnostic.open_float)
vim.keymap.set("n", "<Space>p", vim.diagnostic.setloclist)

vim.keymap.set("n", "<Space>e", function()
  vim.diagnostic.setloclist { open = false } -- don't open and focus
  local window = vim.api.nvim_get_current_win()
  vim.cmd.lwindow()                          -- open+focus loclist if has entries, else close -- this is the magic toggle command
  vim.api.nvim_set_current_win(window)       -- restore focus to window you were editing (delete this if you want to stay in loclist)
end, { buffer = bufnr })

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd("LspAttach", {
  group = vim.api.nvim_create_augroup("UserLspConfig", {}),
  callback = function(ev)
    -- Enable completion triggered by <C-x><c-o>
    vim.bo[ev.buf].omnifunc = "v:lua.vim.lsp.omnifunc"

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)
    vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
    -- vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
    vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
    vim.keymap.set("n", "<C-k>", vim.lsp.buf.signature_help, opts)
    vim.keymap.set("n", "gt", vim.lsp.buf.type_definition, opts)
    vim.keymap.set("n", "<Space>rn", vim.lsp.buf.rename, opts)
    vim.keymap.set("n", "<Space>ca", vim.lsp.buf.code_action, opts)
    vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
    vim.keymap.set("n", "<Space>f", function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

--Enable borders in floating windows (diagnostics)
local _border = "single"

vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
  border = _border,
})

vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
  border = _border,
})

--Disable inline error text
vim.diagnostic.config {
  virtual_text = false,
  underline = false,
  float = { border = _border },
  signs = true,
  update_in_insert = false,
}

--Auto open float diagnostics
vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
