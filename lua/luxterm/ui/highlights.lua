local M = {}

M.groups = {
  LuxtermNormal                = { link = "NormalFloat" },
  LuxtermBorder                = { link = "FloatBorder" },
  LuxtermTitle                 = { link = "FloatTitle" },

  LuxtermSessionIconSelected   = { link = "DiagnosticOk" },
  LuxtermSessionNameSelected   = { link = "Title" },
  LuxtermSessionSelected       = { link = "Special" },
  LuxtermBorderSelected        = { link = "Function" },

  LuxtermSessionIcon           = { link = "NonText" },
  LuxtermSessionName           = { link = "Normal" },
  LuxtermSessionNormal         = { link = "Comment" },
  LuxtermBorderNormal          = { link = "NonText" },

  LuxtermMenuIcon              = { link = "Function" },
  LuxtermMenuText              = { link = "Normal" },
  LuxtermMenuKey               = { link = "Keyword" },

  LuxtermPreviewTitle          = { link = "Title" },
  LuxtermPreviewContent        = { link = "Normal" },
  LuxtermPreviewEmpty          = { link = "Comment" },

  LuxtermSessionKey            = { link = "Number" },
}

function M.apply_defaults()
  for group, definition in pairs(M.groups) do
    vim.api.nvim_set_hl(0, group, vim.tbl_extend("force", definition, { default = true }))
  end
end

function M.setup_all()
  M.apply_defaults()

  vim.api.nvim_create_autocmd("ColorScheme", {
    group = vim.api.nvim_create_augroup("LuxtermHighlights", { clear = true }),
    callback = function()
      M.apply_defaults()
    end,
  })
end

return M
