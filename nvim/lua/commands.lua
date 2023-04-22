local cmd = vim.cmd
local api = vim.api

--Remember last cursor position
api.nvim_create_autocmd("BufRead", {
  callback = function(opts)
    api.nvim_create_autocmd("BufWinEnter", {
      once = true,
      buffer = opts.buf,
      callback = function()
        local ft = vim.bo[opts.buf].filetype
        local last_known_line = api.nvim_buf_get_mark(opts.buf, '"')[1]
        if
            not (ft:match "commit" and ft:match "rebase")
            and last_known_line > 1
            and last_known_line <= api.nvim_buf_line_count(opts.buf)
        then
          api.nvim_feedkeys([[g`"]], "x", false)
        end
      end,
    })
  end,
})

--Remove all trailing whitespaces on save for all filetypes
--We can use .editorconfig to format
api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  callback = function(ev)
    save_cursor = vim.fn.getpos "."
    vim.cmd [[%s/\s\+$//e]]
    vim.fn.setpos(".", save_cursor)
  end,
})

--Highlight on yank
api.nvim_create_augroup("YankHighlightGrp", {})
api.nvim_create_autocmd("TextYankPost", {
  group = "YankHighlightGrp",
  pattern = "*",
  callback = function()
    vim.highlight.on_yank {
      higroup = "IncSearch",
      timeout = 200,
    }
  end,
})

--Disable autocomments
vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    vim.opt.formatoptions = vim.opt.formatoptions - { "c", "r", "o" }
  end,
})

--One statusline for split Terminal and buffer
-- cmd "autocmd TermOpen * setlocal nonumber norelativenumber | set laststatus=3"

--BUG Why signcolumn dont work properly?
-- vim.api.nvim_create_autocmd("BufEnter", {
--   pattern = "*",
--   callback = function()
--     vim.opt.signcolumn = "number"
--   end
-- })

--Toggle-checkbox
local checked_character = "x"

local checked_checkbox = "%[" .. checked_character .. "%]"
local unchecked_checkbox = "%[ %]"

local line_contains_an_unchecked_checkbox = function(line)
  return string.find(line, unchecked_checkbox)
end

local checkbox = {
  check = function(line)
    return line:gsub(unchecked_checkbox, checked_checkbox)
  end,
  uncheck = function(line)
    return line:gsub(checked_checkbox, unchecked_checkbox)
  end,
}

local M = {}

M.toggle = function()
  local bufnr = vim.api.nvim_buf_get_number(0)
  local cursor = vim.api.nvim_win_get_cursor(0)
  local start_line = cursor[1] - 1
  local current_line = vim.api.nvim_buf_get_lines(bufnr, start_line, start_line + 1, false)[1] or ""

  -- If the line contains a checked checkbox then uncheck it.
  -- Otherwise, if it contains an unchecked checkbox, check it.
  local new_line = ""
  if line_contains_an_unchecked_checkbox(current_line) then
    new_line = checkbox.check(current_line)
  else
    new_line = checkbox.uncheck(current_line)
  end

  vim.api.nvim_buf_set_lines(bufnr, start_line, start_line + 1, false, { new_line })
  vim.api.nvim_win_set_cursor(0, cursor)
end

vim.api.nvim_create_user_command("ToggleCheckbox", M.toggle, {})

return M
