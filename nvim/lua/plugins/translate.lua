return {
  {
    "taiseimuto/translate.nvim",
    main = "translate",
    cmd = { "Translate", "TranslateInfo" },
    keys = {
      {
        "<leader>tt",
        function()
          require("translate").translate_visual()
        end,
        mode = "v",
        desc = "Translate selection",
      },
      {
        "<leader>tt",
        function()
          local line = vim.fn.line(".")
          require("translate").translate_lines(line, line)
        end,
        mode = "n",
        desc = "Translate current line",
      },
    },
    opts = {
      provider = "ollama",
      model = "translategemma:4b",
      source_lang = "Japanese",
      target_lang = "English",
      temperature = 0,
    },
  },
}
