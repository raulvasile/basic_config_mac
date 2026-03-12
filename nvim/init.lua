-- =============================================================================
-- Neovim Config — init.lua
-- Plugin manager: lazy.nvim
-- Theme: Catppuccin (mocha)
-- =============================================================================

-- ── Leader key (set before lazy) ─────────────────────────────────────────────
vim.g.mapleader      = " "
vim.g.maplocalleader = " "

-- ── General Options ───────────────────────────────────────────────────────────
local opt = vim.opt

opt.number         = true           -- line numbers
opt.relativenumber = true           -- relative line numbers
opt.signcolumn     = "yes"          -- always show sign column (avoids layout shift)
opt.cursorline     = true           -- highlight current line
opt.scrolloff      = 8              -- keep 8 lines above/below cursor
opt.sidescrolloff  = 8

opt.tabstop        = 2              -- 2-space tabs (frontend standard)
opt.shiftwidth     = 2
opt.expandtab      = true
opt.smartindent    = true

opt.wrap           = false          -- no line wrapping
opt.termguicolors  = true           -- 24-bit color
opt.splitbelow     = true
opt.splitright     = true

opt.ignorecase     = true           -- case-insensitive search…
opt.smartcase      = true           -- …unless uppercase used
opt.hlsearch       = false          -- no persistent search highlight
opt.incsearch      = true

opt.undofile       = true           -- persistent undo
opt.swapfile       = false
opt.backup         = false

opt.updatetime     = 250            -- faster CursorHold events
opt.timeoutlen     = 400

opt.clipboard      = "unnamedplus"  -- use system clipboard

opt.list           = true
opt.listchars      = { tab = "» ", trail = "·", nbsp = "␣" }

-- ── Bootstrap lazy.nvim ──────────────────────────────────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================================================
-- PLUGINS
-- =============================================================================
require("lazy").setup({

  -- ── Theme: Catppuccin Mocha ───────────────────────────────────────────────
  {
    "catppuccin/nvim",
    name     = "catppuccin",
    priority = 1000,
    config   = function()
      require("catppuccin").setup({
        flavour          = "mocha",
        transparent_background = false,
        integrations     = {
          treesitter  = true,
          telescope   = { enabled = true },
          cmp         = true,
          gitsigns    = true,
          neo_tree    = true,
          indent_blankline = { enabled = true },
          which_key   = true,
          lsp_trouble = true,
          native_lsp  = {
            enabled = true,
            underlines = {
              errors   = { "underline" },
              hints    = { "underline" },
              warnings = { "underline" },
            },
          },
        },
      })
      vim.cmd.colorscheme("catppuccin")
    end,
  },

  -- ── Treesitter — smart syntax highlighting ───────────────────────────────
  {
    "nvim-treesitter/nvim-treesitter",
    build  = ":TSUpdate",
    event  = { "BufReadPost", "BufNewFile" },
    opts = {
      ensure_installed = {
        "lua", "vim", "vimdoc",
        "typescript", "tsx", "javascript",
        "html", "css", "svelte",
        "json", "yaml", "toml",
        "bash", "markdown", "markdown_inline",
      },
      auto_install = true,
    },
    config = function(_, opts)
      require("nvim-treesitter").setup(opts)
    end,
  },

  -- ── Telescope — fuzzy finder ─────────────────────────────────────────────
  {
    "nvim-telescope/telescope.nvim",
    tag          = "0.1.8",
    dependencies = { "nvim-lua/plenary.nvim" },
    keys = {
      { "<leader>ff", "<cmd>Telescope find_files<cr>",  desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>",   desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>",     desc = "Buffers" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>",    desc = "Recent Files" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>",     desc = "Keymaps" },
    },
    config = function()
      require("telescope").setup({
        defaults = {
          prompt_prefix   = "  ",
          selection_caret = " ",
          layout_config   = { prompt_position = "top" },
          sorting_strategy = "ascending",
        },
      })
    end,
  },

  -- ── Mason — LSP/linter/formatter installer ───────────────────────────────
  {
    "williamboman/mason.nvim",
    build  = ":MasonUpdate",
    config = function()
      require("mason").setup({
        ui = { border = "rounded" },
      })
    end,
  },

  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = {
          "ts_ls",       -- TypeScript / JavaScript
          "eslint",      -- ESLint
          "svelte",      -- Svelte
          "html",        -- HTML
          "cssls",       -- CSS
          "lua_ls",      -- Lua (for editing this config)
          "jsonls",      -- JSON
        },
        automatic_installation = true,
      })
    end,
  },

  -- ── nvim-lspconfig — LSP setup (nvim 0.11+ API) ─────────────────────────
  {
    "neovim/nvim-lspconfig",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
      "hrsh7th/cmp-nvim-lsp",
    },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      -- Diagnostic signs (Catppuccin-friendly icons)
      local signs = { Error = " ", Warn = " ", Hint = "󰠠 ", Info = " " }
      for type, icon in pairs(signs) do
        local hl = "DiagnosticSign" .. type
        vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
      end

      vim.diagnostic.config({
        virtual_text     = { prefix = "●" },
        update_in_insert = false,
        severity_sort    = true,
        float            = { border = "rounded" },
      })

      -- Default capabilities for all servers
      vim.lsp.config("*", {
        capabilities = capabilities,
      })

      -- Server-specific settings
      vim.lsp.config("ts_ls", {
        settings = {
          typescript = { inlayHints = { includeInlayParameterNameHints = "all" } },
          javascript = { inlayHints = { includeInlayParameterNameHints = "all" } },
        },
      })

      vim.lsp.config("lua_ls", {
        settings = {
          Lua = {
            diagnostics = { globals = { "vim" } },
            workspace   = { checkThirdParty = false },
            telemetry   = { enable = false },
          },
        },
      })

      -- Enable all servers
      vim.lsp.enable({
        "ts_ls", "eslint", "svelte", "html", "cssls", "lua_ls", "jsonls",
      })
    end,
  },

  -- ── nvim-cmp — autocompletion ────────────────────────────────────────────
  {
    "hrsh7th/nvim-cmp",
    event        = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local cmp     = require("cmp")
      local luasnip = require("luasnip")
      require("luasnip.loaders.from_vscode").lazy_load()

      cmp.setup({
        snippet = {
          expand = function(args) luasnip.lsp_expand(args.body) end,
        },
        window = {
          completion    = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        mapping = cmp.mapping.preset.insert({
          ["<C-k>"]   = cmp.mapping.select_prev_item(),
          ["<C-j>"]   = cmp.mapping.select_next_item(),
          ["<C-b>"]   = cmp.mapping.scroll_docs(-4),
          ["<C-f>"]   = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<C-e>"]   = cmp.mapping.abort(),
          ["<CR>"]    = cmp.mapping.confirm({ select = true }),
          ["<Tab>"]   = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer"  },
          { name = "path"    },
        }),
      })
    end,
  },

  -- ── indent-blankline — visual indent guides ───────────────────────────────
  {
    "lukas-reineke/indent-blankline.nvim",
    main  = "ibl",
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      require("ibl").setup({
        indent = { char = "│" },
        scope  = { enabled = true, show_start = false },
      })
    end,
  },

  -- ── gitsigns — git blame + diff in gutter ────────────────────────────────
  {
    "lewis6991/gitsigns.nvim",
    event  = { "BufReadPost", "BufNewFile" },
    config = function()
      require("gitsigns").setup({
        signs = {
          add          = { text = "▎" },
          change       = { text = "▎" },
          delete       = { text = "" },
          topdelete    = { text = "" },
          changedelete = { text = "▎" },
        },
        current_line_blame            = true,   -- inline git blame
        current_line_blame_opts       = {
          virt_text = true,
          delay     = 600,
        },
        on_attach = function(bufnr)
          local gs = package.loaded.gitsigns
          local map = function(mode, l, r, desc)
            vim.keymap.set(mode, l, r, { buffer = bufnr, desc = desc })
          end

          map("n", "]g", gs.next_hunk,         "Next Hunk")
          map("n", "[g", gs.prev_hunk,         "Prev Hunk")
          map("n", "<leader>gb", gs.blame_line, "Blame Line")
          map("n", "<leader>gp", gs.preview_hunk, "Preview Hunk")
          map("n", "<leader>gs", gs.stage_hunk,   "Stage Hunk")
          map("n", "<leader>gr", gs.reset_hunk,   "Reset Hunk")
          map("n", "<leader>gd", gs.diffthis,     "Diff This")
        end,
      })
    end,
  },

  -- ── trouble.nvim — diagnostics panel ─────────────────────────────────────
  {
    "folke/trouble.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>",                        desc = "Toggle Diagnostics" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>",  desc = "Workspace Diagnostics" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>",   desc = "Document Diagnostics" },
    },
    config = function()
      require("trouble").setup({ use_diagnostic_signs = true })
    end,
  },

  -- ── which-key — keybinding popup (bonus QoL, lightweight) ────────────────
  {
    "folke/which-key.nvim",
    event  = "VeryLazy",
    opts = {
      win    = { border = "rounded" },
      spec   = {
        { "<leader>f", group = "Find (Telescope)" },
        { "<leader>g", group = "Git" },
        { "<leader>x", group = "Diagnostics" },
        { "<leader>c", group = "Code / LSP" },
        { "<leader>r", group = "Rename" },
      },
    },
  },

  -- ── Autopairs ─────────────────────────────────────────────────────────────
  {
    "windwp/nvim-autopairs",
    event  = "InsertEnter",
    config = function()
      require("nvim-autopairs").setup({ check_ts = true })
      -- Connect to cmp
      local cmp_autopairs = require("nvim-autopairs.completion.cmp")
      require("cmp").event:on("confirm_done", cmp_autopairs.on_confirm_done())
    end,
  },

  -- ── Comment.nvim — gcc / gc to comment ───────────────────────────────────
  {
    "numToStr/Comment.nvim",
    event  = { "BufReadPost", "BufNewFile" },
    config = function() require("Comment").setup() end,
  },

}, {
  -- lazy.nvim UI options
  ui = {
    border = "rounded",
    icons  = {
      package_installed   = "✔",
      package_pending     = "⟳",
      package_uninstalled = "✘",
    },
  },
  performance = {
    rtp = {
      disabled_plugins = {
        "gzip", "matchit", "matchparen",
        "netrwPlugin", "tarPlugin", "tohtml",
        "tutor", "zipPlugin",
      },
    },
  },
})

-- ── LSP keymaps (attached per buffer) ────────────────────────────────────────
vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local bufnr = args.buf
    local m = function(keys, func, desc)
      vim.keymap.set("n", keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
    end

    m("gd",          vim.lsp.buf.definition,      "Go to Definition")
    m("gD",          vim.lsp.buf.declaration,      "Go to Declaration")
    m("gr",          vim.lsp.buf.references,       "References")
    m("gi",          vim.lsp.buf.implementation,   "Implementation")
    m("K",           vim.lsp.buf.hover,            "Hover Docs")
    m("<leader>rn",  vim.lsp.buf.rename,           "Rename")
    m("<leader>ca",  vim.lsp.buf.code_action,      "Code Action")
    m("<leader>cf",  function() vim.lsp.buf.format({ async = true }) end, "Format")
    m("[d",          vim.diagnostic.goto_prev,      "Prev Diagnostic")
    m("]d",          vim.diagnostic.goto_next,      "Next Diagnostic")
    m("<leader>e",   vim.diagnostic.open_float,     "Show Diagnostic")
  end,
})

-- ── Extra keymaps ─────────────────────────────────────────────────────────────
local map = vim.keymap.set

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window Left"  })
map("n", "<C-j>", "<C-w>j", { desc = "Window Down"  })
map("n", "<C-k>", "<C-w>k", { desc = "Window Up"    })
map("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

-- Move selected lines up/down in visual mode
map("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move Down" })
map("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move Up"   })

-- Keep cursor centred when jumping
map("n", "<C-d>", "<C-d>zz")
map("n", "<C-u>", "<C-u>zz")
map("n", "n",     "nzzzv")
map("n", "N",     "Nzzzv")

-- Paste without losing register
map("x", "<leader>p", '"_dP', { desc = "Paste without yank" })

-- Clear search highlight
map("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Quick save
map("n", "<C-s>", "<cmd>w<CR>", { desc = "Save" })
map("i", "<C-s>", "<Esc><cmd>w<CR>a", { desc = "Save" })
