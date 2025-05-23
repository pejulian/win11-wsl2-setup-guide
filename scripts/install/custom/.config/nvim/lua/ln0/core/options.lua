-- clipboard for wsl2 ubuntu running on windows
vim.opt.clipboard = "unnamedplus"

-- searching and uppercase config
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Map "jj" to escape insert mode
vim.api.nvim_set_keymap("i", "jj", "<Esc>", { noremap = true, silent = true })

-- Trigger VS Code's formatDocument command before saving any buffer
vim.api.nvim_create_autocmd("BufWritePre", {
  pattern = "*",
  callback = function()
      require("vscode").call("editor.action.formatDocument")
  end,
})

vim.api.nvim_create_user_command("Format", function()
  require("vscode").call("editor.action.formatDocument")
end, { desc = "Format current buffer" })
