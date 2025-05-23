return {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    version = "*",
    config = function() 
        require("nvim-surround").setup({
            keymaps = {
              -- ADD surround in Insert mode: Ctrl+g then s
              -- Example: type "hello", then <C-g>s to wrap it
              insert = "<C-g>s",

              -- ADD surround to the current line in Insert mode
              insert_line = "<C-g>S",

              -- ADD surround in Normal mode
              -- Example: ysiw"  → surrounds inner word with double quotes
              normal = "ys",

              -- ADD surround to current cursor word
              -- Example: yss)  → surrounds the current line with parentheses
              normal_cur = "yss",

              -- ADD surround to whole line
              -- Example: yS] → wraps whole line in brackets
              normal_line = "yS",

              -- ADD surround to current line only (alternative to yS)
              normal_cur_line = "ySS",

              -- ADD surround in Visual mode
              -- Example: select a block of text, press S then a tag name → surrounds with HTML-like tag
              visual = "S",

              -- ADD surround to a visual *line* block
              visual_line = "gS",

              -- DELETE a surrounding pair
              -- Example: ds" → deletes surrounding quotes
              delete = "ds",

              -- CHANGE one surround to another
              -- Example: cs"' → changes " to '
              change = "cs",
            }
        })
    end,
}