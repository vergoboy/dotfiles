-- Neovim 0.11 compatibility shims.
-- rustaceanvim calls the pre-0.11 inlay hint API
-- (`is_enabled(bufnr)` / `enable(bufnr, bool)`), which Neovim 0.11 replaced
-- with table filters (`{ bufnr = ... }`).
-- These shims translate the old numeric form to the new table form.
-- Remove this file when upgrading to Neovim 0.12+.

local inlay = vim.lsp.inlay_hint
if type(inlay) == "table" then
  local is_enabled = inlay.is_enabled
  if type(is_enabled) == "function" then
    inlay.is_enabled = function(filter)
      if type(filter) == "number" then
        filter = { bufnr = filter }
      end
      return is_enabled(filter)
    end
  end

  local enable = inlay.enable
  if type(enable) == "function" then
    inlay.enable = function(a, b)
      -- old API: enable(bufnr, enable)
      if type(a) == "number" then
        return enable(b, { bufnr = a })
      end
      -- new API: enable(enable, filter)
      return enable(a, b)
    end
  end
end
