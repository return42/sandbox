;;; .emacs --- my local emacs setup -*- lexical-binding: t -*-

;;; Commentary:

;;; Code:

;; =============================================================================
;; ~/.emacs
;; =============================================================================
;;
;; MEMO:
;;
;;   Inferior Emacs Lisp mode --> M-x ielm
;;
;; mise-en-place: https://mise.jdx.dev/installing-mise.html
;;
;;   $ mise use -g usage go node python shellcheck shfmt
;;   $ mise use -g jq # https://jqlang.org/
;;   $ mise use -g rust  # rustup command --> https://www.rust-lang.org/tools/install
;;   $ mise use -g github:kristoff-it/superhtml  # https://github.com/kristoff-it/superhtml
;;
;; Rust Development
;;
;;   $ rustup component add rust-analyzer
;;
;; Python development:
;;   $ mise use -g python
;;
;;   $ pipx install \
;;       uv hatch black \
;;       basedpyright ruff  'python-lsp-server[all]' pylsp-mypy jedi-language-server zuban
;;
;; JavaScript development:
;;   $ mise use -g node
;;
;;   Configure npm to install global executables to ~/.local/bin and the
;;   libraries to ~/.local/lib/node_modules/
;;
;;   $ npm config set prefix ~/.local
;;
;;   Typescript LSP alternative: vtsls --> https://github.com/yioneko/vtsls
;;
;;   $ npm install -g typescript-language-server typescript
;;   $ npm install -g @vtsls/language-server
;;   $ npm install -g eslint eslint-plugin-json
;;   $ npm install -g vscode-langservers-extracted
;;
;; bash scripting:
;;
;;   $ mise use -g shellcheck shfmt
;;   $ npm install -g bash-language-server


;; ----------------------------------------------------------------------
;; --- init this (my/)setup
;; ----------------------------------------------------------------------

(defun my/setup-init ()
  "Initialize my/setup.

When Emacs has been started for the first time the package directory
does not exists .. ask to install required packages."

  (if (not (file-exists-p package-user-dir))
      (when (y-or-n-p "Should Emacs install the required packages?")
        (my/packages-install)
        ;; ...
        ))

  ;; (bash-completion-setup)
  (my/custom-defaults)
  (my/key-bindings)
  (bookmark-bmenu-list)
  (switch-to-buffer "*Bookmark List*")
  (load-theme 'modus-vivendi)
  )

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
    '(global-so-long-mode t)
    '(history-delete-duplicates t)
    '(inhibit-splash-screen t)
    '(js-indent-level 2)
    '(mouse-wheel-tilt-scroll t)
    '(package-selected-packages my/packages)
    '(quote (dired-recursive-deletes 'top))
    '(save-place-local-mode 1)
    '(savehist-mode t nil (savehist))
    '(show-trailing-whitespace t)
    '(tab-always-indent 'complete)
    '(use-short-answers t)
    '(ispell-dictionary "en_US")
    ;; '(enable-dir-local-variables nil)
    )
  (load "~/.emacs-custom" t t)
  )

;; ----------------------------------------------------------------------
;; --- shortcuts
;; ----------------------------------------------------------------------

(defun my/key-bindings ()
  "My key bindings."
  (keymap-global-set "C-<return>"      'fill-paragraph)
  (keymap-global-set "C-c c"           'compile)
  (keymap-global-set "C-c l"           'goto-line)
  (keymap-global-set "C-x C-f"         'find-file-at-point)
  (keymap-global-set "<f7>"            'spell-checker)
  (keymap-global-set "<f8>"            'dictcc-at-point)
  )

;; ----------------------------------------------------------------------
;; --- packages
;; ----------------------------------------------------------------------

(require 'package)
(setq package-install-upgrade-built-in t)
;; (add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(setq my/packages
  '(
     use-package             ;; https://github.com/jwiegley/use-package
     totp                    ;; https://github.com/juergenhoetzel/emacs-totp
     f                       ;; https://github.com/rejeep/f.el
     corfu                   ;; https://github.com/minad/corfu
     elisp-slime-nav         ;; https://github.com/purcell/elisp-slime-nav
     flycheck                ;; https://www.flycheck.org
     flycheck-pos-tip        ;; https://github.com/flycheck/flycheck-pos-tip
     dap-mode                ;; https://emacs-lsp.github.io/dap-mode/
     lsp-mode                ;; https://emacs-lsp.github.io/lsp-mode/
     lsp-ui                  ;; https://github.com/emacs-lsp/lsp-ui
     realgud                 ;; https://github.com/realgud/realgud
     company                 ;; http://company-mode.github.io/
     treesit-auto            ;; https://github.com/renzmann/treesit-auto

     ;; https://github.com/emacs-tree-sitter/tree-sitter-langs/issues/1120
     ;; tree-sitter-langs       ;; https://github.com/emacs-tree-sitter/tree-sitter-langs

     mise                    ;; https://github.com/eki3z/mise.el

     yaml-mode               ;; https://github.com/yoshiki/yaml-mode
     apache-mode             ;; https://github.com/emacs-php/apache-mode
     nginx-mode              ;; https://github.com/ajc/nginx-mode
     json-mode               ;; https://github.com/json-emacs/json-mode
     lua-mode                ;; https://github.com/immerrr/lua-mode
     powershell              ;; https://github.com/jschaf/powershell.el
     go-mode                 ;; https://melpa.org/#/go-mode
     php-mode                ;; https://github.com/emacs-php/php-mode
     bash-completion         ;; https://github.com/szermatt/emacs-bash-completion
     paredit                 ;; https://paredit.org/

     graphql-mode            ;; https://github.com/davazp/graphql-mode

     ;; TXT stuff
     sphinx-doc              ;; https://github.com/naiquevin/sphinx-doc.el
     el2markdown             ;; https://github.com/Lindydancer/el2markdown
     markdown-mode           ;; https://jblevins.org/projects/markdown-mode/
     jinja2-mode             ;; https://github.com/paradoxxxzero/jinja2-mode
     web-mode                ;; https://github.com/fxbois/web-mode
     graphviz-dot-mode       ;; https://ppareit.github.io/graphviz-dot-mode/

     ;; SCM
     magit                   ;; https://github.com/magit/magit
     gitconfig               ;; https://github.com/tonini/gitconfig.el
     editorconfig            ;; https://editorconfig.org/

     ;; JavaScript
     js2-mode                ;; https://github.com/mooz/js2-mode

     ;; Python Stuff
     pet                     ;; https://github.com/wyuenho/emacs-pet
     pydoc                   ;; https://github.com/statmobile/pydoc
     pylint                  ;; https://github.com/emacsorphanage/pylint
     ;; pyvenv                  ;; https://github.com/jorgenschaefer/pyvenv
     pyvenv-auto             ;; https://github.com/nryotaro/pyvenv-auto
     pip-requirements        ;; https://github.com/Wilfred/pip-requirements.el
     lsp-pyright             ;; https://github.com/emacs-lsp/lsp-pyright

     ;; Dictionaries
     leo                     ;; https://github.com/mtenders/emacs-leo
     dictcc                  ;; https://github.com/martenlienen/dictcc.el

     ;; eye candy
     nord-theme              ;; https://github.com/nordtheme/emacs
     wildcharm-theme         ;; https://github.com/habamax/wildcharm-theme

     ;; entertainment
     ;;empv                    ;; https://github.com/isamert/empv.el
        )
  )

(defun my/packages-install ()
  "Install 'my/packages'."
  (interactive)
  (package-list-packages)
  (setq package-selected-packages my/packages)
  (package-install-selected-packages)
  (message "my/packages installed, to update use: M-x my/packages-update")
  )

(defun my/packages-update ()
  "Update 'my/packages'."
  (interactive)
  (package-upgrade-all)
  (package-autoremove)
  )

(defun my/display-ansi-colors ()
  "Render colors in a buffer that contains ASCII color escape codes."
  (interactive)
  (require 'ansi-color)
  (let ((inhibit-read-only t))
    (ansi-color-apply-on-region (point-min) (point-max))))


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

(add-hook 'prog-mode-hook #'flymake-mode)
(add-hook 'prog-mode-hook #'flyspell-prog-mode)
(add-hook 'prog-mode-hook 'electric-pair-local-mode)
(add-hook 'prog-mode-hook 'show-paren-local-mode)

;; https://github.com/renzmann/.emacs.d?tab=readme-ov-file#pyright-error-links-in-compilation
(with-eval-after-load 'compile
  (add-to-list 'compilation-error-regexp-alist-alist
    '(pyright "^[[:blank:]]+\\(.+\\):\\([0-9]+\\):\\([0-9]+\\).*$" 1 2 3))
  (add-to-list 'compilation-error-regexp-alist 'pyright))


;; ----------------------------------------------------------------------
;; --- use-package
;; ----------------------------------------------------------------------

(use-package dired
  :ensure nil
  :init
  (put 'dired-find-alternate-file 'disabled nil)
  :bind
  ( :map dired-mode-map
    ("o" . ofap-dired)))

(use-package editorconfig
  :config
  (editorconfig-mode 1))

(use-package pet
  :config
  (add-hook 'python-base-mode-hook 'pet-mode -10))

;; (use-package tree-sitter-langs
;;   :ensure t
;;   :after tree-sitter)

(use-package treesit-auto
  :custom
  (treesit-auto-install 'prompt)
  :config
  (treesit-auto-add-to-auto-mode-alist 'all)
  (global-treesit-auto-mode))

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

;; (use-package lsp-mode
;;   :commands lsp
;;   :hook
;;   ((c++-mode python-mode java-mode js-mode js2-mode) . lsp-deferred))
;;   :custom
;;   (add-hook 'lsp-mode-hook 'lsp-ui-mode) ;; Optional, see below
;;   (add-hook 'go-mode-hook #'lsp-deferred))

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

(use-package mise
  ;; :hook

  ;; der mise-mode macht aktuell noch probleme, wenn in dem projektordner eine
  ;; ".nvmrc" datei liegt, will man dann den ordner im emacs öffnen, dann kommt
  ;; aus dem mise mode ein "JSON error" (warum auch immer, die .nvmrc ist
  ;; nämlich keine JSON Datei) der zum Abbruch des Dired (ordner anzeigen) führt.

  ;; (after-init . global-mise-mode)
  )

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

(use-package python
  :config
  (require 'eglot)
  (setq python-check-command "uv run ruff format && uv run ruff check --fix")
  )
;;(add-hook 'python-mode-hook #'flymake-mode)
;;(add-hook 'python-ts-mode-hook #'flymake-mode))

;; (use-package js2-mode
;;   :mode ("\\.js\\'"
;;          "\\.jsx\\'"))

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

(use-package flycheck
  :init (global-flycheck-mode))

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
    (flyspell-mode-off)
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
