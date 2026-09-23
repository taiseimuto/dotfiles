-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
--
vim.opt.clipboard = vim.env.SSH_CONNECTION and "" or "unnamedplus"

-- 挿入モードの左右移動（<C-b>/<C-f>/矢印）が行頭・行末で前後の行へ回り込むようにする。
-- `[` と `]` は挿入・置換モード専用のフラグなので、ノーマルモードの h/l には影響しない。
vim.opt.whichwrap:append("[,]")
