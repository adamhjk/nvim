local status_ok, mason = pcall(require, "mason")
if not status_ok then
  return
end

mason.setup()

local status_ok, mason_lspconfig = pcall(require, "mason-lspconfig")
if not status_ok then
  return
end


require("mason-lspconfig").setup_handlers {
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function (server_name) -- default handler (optional)
    require("lspconfig")[server_name].setup {}
  end,
  -- Next, you can provide a dedicated handler for specific servers.
  -- For example, a handler override for the `rust_analyzer`:
  ["rust_analyzer"] = function ()
    require("rust-tools").setup {}
    require("rust-tools").inlay_hints.enable()
  end
}

local M = {}

-- TODO: backfill this to template
M.setup = function()
  local signs = {
    { name = "DiagnosticSignError", text = "" },
    { name = "DiagnosticSignWarn", text = "" },
    { name = "DiagnosticSignHint", text = "" },
    { name = "DiagnosticSignInfo", text = "" },
  }

  for _, sign in ipairs(signs) do
    vim.fn.sign_define(sign.name, { texthl = sign.name, text = sign.text, numhl = "" })
  end

  local config = {
    -- enable virtual text
    virtual_text = true,
    -- show signs
    signs = {
      active = signs,
    },
    update_in_insert = true,
    underline = true,
    severity_sort = true,
    float = {
      focusable = false,
      style = "minimal",
      border = "rounded",
      source = "always",
      header = "",
      prefix = "",
    },
  }

  vim.diagnostic.config(config)

  vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
    border = "rounded",
  })

  vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
    border = "rounded",
  })
end

local function lsp_highlight_document(client)
  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.document_highlight then
    vim.api.nvim_exec(
      [[
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]],
      false
    )
  end
end

local function lsp_keymaps(bufnr)
  local opts = { noremap = true, silent = true }
end

M.on_attach = function(client, bufnr)
  -- Turn off tsserver and volar for formatting, use null_ls instead
  if client.name == "tsserver" then
    client.server_capabilities.document_formatting = false
  end
  if client.name == "volar" then
    client.server_capabilities.document_formatting = false
  end
  --if client.name == "sqls" then
  --  require('sqls').on_attach(client, bufnr)
  --end
  lsp_keymaps(bufnr)
  lsp_highlight_document(client)
  require("lsp_signature").on_attach()
end

local capabilities = vim.lsp.protocol.make_client_capabilities()

local status_ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
if not status_ok then
  return
end

M.capabilities = cmp_nvim_lsp.default_capabilities(capabilities)

mason_lspconfig.setup()

vim.api.nvim_create_autocmd('LspAttach', {
  desc = 'LSP Actions',
  callback = function()
    local bufmap = function(mode, lhs, rhs)
      local opts = {buffer = true}
      vim.keymap.set(mode, lhs, rhs, opts)
    end
    bufmap("n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>")
    bufmap("n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>")
    bufmap("n", "K", "<cmd>lua vim.lsp.buf.hover()<CR>")
    bufmap("n", "gi", "<cmd>lua vim.lsp.buf.implementation()<CR>")
    bufmap("n", "<C-k>", "<cmd>lua vim.lsp.buf.signature_help()<CR>")
    bufmap("n", "gr", "<cmd>lua vim.lsp.buf.references()<CR>")
    bufmap("v", "a", "<cmd>lua vim.lsp.buf.range_code_action()<CR>")
    bufmap("n", "[d", '<cmd>lua vim.diagnostic.goto_prev({ border = "rounded" })<CR>')
    bufmap(
      "n",
      "gl",
      '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics({ border = "rounded" })<CR>'
    )
    bufmap("n", "]d", '<cmd>lua vim.diagnostic.goto_next({ border = "rounded" })<CR>')
    bufmap("n", "<leader>q", "<cmd>lua vim.diagnostic.setloclist()<CR>")
  end
})


return M


