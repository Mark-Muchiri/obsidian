return {
  on_attach = function(client, bufnr)
    -- Disable only document highlighting
    client.server_capabilities.documentHighlightProvider = false
    bufnr.server_capabilities.documentHighlightProvider = false
  end,
}
