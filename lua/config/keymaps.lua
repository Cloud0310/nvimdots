vim.keymap.set("n", "<C-s>", ":<C-u>write<CR>", { silent = true, desc = "edit: Save file" })

vim.keymap.set("n", "<C-q>", ":wq<CR>", { remap = true, desc = "edit: Save file and quit" })

vim.keymap.set("n", "<A-S-q>", ":q!<CR>", { remap = true, desc = "edit: Force quit" })

vim.keymap.set("i", "<C-u>", "<C-G>u<C-U>", { desc = "edit: Delete previous block" })

vim.keymap.set("i", "<C-b>", "<Left>", { desc = "edit: Move cursor to left" })

vim.keymap.set("i", "<C-a>", "<ESC>^i", { desc = "edit: Move cursor to line start" })

vim.keymap.set("i", "<C-s>", "<Esc>:w<CR>", { remap = true, desc = "edit: Save file" })

vim.keymap.set("i", "<C-q>", "<Esc>:wq<CR>", { remap = true, desc = "edit: Save file and quit" })

vim.keymap.set("c", "<C-b>", "<Left>", { desc = "edit: Left" })

vim.keymap.set("c", "<C-f>", "<Right>", { desc = "edit: Right" })

vim.keymap.set("c", "<C-a>", "<Home>", { desc = "edit: Home" })

vim.keymap.set("c", "<C-e>", "<End>", { desc = "edit: End" })

vim.keymap.set("c", "<C-d>", "<Del>", { desc = "edit: Delete" })

vim.keymap.set("c", "<C-h>", "<BS>", { desc = "edit: Backspace" })

vim.keymap.set("c", "<C-t>", '<C-R>=expand("%:p:h") . "/" <CR>', { desc = "edit: Complete path of current file" })

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { remap = true, desc = "edit: Move this line down" })

vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { remap = true, desc = "edit: Move this line up" })

vim.keymap.set("v", "<", "<gv", { remap = true, desc = "edit: Decrease indent" })

vim.keymap.set("v", ">", ">gv", { remap = true, desc = "edit: Increase indent" })

vim.keymap.set("n", "Y", "y$", { remap = true, desc = "edit: Yank text to EOL" })

vim.keymap.set("n", "D", "d$", { remap = true, desc = "edit: Delete text to EOL" })

vim.keymap.set("n", "n", "nzzzv", { desc = "edit: Next search result" })

vim.keymap.set("n", "N", "Nzzzv", { desc = "edit: Prev search result" })

vim.keymap.set("n", "J", "mzJ`z", { desc = "edit: Join next line" })

vim.keymap.set("n", "<S-Tab>", ":normal za<CR>", { silent = true, desc = "edit: Toggle code fold" })

vim.keymap.set("n", "<Esc>", function()
	local flash_active, state = pcall(function()
		return require("flash.plugins.char").state
	end)
	if flash_active and state then
		state:hide()
	else
		pcall(vim.cmd.noh)
	end
end, { silent = true, desc = "edit: Clear search highlight" })

vim.keymap.set(
	"n",
	"<leader>o",
	":setlocal spell! spelllang=en_us<CR>",
	{ remap = true, desc = "edit: Toggle spell check" }
)

vim.keymap.set("n", "<leader>ph", ":Lazy<CR>", { silent = true, nowait = true, desc = "package: Show" })

vim.keymap.set("n", "<leader>ps", ":Lazy sync<CR>", { silent = true, nowait = true, desc = "package: Sync" })

vim.keymap.set("n", "<leader>pu", ":Lazy update<CR>", { silent = true, nowait = true, desc = "package: Update" })

vim.keymap.set("n", "<leader>pi", ":Lazy install<CR>", { silent = true, nowait = true, desc = "package: Install" })

vim.keymap.set("n", "<leader>pl", ":Lazy log<CR>", { silent = true, nowait = true, desc = "package: Log" })

vim.keymap.set("n", "<leader>pc", ":Lazy check<CR>", { silent = true, nowait = true, desc = "package: Check" })

vim.keymap.set("n", "<leader>pd", ":Lazy debug<CR>", { silent = true, nowait = true, desc = "package: Debug" })

vim.keymap.set("n", "<leader>pp", ":Lazy profile<CR>", { silent = true, nowait = true, desc = "package: Profile" })

vim.keymap.set("n", "<leader>pr", ":Lazy restore<CR>", { silent = true, nowait = true, desc = "package: Restore" })

vim.keymap.set("n", "<leader>px", ":Lazy clean<CR>", { silent = true, nowait = true, desc = "package: Clean" })

vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { silent = true })

vim.keymap.set("n", "<leader>bn", ":<C-u>enew<CR>", { silent = true, desc = "buffer: New" })

vim.keymap.set("t", "<C-w>h", "<Cmd>wincmd h<CR>", { silent = true, desc = "window: Focus left" })

vim.keymap.set("t", "<C-w>l", "<Cmd>wincmd l<CR>", { silent = true, desc = "window: Focus right" })

vim.keymap.set("t", "<C-w>j", "<Cmd>wincmd j<CR>", { silent = true, desc = "window: Focus down" })

vim.keymap.set("t", "<C-w>k", "<Cmd>wincmd k<CR>", { silent = true, desc = "window: Focus up" })

vim.keymap.set("n", "tn", ":tabnew<CR>", { silent = true, desc = "tab: Create a new tab" })

vim.keymap.set("n", "tk", ":tabnext<CR>", { silent = true, desc = "tab: Move to next tab" })

vim.keymap.set("n", "tj", ":tabprevious<CR>", { silent = true, desc = "tab: Move to previous tab" })

vim.keymap.set("n", "to", ":tabonly<CR>", { silent = true, desc = "tab: Only keep current tab" })
