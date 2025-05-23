-- <leader> key
vim.g.mapleader = " "
vim.g.maplocalleader = "\\"

vim.keymap.set("n", "<leader>nh", ":nohl<CR>", { noremap = true, desc = "Clear search highlights" }) -- Clear search highlights
vim.keymap.set("n", "<leader>c", ":e ~/.config/nvim/init.lua<CR>", { noremap = true, desc = "Open nvim root config" }) -- Open nvim root config
vim.keymap.set("n", "<leader>f", ":Format<CR>", { noremap = true, desc = "Format current buffer" }) -- Format current buffer

-- Go to terminal
vim.keymap.set("n", "<C-w>t", function()
    require("vscode").call("workbench.action.terminal.focus")
end, { noremap = true, desc = "Go to terminal" })

-- Go to editor
-- "t" is for terminal mode - used when you're in a terminal buffer in VS Code's integrated terminal
vim.keymap.set("t", "<C-w>t", function()
    require("vscode").call("workbench.action.forcusActiveEditorGroup")
end, { noremap = true, desc = "Focus editor from terminal" })

-- Go to file explorer
vim.keymap.set("n", "<C-w>e", function()
    require("vscode").call("workbench.view.explorer")
end, { noremap = true, desc = "Go to file explorer" })

