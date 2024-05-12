local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.signcolumn = "number"
vim.g.netrw_bufsettings = 'noma nomod nonu nobl nowrap ro'


require("lazy").setup({
	{ "nvim-treesitter/nvim-treesitter", cmd = "TSUpdate" },
	{ "ellisonleao/gruvbox.nvim", priority = 1000 , config = true},
	{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }},
	{ "nvim-tree/nvim-web-devicons" },
	--	{ "romgrk/barbar.nvim", dependencies = {"lewis6991/gitsigns.nvim", "nvim-tree/nvim-web-devicons"}, init = function() vim.g.barbar_auto_setup = true end},
	{ "williamboman/mason.nvim" },
	{ "mfussenegger/nvim-jdtls" }
	})

vim.cmd([[colorscheme gruvbox]])
