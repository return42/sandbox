;; =============================================================================
;; ~/.emacs
;; =============================================================================

;; ----------------------------------------------------------------------
;; --- init this (my-)setup
;; ----------------------------------------------------------------------

(defun my-setup-init ()

  ;; When emacs has been started for the first time the package
  ;; directory does not exists --> ask to install required packages.

  (if (not (file-exists-p package-user-dir))
      (when (y-or-n-p "Should emacs install the required packages?")
	(my-packages-install)
	;; ...
	))

  ;; (bash-completion-setup)
  (my-custom-defaults)
  (my-key-bindings)
  (bookmark-bmenu-list)
  (switch-to-buffer "*Bookmark List*")

  (load-theme 'wombat)
  )

;; ----------------------------------------------------------------------
;; --- custom settings
;; ----------------------------------------------------------------------

(defun my-custom-defaults ()
  (setq custom-file "~/.emacs-custom")
  (custom-set-variables
   '(column-number-mode t)
   '(company-mode t)
   '(delete-selection-mode t)
   '(desktop-save-mode nil)
   '(fill-column 80)
   '(history-delete-duplicates t)
   '(inhibit-splash-screen t)
   '(package-selected-packages my-packages)
   '(quote (dired-recursive-deletes 'top))
   '(savehist-mode t nil (savehist))
   '(show-trailing-whitespace t)
   '(enable-dir-local-variables nil)
   '(tab-always-indent 'complete)
   '(js-indent-level 2)
   )
  (load "~/.emacs-custom" t t)
)

;; ----------------------------------------------------------------------
;; --- shortcuts
;; ----------------------------------------------------------------------

(defun my-key-bindings ()
  (keymap-global-set "C-<return>"      'fill-paragraph)
  (keymap-global-set "C-c c"           'compile)
  (keymap-global-set "C-c l"           'goto-line)
  (keymap-global-set "C-x C-f"         'find-file-at-point)
  (keymap-global-set "<f7>"            'spell-checker)
  (keymap-global-set "<f8>"            'dictcc-at-point)
  (fset 'yes-or-no-p 'y-or-n-p)
  )

;; ----------------------------------------------------------------------
;; --- packages
;; ----------------------------------------------------------------------

(require 'package)
(setq package-install-upgrade-built-in t)
;; (add-to-list 'package-archives '("gnu"   . "https://elpa.gnu.org/packages/"))
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize)

(setq my-packages
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
	lsp-pyright             ;; https://github.com/emacs-lsp/lsp-pyright
	realgud                 ;; https://github.com/realgud/realgud
	company                 ;; http://company-mode.github.io/

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

(defun my-packages-install ()
  "Install 'my-packages'."
  (interactive)
  (package-list-packages)
  (setq package-selected-packages my-packages)
  (package-install-selected-packages)
  (message "my-packages installed / to update use: M-x my-packages-update")
  )

(defun my-packages-update ()
  "Update 'my-packages'."
  (interactive)
  (package-upgrade-all)
  (package-autoremove)
  )

;; ----------------------------------------------------------------------
(my-setup-init)
;; ----------------------------------------------------------------------

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

(use-package lsp-mode
  :hook
  ((c++-mode python-mode java-mode js-mode js2-mode) . lsp-deferred)
  :commands lsp
  :custom
  (add-hook 'lsp-mode-hook 'lsp-ui-mode) ;; Optional, see below
  (add-hook 'go-mode-hook #'lsp-deferred))

(use-package js2-mode
  :mode ("\\.js\\'"
         "\\.jsx\\'"))


(use-package lsp-ui
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-doc-header t)
  (setq lsp-ui-doc-include-signature t)
  (setq lsp-ui-doc-border (face-foreground 'default))
  (setq lsp-ui-sideline-show-code-actions t)
  (setq lsp-ui-sideline-delay 0.05)
  :custom
  (lsp-ui-peek-always-show t)
  (lsp-ui-sideline-show-hover t)
  (lsp-ui-doc-enable nil))

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

;; ----------------------------------------------------------------------
;; --- tools
;; ----------------------------------------------------------------------

(defun ofap-dired ()
  (interactive)
  (ofap (dired-get-file-for-visit)))

(defun ofap ( &optional file-name)
  "Open *file-at-point* with it's default application.

Find FILENAME, guessing a default from text around point and open FILENAME with
the default application of the desktop system:

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
  "spell checker (on/off) with selectable dictionary"
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
  "Untabify current buffer"
  (interactive)
  (untabify (point-min) (point-max)))
