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
vim.opt.autochdir = true
vim.opt.clipboard='unnamed'

require("lazy").setup({
	{ "catppuccin/nvim", name = "catppuccin", priority = 1000 },
	{ "everblush/nvim", name = "everblush", priority = 1000 },
	{ "nvim-treesitter/nvim-treesitter", cmd = "TSUpdate" },
--	{ "ellisonleao/gruvbox.nvim", priority = 1000 , config = true},
--	{ "rose-pine/neovim", name = "rose-pine" },
	{ "nvim-telescope/telescope.nvim", dependencies = { "nvim-lua/plenary.nvim" }},
--	{ "nvim-tree/nvim-tree.lua", dependencies = { "nvim-tree/nvim-web-devicons" }},
--	{ "nvim-tree/nvim-web-devicons"},
	{ "prichrd/netrw.nvim", opts = {}, dependencies = { "nvim-tree/nvim-web-devicons" }},
	--	{ "romgrk/barbar.nvim", dependencies = {"lewis6991/gitsigns.nvim", "nvim-tree/nvim-web-devicons"}, init = function() vim.g.barbar_auto_setup = true end},
	{ "williamboman/mason.nvim" },
--	{ "github/copilot.vim"},
	{ "mfussenegger/nvim-jdtls" },
--	{ "f-person/git-blame.nvim" },
	{ "cameron-wags/rainbow_csv.nvim", config = true, ft = { 'csv', 'tsv', 'csv_semicolon', 'csv_whitespace', 'csv_pipe', 'rfc_csv', 'rfc_semicolon' }, cmd = { 'RainbowDelim', 'RainbowDelimSimple', 'RainbowDelimQuoted', 'RainbowMultiDelim' } }
	},
	{ "cuducos/yaml.nvim" }
	)

--	vim.cmd.colorscheme "everblush"

	require ("netrw").setup({})
--vim.cmd([[colorscheme gruvbox]])
--vim.cmd([[colorscheme rose-pine]])
