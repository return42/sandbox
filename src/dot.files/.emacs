;;; .emacs --- my local emacs setup -*- lexical-binding: t -*-

;; SPDX-License-Identifier: AGPL-3.0-or-later
;; Author: Markus Heiser <markus.heiser@darmarit.de>
;; Keywords: dot.emacs setup

;;; Commentary:
;;
;; mise-en-place: https://mise.jdx.dev/installing-mise.html
;;
;;   $ mise settings set python.compile false
;;   $ mise use -g usage go node python shellcheck shfmt
;;
;;   Configure npm to install global executables to ~/.local/bin and the
;;   libraries to ~/.local/lib/node_modules/
;;
;;   $ npm config set prefix ~/.local
;;
;;   $ mise use -g jq # https://jqlang.org/
;;   $ mise use -g rust  # rustup command --> https://www.rust-lang.org/tools/install
;;   $ mise use -g github:kristoff-it/superhtml  # https://github.com/kristoff-it/superhtml
;;   ...
;;   $ mise self-update
;;   $ mise upgrade --bump  # Upgrades to latest version, bumping the version in mise.toml
;;   ...
;;   $ pipx upgrade-all
;;   ...
;;   $ npm update -g
;;   ...
;;   $ rustup update
;;
;; Python development:
;;
;;   $ pipx install \
;;       uv hatch black \
;;       basedpyright ruff  'python-lsp-server[all]' pylsp-mypy jedi-language-server zuban
;;
;; JavaScript development:
;;
;;   Typescript LSP alternative: vtsls --> https://github.com/yioneko/vtsls
;;
;;   $ npm install -g typescript-language-server typescript
;;   $ npm install -g @vtsls/language-server
;;   $ npm install -g eslint eslint-plugin-json
;;
;; Rust Development
;;
;;   $ rustup component add rust-analyzer
;;
;; Bash scripting:
;;
;;   $ mise use -g shellcheck shfmt
;;   $ npm install -g bash-language-server
;;
;; Language Servers:
;;
;;   $ npm install -g yaml-language-server
;;   $ npm install -g vscode-langservers-extracted  # html css json eslint
;;
;; Developer notes:
;;
;; - Emacs-Lisp Interpreter: M-x ielm
;; - Format code: M-x editorconfig-format-buffer

;;; Code:

;; ----------------------------------------------------------------------
;; https://github.com/radian-software/straight.el
;; ----------------------------------------------------------------------

(setq package-enable-at-startup nil)
(setq straight-use-package-by-default t)

(defvar bootstrap-version)
(let ((bootstrap-file
        (expand-file-name
          "straight/repos/straight.el/bootstrap.el"
          (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
       (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
      (url-retrieve-synchronously
        "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
        'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)


;; ----------------------------------------------------------------------
;; --- init my/..
;; ----------------------------------------------------------------------

(defun my/setup-init ()
  "Initialize my/setup."

  (bash-completion-setup)
  (my/custom-defaults)
  (my/key-bindings)
  (bookmark-bmenu-list)
  (switch-to-buffer "*Bookmark List*")
  (load-theme 'modus-vivendi)
  )

(defun my/display-ansi-colors ()
  "Render colors in a buffer that contain ASCII color escape codes."
  (interactive)
  (require 'ansi-color)
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region (point-min) (point-max))))


;; ----------------------------------------------------------------------
;; --- custom settings
;; ----------------------------------------------------------------------

(defun my/custom-defaults ()
  "My default customizing."
  (setq ring-bell-function 'ignore)
  (setq custom-file "~/.emacs-custom")
  (custom-set-variables
    '(column-number-mode t)
    '(company-mode t)
    '(compilation-scroll-output 'first-error)
    '(confirm-kill-emacs 'yes-or-no-p)
    '(delete-selection-mode t)
    '(desktop-save-mode nil)
    '(fill-column 80)
    '(font-use-system-font t)
    '(global-so-long-mode t)
    '(history-delete-duplicates t)
    '(inhibit-splash-screen t)
    '(ispell-dictionary "en_US")
    '(js-indent-level 2)
    '(mouse-wheel-tilt-scroll t)
    '(quote (dired-recursive-deletes 'top))
    '(save-place-local-mode 1)
    '(savehist-mode t nil (savehist))
    '(show-trailing-whitespace t)
    '(tab-always-indent 'complete)
    '(use-short-answers t)
    ;; '(enable-dir-local-variables nil)
    )
  (load "~/.emacs-custom" t t)
  )

;; ----------------------------------------------------------------------
;; --- key bindings
;; ----------------------------------------------------------------------

(defun my/key-bindings ()
  "My key bindings."
  (keymap-global-set "C-<return>"      'fill-paragraph)
  (keymap-global-set "C-c c"           'compile)
  (keymap-global-set "C-c l"           'goto-line)
  (keymap-global-set "C-x C-f"         'find-file-at-point)
  (keymap-global-set "<f7>"            'spell-checker)
  (keymap-global-set "<f8>"            'dictcc-at-point)
  (keymap-global-set "C-c t"           'gt-translate)
  )

;; ----------------------------------------------------------------------
;; --- packages
;; ----------------------------------------------------------------------

;; Emacs minibuffer configurations.
(use-package emacs
  :custom
  ;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
  ;; to switch display modes.
  (context-menu-mode t)
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
    '(read-only t cursor-intangible t face minibuffer-prompt)))

;; https://github.com/rejeep/f.el
;;(use-package f)

(use-package dired
  :straight nil
  :ensure nil
  :init
  (put 'dired-find-alternate-file 'disabled nil)
  :bind
  ( :map dired-mode-map
    ("o" . ofap-dired)))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; https://github.com/juergenhoetzel/emacs-totp
(use-package totp)

(use-package tab-bookmark
  :straight (:host github :repo "minad/tab-bookmark")
  )

;; https://paredit.org/
(use-package paredit)

(use-package spdx
  :ensure t
  :straight (:host github :repo "condy0919/spdx.el")
  :bind (:map prog-mode-map
         ("C-c i l" . spdx-insert-spdx))
  :custom
  (spdx-copyright-holder 'auto)
  (spdx-project-detection 'auto))

;; https://github.com/company-mode/company-mode
(use-package company
  :custom
  (company-idle-delay 0) ;; how long to wait until popup
  (company-minimum-prefix-length 1)
  ;; (company-begin-commands nil) ;; uncomment to disable popup
  :hook
  (after-init . global-company-mode)
  :bind
  ( :map company-active-map
    ("C-n". company-select-next)
    ("C-p". company-select-previous)
    ("M-<". company-select-first)
    ("M->". company-select-last)))

;; https://github.com/bbatsov/projectile
(use-package projectile
  ;; :init
  ;; (setq projectile-project-search-path '("~/projects/" "~/work/" "~/playground"))
  :config
  (projectile-mode +1)
  :bind
  ( :map global-map
    ("C-c p" . projectile-command-map)
    :map projectile-mode-map
    ("C-c p" . projectile-command-map))
)

;; https://github.com/minad/marginalia
;;
;; Enable rich annotations using the Marginalia package
(use-package marginalia
  ;; Bind `marginalia-cycle' locally in the minibuffer.  To make the binding
  ;; available in the *Completions* buffer, add it to the
  ;; `completion-list-mode-map'.
  :bind (:map minibuffer-local-map
          ("M-A" . marginalia-cycle))

  ;; The :init section is always executed.
  :init

  ;; Marginalia must be activated in the :init section of use-package such that
  ;; the mode gets enabled right away. Note that this forces loading the
  ;; package.
  (marginalia-mode))

;; Example configuration for Consult
(use-package consult
  ;; Replace bindings. Lazily loaded by `use-package'.
  :bind
  (;; C-c bindings in `mode-specific-map'
    ("C-c M-x" . consult-mode-command)
    ("C-c h" . consult-history)
    ("C-c k" . consult-kmacro)
    ("C-c m" . consult-man)
    ("C-c i" . consult-info)
    ([remap Info-search] . consult-info)
    ;; C-x bindings in `ctl-x-map'
    ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
    ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
    ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
    ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
    ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
    ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
    ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
    ;; Custom M-# bindings for fast register access
    ("M-#" . consult-register-load)
    ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
    ("C-M-#" . consult-register)
    ;; Other custom bindings
    ("M-y" . consult-yank-pop)                ;; orig. yank-pop
    ;; M-g bindings in `goto-map'
    ("M-g e" . consult-compile-error)
    ("M-g f" . consult-flycheck)              ;; Alternative: consult-flymake
    ("M-g g" . consult-goto-line)             ;; orig. goto-line
    ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
    ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
    ("M-g m" . consult-mark)
    ("M-g k" . consult-global-mark)
    ("M-g i" . consult-imenu)
    ("M-g I" . consult-imenu-multi)
    ;; M-s bindings in `search-map'
    ("M-s d" . consult-find)                  ;; Alternative: consult-fd
    ("M-s c" . consult-locate)
    ("M-s g" . consult-grep)
    ("M-s G" . consult-git-grep)
    ("M-s r" . consult-ripgrep)
    ("M-s l" . consult-line)
    ("M-s L" . consult-line-multi)
    ("M-s k" . consult-keep-lines)
    ("M-s u" . consult-focus-lines)
    ;; Isearch integration
    ("M-s e" . consult-isearch-history)
    :map isearch-mode-map
    ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
    ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
    ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
    ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
    ;; Minibuffer history
    :map minibuffer-local-map
    ("M-s" . consult-history)                 ;; orig. next-matching-history-element
    ("M-r" . consult-history))                ;; orig. previous-matching-history-element

  ;; Enable automatic preview at point in the *Completions* buffer. This is
  ;; relevant when you use the default completion UI.
  :hook (completion-list-mode . consult-preview-at-point-mode)

  ;; The :init configuration is always executed (Not lazy)
  :init

  ;; Tweak the register preview for `consult-register-load',
  ;; `consult-register-store' and the built-in commands.  This improves the
  ;; register formatting, adds thin separator lines, register sorting and hides
  ;; the window mode line.
  (advice-add #'register-preview :override #'consult-register-window)
  (setq register-preview-delay 0.5)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
    xref-show-definitions-function #'consult-xref)

  ;; Configure other variables and modes in the :config section,
  ;; after lazily loading the package.
  :config

  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
    consult-theme :preview-key '(:debounce 0.2 any)
    consult-ripgrep consult-git-grep consult-grep consult-man
    consult-bookmark consult-recent-file consult-xref
    consult--source-bookmark consult--source-file-register
    consult--source-recent-file consult--source-project-recent-file
    ;; :preview-key "M-."
    :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (keymap-set consult-narrow-map (concat consult-narrow-key " ?") #'consult-narrow-help)
  )

;; https://github.com/minad/corfu
;; Corfu is the minimalistic in-buffer completion counterpart of the
;; Vertico minibuffer UI.
;;
;;(use-package corfu)

;; Enable Vertico.
(use-package vertico
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  ;; (vertico-count 20) ;; Show more candidates
  (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

(use-package orderless
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; https://editorconfig.org/
(use-package editorconfig
  :config
  (editorconfig-mode 1))

(use-package eglot
  :bind
  (("s-e a" . eglot-code-actions)
    ("s-e h" . eglot-inlay-hints-mode)
    ("s-e i" . eglot-find-implementation)
    ("s-e m" . eglot-rename)
    ("s-e t" . eglot-find-typeDefinition))
  :hook
  (((c++-mode python-mode python-ts-mode java-mode typescript-ts-mode js-ts-mode) . eglot-ensure)
    (eglot-managed-mode . my/eglot-mode-hook-fn))
  :config
  (defun my/eglot-mode-hook-fn ()
    (eglot-inlay-hints-mode 0))
  (add-to-list 'eglot-server-programs
    `((js-mode js-ts-mode typescript-mode typescript-ts-mode) .
       ,(eglot-alternatives
          ;; from the list of alternatives, I prefer vtsls
          '(("vtsls" "--stdio") ("deno" "lsp") ("typescript-language-server" "--stdio")))))
  (add-to-list 'eglot-server-programs
    `((python-mode python-ts-mode) .
       ,(eglot-alternatives
          '(("hatch" "run" "basedpyright-langserver" "--stdio")
             ("basedpyright-langserver" "--stdio")
             "pylsp" "pyls"
             ("pyright-langserver" "--stdio")
             "jedi-language-server"
             ("ruff" "server")
             "ruff-lsp" "zubanls"
             ))))

  (add-to-list 'eglot-server-programs
    `((html-mode html-ts-mode) .
       ,(eglot-alternatives
          ;; from the list of alternatives, I prefer superhtml
          '(("vscode-html-language-server" "--stdio")
             ("superhtml" "lsp")
             ("html-languageserver" "--stdio")
             ))))
  )

;; https://github.com/eki3z/mise.el
(use-package mise
  ;; :hook

  ;; der mise-mode macht aktuell noch probleme, wenn in dem projektordner eine
  ;; ".nvmrc" datei liegt, will man dann den ordner im emacs öffnen, dann kommt
  ;; aus dem mise mode ein "JSON error" (warum auch immer, die .nvmrc ist
  ;; nämlich keine JSON Datei) der zum Abbruch des Dired (ordner anzeigen) führt.

  ;; (after-init . global-mise-mode)
  )

;; https://github.com/magit/magit
(use-package magit
  :commands magit-status magit--handle-bookmark
  :bind
  ( :map global-map
    ("C-c v" . magit-status)
    ("C-x g" . magit-status)
    ("C-x C-g" . magit-status)
    :map magit-mode-map
    ("o" . 'ofap)))

(use-package dap-mode
  :config
  (dap-auto-configure-mode)
  :bind
  ( :map global-map
    ("<f7>" . dap-step-in)
    ("<f8>" . dap-next)
    ("<f9>" . dap-continue)))

;; https://github.com/purcell/elisp-slime-nav
(use-package elisp-slime-nav)

;; https://emacs-lsp.github.io/dap-mode/
(use-package dap-mode
  :config
  (dap-auto-configure-mode)
  :bind
  ( :map global-map
    ("<f7>" . dap-step-in)
    ("<f8>" . dap-next)
    ("<f9>" . dap-continue)))

;; https://emacs-lsp.github.io/lsp-mode/
;; (use-package lsp-mode
;;   :commands lsp
;;   :hook
;;   ((c++-mode python-mode java-mode js-mode js2-mode) . lsp-deferred))
;;   :custom
;;   (add-hook 'lsp-mode-hook 'lsp-ui-mode) ;; Optional, see below
;;   (add-hook 'go-mode-hook #'lsp-deferred))

;; https://github.com/emacs-lsp/lsp-ui
;; (use-package lsp-ui
;;   :commands lsp-ui-mode
;;   :config
;;   (setq lsp-ui-doc-enable nil)
;;   (setq lsp-ui-doc-header t)
;;   (setq lsp-ui-doc-include-signature t)
;;   (setq lsp-ui-doc-border (face-foreground 'default))
;;   (setq lsp-ui-sideline-show-code-actions t)
;;   (setq lsp-ui-sideline-delay 0.05)
;;   :custom
;;   (lsp-ui-peek-always-show t)
;;   (lsp-ui-sideline-show-hover t)
;;   (lsp-ui-doc-enable nil))

;; https://github.com/realgud/realgud
(use-package realgud)

;; https://github.com/szermatt/emacs-bash-completion
(use-package bash-completion)


;; https://github.com/emacs-php/apache-mode
(use-package apache-mode)

;; https://github.com/ajc/nginx-mode
(use-package nginx-mode)

;; ----------
;; treesit.el
;; ----------

;; modes I replaced by treesit-langs
;;
;;    yaml-mode               ;; https://github.com/yoshiki/yaml-mode
;;    json-mode               ;; https://github.com/json-emacs/json-mode
;;    lua-mode                ;; https://github.com/immerrr/lua-mode
;;    powershell              ;; https://github.com/jschaf/powershell.el
;;    go-mode                 ;; https://melpa.org/#/go-mode
;;    php-mode                ;; https://github.com/emacs-php/php-mode
;;    graphql-mode            ;; https://github.com/davazp/graphql-mode
;;    jinja2-mode             ;; https://github.com/paradoxxxzero/jinja2-mode
;;    markdown-mode           ;; https://jblevins.org/projects/markdown-mode/
;;    graphviz-dot-mode       ;; https://ppareit.github.io/graphviz-dot-mode/
;;    gitconfig               ;; https://github.com/tonini/gitconfig.el

;; https://github.com/renzmann/treesit-auto
(use-package treesit-auto
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

;; https://github.com/emacs-tree-sitter/treesit-langs
(use-package treesit-langs
  :straight (:host github :repo "emacs-tree-sitter/treesit-langs" :files (:defaults "*"))
  )
;; https://github.com/kiennq/treesit-langs
;; (use-package treesit-langs
;;   :straight (:host github :repo "kiennq/treesit-langs" :files (:defaults "*"))
;;   )

;; https://github.com/emacs-tree-sitter/tree-sitter-langs/issues/1120
;;(use-package tree-sitter-langs)

;; ------------
;; Python Stuff
;; ------------

(use-package python
  :config
  (require 'eglot)
  (setq python-check-command "uv run ruff format && uv run ruff check --fix")
  )

;; https://github.com/wyuenho/emacs-pet
(use-package pet
  :config
  (add-hook 'python-base-mode-hook 'pet-mode -10))

;; https://github.com/statmobile/pydoc
(use-package pydoc)

;; https://github.com/emacsorphanage/pylint
(use-package pylint)

;; https://github.com/jorgenschaefer/pyvenv
;; (use-package pyvenv)

;; https://github.com/nryotaro/pyvenv-auto
(use-package pyvenv-auto)

;; https://github.com/Wilfred/pip-requirements.el
(use-package pip-requirements)

;; https://github.com/emacs-lsp/lsp-pyright
(use-package lsp-pyright)

;; https://github.com/fxbois/web-mode
(use-package web-mode
  :custom
  (web-mode-markup-indent-offset 2)
  (web-mode-css-indent-offset 2)
  (web-mode-code-indent-offset 2)
  :config
  (add-to-list 'auto-mode-alist '("\\.html?\\'" . web-mode))
  (setq web-mode-engines-alist
    '(("php"    . "\\.phtml\\'")
       ("jinja"  . "\\.html\\'")
       ("jinja"  . "\\.jinja.html\\'")
       ))
  )

;; ------------------
;; FlyMake / FlyCheck
;; ------------------

;; I prefer flycheck over flymake-mode
;; (add-hook 'prog-mode-hook #'flymake-mode)
;;
;; https://www.flycheck.org
(use-package flycheck
  :init
  (global-flycheck-mode)
  (setq-default flycheck-disabled-checkers '(python-ruff))
  :config
  )

;; https://github.com/flycheck/flycheck-pos-tip
(use-package flycheck-pos-tip
  :after flycheck
  :config (flycheck-pos-tip-mode 1))

;; https://github.com/flycheck/flycheck-eglot
(use-package flycheck-eglot
  ;; :straight (:host github :repo "flycheck/flycheck-eglot" upgrade: t)
  :after (flycheck eglot)
  :config (global-flycheck-eglot-mode 1))

;; ------------
;; Dictionaries
;; ------------

;; https://github.com/mtenders/emacs-leo
(use-package leo)

;; https://github.com/martenlienen/dictcc.el
(use-package dictcc)

;; https://github.com/lorniu/gt.el
(use-package gt
  :config
  (setq gt-langs '(de en))
  (setq gt-default-translator
    (gt-translator
      :taker   (gt-taker :text 'word :pick 'paragraph)
      :engines (list (gt-bing-engine) (gt-google-engine))
      ;; :render  (gt-insert-render :type 'replace)
      :render  (gt-buffer-render)
      )))

;; -------------
;; entertainment
;; -------------

;; https://github.com/isamert/empv.el
(use-package empv)

;; ----------
;; Text stuff
;; ----------

;; https://github.com/naiquevin/sphinx-doc.el
(use-package sphinx-doc)

;; https://github.com/Lindydancer/el2markdown
(use-package el2markdown)

;; ----------------------------------------------------------------------
;; --- eye candy
;; ----------------------------------------------------------------------

;; M-x consult-theme

;;; Fonts:
;;
;; For developer targeted fonts with a high number of glyphs (icons) its
;; recommended to install the Nerd-Fonts:
;;
;; TODO:
;;
;; - https://github.com/ryanoasis/nerd-fonts/pull/1913
;; - https://github.com/ryanoasis/nerd-fonts/releases/latest/download/
;;
;; On my desktops I installed at least these fonts:
;;
;; - NerdFontsSymbolsOnly
;; - AdwaitaMono           <-- the one I prefer in this emacs setup
;; - DejaVuSansMono

;; https://github.com/emacsmirror/nerd-icons
(use-package nerd-icons
  :straight (nerd-icons
              :type git
              :host github
              :repo "rainstormstudio/nerd-icons.el"
              ;; :files (:defaults "data"))
              )
  :custom
  ;; The Nerd Font you want to use in GUI. "Symbols Nerd Font Mono" is the
  ;; default.
  ;; (nerd-icons-font-family "Symbols Nerd Font Mono")
  (nerd-icons-font-family "AdwaitaMono Nerd Font Mono")
  )

;; https://github.com/jaypei/emacs-neotree
(use-package neotree
  :custom
  (neo-theme 'nerd-icons)
  )

(use-package nerd-icons-completion
  :after marginalia
  :config
  (nerd-icons-completion-mode)
  (add-hook 'marginalia-mode-hook #'nerd-icons-completion-marginalia-setup))

;; https://github.com/LionyxML/auto-dark-emacs
(use-package auto-dark
  :custom
  ;; https://github.com/protesilaos/modus-themes (built into GNU Emacs 28)
  (auto-dark-themes '((modus-vivendi) (modus-operandi)))
  (auto-dark-polling-interval-seconds 5)
  (auto-dark-allow-osascript nil)
  (auto-dark-allow-powershell nil)
  ;; (auto-dark-detection-method nil) ;; dangerous to be set manually
  :hook
  (auto-dark-dark-mode
    . (lambda ()
        ;; something to execute when dark mode is detected
        ))
  (auto-dark-light-mode
    . (lambda ()
        ;; something to execute when light mode is detected
        ))
  :init (auto-dark-mode))

;; https://github.com/bbatsov/solarized-emacs
(use-package solarized-theme)

;; https://github.com/nordtheme/emacs
(use-package nord-theme)

;; https://github.com/habamax/wildcharm-theme
(use-package wildcharm-theme)

;; ----------------------------------------------------------------------
;; --- tools
;; ----------------------------------------------------------------------

(require 'ffap)
(require 'dired)
(require 'flyspell)

(defun ofap-dired ()
  "Open file a point (cursor)."
  (interactive)
  (ofap (dired-get-file-for-visit)))

(defun ofap ( &optional file-name)
  "Open *file-at-point* with it's default application.

Find FILE-NAME, guessing a default from text around point and open
FILE-NAME with the default application of the desktop system:

* linux: /usr/bin/xdg-open
* MS-Windows: `w32-shell-execute'
* macOS: /usr/bin/open"
  (interactive)
  (let* (
          (file-name (or file-name (ffap-guesser) (ffap-prompter)))
          )
    (if (file-exists-p file-name)
      (cond ((or (eq system-type 'gnu/linux)
               (eq system-type 'linux))
              (call-process "/usr/bin/xdg-open" nil 0 nil file-name)
              )
        ((eq system-type 'darwin)
          (call-process "/usr/bin/open" nil 0 nil file-name))
        ((eq system-type 'windows-nt)
          (w32-shell-execute nil file-name))
        (t
          (call-process "/usr/bin/xdg-open" nil 0 nil file-name))
        )
      (message "can't find: %s" file-name))))

(defun spell-checker ()
  "Spell checker (on/off) with selectable dictionary."
  (interactive)
  (if flyspell-mode
    (flyspell--mode-off)
    (progn
      (flyspell-mode)
      (ispell-change-dictionary
        (completing-read
          "Use new dictionary (RET for *default*): "
          (and (fboundp 'ispell-valid-dictionary-list)
            (mapcar 'list (ispell-valid-dictionary-list)))
          nil t))
      )))

(defun untabify-buffer ()
  "Untabify current buffer."
  (interactive)
  (untabify (point-min) (point-max)))

;; ----------------------------------------------------------------------
(my/setup-init)
;; ----------------------------------------------------------------------

;; https://github.com/renzmann/.emacs.d?tab=readme-ov-file#render-ascii-color-escape-codes
(add-hook 'compilation-filter-hook #'my/display-ansi-colors)
(add-hook 'eshell-preoutput-filter-functions  #'ansi-color-apply)
(add-hook 'before-save-hook 'delete-trailing-whitespace)

(add-hook 'text-mode-hook #'hl-line-mode)
(add-hook 'org-mode-hook #'hl-line-mode)
(add-hook 'prog-mode-hook #'hl-line-mode)

(add-hook 'prog-mode-hook #'flyspell-prog-mode)
(add-hook 'prog-mode-hook 'electric-pair-local-mode)
(add-hook 'prog-mode-hook 'show-paren-local-mode)

;; https://github.com/renzmann/.emacs.d?tab=readme-ov-file#pyright-error-links-in-compilation
(with-eval-after-load 'compile
  (add-to-list 'compilation-error-regexp-alist-alist
    '(pyright "^[[:blank:]]+\\(.+\\):\\([0-9]+\\):\\([0-9]+\\).*$" 1 2 3))
  (add-to-list 'compilation-error-regexp-alist 'pyright))

;;; .emacs ends here
