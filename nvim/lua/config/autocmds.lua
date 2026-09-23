-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
--
vim.o.autoread = true
vim.api.nvim_create_autocmd({ "BufEnter", "FocusGained", "CursorHold" }, {
  pattern = "*",
  command = "checktime",
})

vim.api.nvim_create_autocmd({ "BufWritePost" }, {
  pattern = { "requiremennts.txt", "pyproject.toml" },
  callback = function()
    vim.cmd("LspRestart")
  end,
})

-- ~/.config/nvim/lua/config/autocmds.lua

vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function(args)
    -- スペルチェックをオフ
    vim.opt_local.spell = false

    -- テキストの折り返しをオフ
    vim.opt_local.wrap = false

    -- 現在のバッファのDiagnostics（診断・警告表示）をオフ
    -- ※ Neovim 0.10 以降の標準APIを使用
    vim.diagnostic.enable(false, { bufnr = args.buf })
  end,
})
