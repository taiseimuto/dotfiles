return {
  {
    "lervag/vimtex",
    lazy = false,

    init = function()
      -- latexmkを使用
      vim.g.vimtex_compiler_method = "latexmk"

      -- SafariでPDFを表示
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "open"
      vim.g.vimtex_view_general_options = "-a Safari @pdf"

      -- コンパイル後に自動的にPDFビューアを起動しない
      vim.g.vimtex_view_automatic = 1

      -- VimTeXの標準キーマッピング
      vim.g.vimtex_mappings_enabled = 1
    end,
  },
}
