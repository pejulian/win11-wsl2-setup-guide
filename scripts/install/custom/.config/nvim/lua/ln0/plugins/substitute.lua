return {
    "gbprod/substitute.nvim",
    event = "VeryLazy",
    config = function()
        require("substitute").setup()
        
        vim.keymap.set("n", "s", function()
            require("substitute").operator()
        end, { noremap = true, desc = "Substitute" })   

        vim.keymap.set("n", "ss", function()
            require("substitute").line()
        end, { noremap = true, desc = "Substitute line" })

        vim.keymap.set("n", "S", function()
            require("substitute").eol()
        end, { noremap = true, desc = "Substitute eol" })

        vim.keymap.set("x", "s", function()
            require("substitute").visual()
        end, { noremap = true, desc = "Substitute visual" })
    end,
}