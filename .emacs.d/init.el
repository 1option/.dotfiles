;;; init.el --- -*- lexical-binding: t -*-
;;  Author: Maksim Rozhkov
;;; Commentary:
;;  This is my personal Emacs configuration
;;; Code:

(setq package-list
      '(dap-mode vimrc-mode yaml-mode xclip use-package undo-fu-session undo-fu org-bullets orderless minions magit lua-mode lsp-ui lsp-pyright lsp-java json-mode ivy-prescient hl-todo gruber-darker-theme gcmh format-all flycheck evil-nerd-commenter dashboard counsel company-prescient pulsar flx wgrep lin web-mode ivy-posframe amx dired-subtree savehist modus-themes))

;; Initialize package sources
(require 'package)

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                         ("org" . "https://orgmode.org/elpa/")
                         ("elpa" . "https://elpa.gnu.org/packages/")))

(package-initialize)
(unless package-archive-contents
  (package-refresh-contents))

;; Initialize use-package on non-Linux platforms
(unless (package-installed-p 'use-package)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

(dolist (package package-list)
  (unless (package-installed-p package)
    (package-install package)))

;; {{{
;; Bootstrap 'straight'
(setq straight-repository-branch "develop")
(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name "straight/repos/straight.el/bootstrap.el" user-emacs-directory))
      (bootstrap-version 6))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))
(straight-use-package 'use-package)

;; automatically ensure every package exists (like :ensure or :straight)
;; (setq straight-use-package-by-default t)

;; Configure use-package to use straight.el by default
;; (use-package straight
;;   :custom
;;   (straight-use-package-by-default t))
;; }}}

;; Open files externally
(use-package openwith
  ;; :if (not dw/is-termux)
  :config
  (setq openwith-associations
        (list
         (list (openwith-make-extension-regexp
                '("mpg" "mpeg" "mp3" "mp4"
                  "avi" "wmv" "wav" "mov" "flv"
                  "ogm" "ogg" "mkv"))
               "mpv"
               '(file))
         (list (openwith-make-extension-regexp
                '("xbm" "pbm" "pgm" "ppm" "pnm"
                  "png" "gif" "bmp" "tif" "jpeg")) ;; Removed jpg because Telega was
               ;; causing feh to be opened...
               "feh"
               '(file))
         (list (openwith-make-extension-regexp
                '("pdf"))
               "zathura"
               '(file)))))


;; Block templates
;; This is needed as of Org 9.2
(require 'org-tempo)

(add-to-list 'org-structure-template-alist '("sh" . "src sh"))
(add-to-list 'org-structure-template-alist '("el" . "src emacs-lisp"))
(add-to-list 'org-structure-template-alist '("sc" . "src scheme"))
(add-to-list 'org-structure-template-alist '("ts" . "src typescript"))
(add-to-list 'org-structure-template-alist '("py" . "src python"))
(add-to-list 'org-structure-template-alist '("go" . "src go"))
(add-to-list 'org-structure-template-alist '("yaml" . "src yaml"))
(add-to-list 'org-structure-template-alist '("json" . "src json"))

(use-package emacs
  :init
  (save-place-mode +1)
  :hook
  (after-init . winner-mode)
  :config
  ;; Scrolling is moving the document, not my cursor
  (setq scroll-preserve-screen-position nil)
  ;; Calendar
  (setq calendar-week-start-day 1)
  (setq display-time-24hr-format t)
  ;; (setq-default line-spacing .2)
  (setq cursor-in-non-selected-windows nil)
  (defface ct/tab-bar-numbers
    '((t
       :inherit tab-bar
       :family "Iosevka Comfy"
       :weight regular))
    "Face for tab numbers in both active and inactive tabs.")
  (defvar ct/circle-numbers-alist
    '((0 . "⓪")
      (1 . "①")
      (2 . "②")
      (3 . "③")
      (4 . "④")
      (5 . "⑤")
      (6 . "⑥")
      (7 . "⑦")
      (8 . "⑧")
      (9 . "⑨"))
    "Alist of integers to strings of SF Symbols with numbers in boxes.")
  (defun ct/tab-bar-tab-name-format-default (tab i)
    (let ((current-p (eq (car tab) 'current-tab)))
      (concat
       (propertize
        (when (and tab-bar-tab-hints (< i 10)) (alist-get i ct/circle-numbers-alist))
        'face 'ct/tab-bar-numbers)
       " "
       (propertize
        (concat (alist-get 'name tab)
	        (or (and tab-bar-close-button-show
			 (not (eq tab-bar-close-button-show
				  (if current-p 'non-selected 'selected)))
			 tab-bar-close-button)
		    ""))
        'face (funcall tab-bar-tab-face-function tab))
       " ")))
  (setq tab-bar-tab-name-format-function #'ct/tab-bar-tab-name-format-default
        tab-bar-tab-hints t)

  (setq tab-bar-new-tab-choice 'recentf-open-files)
  (setq tab-bar-close-button-show nil)
  ;; tab-bar-close-button " \x00d7 ") ;; Cross multiplication character
  (setq tab-bar-new-button-show nil)
  ;; tab-bar-new-button " + ")  ;; Thicker + than the flimsy default
  (setq tab-bar-separator nil)
  (setq tab-bar-format
	'(;;tab-bar-format-history ;; forward/back buttons
	  tab-bar-format-tabs-groups
	  tab-bar-separator
          ;; tab-bar-format-add-tab ;; new tab button
	  tab-bar-format-align-right
	  tab-bar-format-global))

  ;; Display battery and time in `tab-bar-format-global' section:
  (require 'battery)
  (when (and battery-status-function
	     (not (string-match-p "N/A"
				  (battery-format "%B"
						  (funcall battery-status-function)))))
    (display-battery-mode 1))
  (setq display-time-format "%Y-%m-%d %H:%M")   ;; Override time format.
  (setq display-time-default-load-average nil)  ;; Hide load average.
  (display-time-mode +1)

  ;; Bind 1-9 in the tab prefix map to switch to that tab.
  (mapcar (lambda (tab-number)
            (let ((funname (intern (format "ct/tab-bar-select-%d" tab-number)))
                  (docstring (format "Select tab %d by its absolute number." tab-number))
                  (key (kbd (format "%d" tab-number)))
                  (super-key (kbd (format "s-%d" tab-number))))
              (eval-expression `(defun ,funname ()
                                  ,docstring
                                  (interactive)
                                  (tab-bar-select-tab ,tab-number)))
              (eval-expression `(define-key tab-prefix-map ,key ',funname))
              (eval-expression `(global-set-key ,super-key ',funname))))
          (number-sequence 1 9))

  :hook
  (tab-bar-mode . tab-bar-history-mode)
  (after-init . tab-bar-mode)

  :bind
  ("s-[" . tab-bar-switch-to-prev-tab)
  ("s-]" . tab-bar-switch-to-next-tab)
  ("s-w" . tab-bar-new-tab)
  ("s-c" . tab-bar-close-tab) ; I constantly want to close a buffer this way.
  ("C-S-t" . tab-bar-undo-close-tab))

;; (use-package mlscroll
;;   :hook
;;   (after-init . mlscroll-mode))

(use-package which-key
  :init (which-key-mode)
  :diminish which-key-mode
  :config
  (setq which-key-idle-delay 1))

(use-package ibuffer
  :ensure t
  :init
  ;; Rewrite all programmatic calls to `list-buffers`. Should work without this.
					;(defalias 'list-buffers 'ibuffer-other-window)
  ;; Override `list-buffers` shortcut with ibuffer
  (global-unset-key (kbd "C-x b"))
  (global-set-key (kbd "C-x b") 'ibuffer-other-window))

;;; For packaged versions which must use `require':
(use-package modus-themes
  :ensure
  :init
  (require 'modus-themes)
  (setq
   modus-themes-italic-constructs nil
   modus-themes-bold-constructs t
   modus-themes-variable-pitch-ui t
   modus-themes-mixed-fonts t))

;;   ;; Theme overrides
;;   ;; (customize-set-variable 'modus-themes-common-palette-overrides
;; 		          ;; `(
;; 		            ;; Make the mode-line borderless
;; 		            ;; (bg-mode-line-active bg-inactive)
;; 		            ;; (fg-mode-line-active fg-main)
;; 		            ;; (bg-mode-line-inactive bg-inactive)
;; 		            ;; (fg-mode-line-active fg-dim)
;; 		            ;; (border-mode-line-active bg-inactive)
;; 		            ;; (border-mode-line-inactive bg-main)

;; 		            ;; macOS Selection colors
;;                             ;; (bg-region "#242679")
;;                             ;; (fg-region "#242679")
;;                             ;; ))
;;   (customize-set-variable 'modus-vivendi-palette-overrides
;; 	                  `(
;; 		            ;; More subtle gray for the inactive window and modeline
;; 		            (bg-inactive "#202020"))))

(use-package dired-subtree
  :ensure
  :defer
  :bind (:map dired-mode-map ("TAB" . dired-subtree-toggle)))

(use-package savehist
  :ensure t
  :hook (after-init . savehist-mode))

(use-package treemacs
  :defer
  :demand
  :config
  (setq treemacs-position 'left
        treemacs-width 30
        treemacs-show-hidden-files t)

					;(setq treemacs--icon-size 16)
  (treemacs-resize-icons 16)

  ;; Don't always focus the currently visited file
  (treemacs-follow-mode -1)

  (defun ct/treemacs-decrease-text-scale ()
    (text-scale-decrease 1))
  :bind
  ("<f2>" . treemacs)
  :hook
  (treemacs-mode . ct/treemacs-decrease-text-scale))

(use-package treemacs-nerd-icons
  :after treemacs
  :config
  (treemacs-load-theme "nerd-icons"))

(use-package sudo-edit
  :ensure)

(use-package recentf
  :config
  (recentf-mode 1)
  ;; (setq recent-save-file "~/.emacs.d/recentf")
  (setq recentf-max-menu-items 10)
  (setq recentf-max-saved-items 100)
  (setq recentf-show-file-shortcuts-flag nil))

(use-package orderless
  :ensure t
  :custom
  (completion-styles '(orderless basic))
  (completion-category-overrides '((file (styles basic partial-completion)))))

(use-package lsp-mode
  :init
  (setq lsp-keymap-prefix "C-c l")
  :hook ((python-mode
	  ;; java-mode
	  js-mode
	  js-jsx-mode
	  typescript-mode
	  web-mode
	  ) . lsp-deferred)
  :commands lsp
  :config
  (add-hook 'java-mode-hook #'(lambda () (when (eq major-mode 'java-mode) (lsp-deferred))))
  (add-hook 'java-mode-hook 'lsp-java-lens-mode)
  (global-unset-key (kbd "<f4>"))
  (define-key global-map (kbd "<f4>") 'lsp-rename)
  (setq lsp-auto-guess-root t)
  (setq lsp-log-io nil)
  (setq lsp-restart 'auto-restart)
  (setq lsp-enable-indentation nil)
  (setq lsp-enable-links nil)
  (setq lsp-enable-symbol-highlighting nil)
  (setq lsp-enable-on-type-formatting nil)
  (setq lsp-signature-auto-activate nil)
  (setq lsp-lens-enable t)
  (setq lsp-signature-render-documentation nil)
  (setq lsp-eldoc-enable-hover nil)
  (setq lsp-eldoc-hook nil)
  (setq lsp-modeline-code-actions-enable nil)
  (setq lsp-modeline-diagnostics-enable nil)
  (setq lsp-headerline-breadcrumb-enable nil)
  (setq lsp-headerline-breadcrumb-icons-enable nil)
  (setq lsp-semantic-tokens-enable nil)
  (setq lsp-enable-folding nil)
  (setq lsp-enable-imenu nil)
  (setq lsp-completion-show-detail nil)
  ;; (setq lsp-enable-snippet nil)
  (setq lsp-enable-file-watchers nil)
  (setq lsp-keep-workspace-alive nil)
  (setq lsp-completion-show-kind nil)
  ;; (setq read-process-output-max (* 1024 1024)) ;; 1MB
  ;; (setq lsp-idle-delay 0.25)
  (setq lsp-auto-execute-action nil))

(use-package lsp-ui
  :commands lsp-ui-mode
  :custom-face
  (lsp-ui-sideline-global ((t (:italic t))))
  (lsp-ui-peek-highlight  ((t (:foreground unspecified :background unspecified :inherit isearch))))
  :config
  (setq lsp-ui-doc-enable nil)
  (setq lsp-ui-doc-show-with-mouse nil)
  (setq lsp-ui-doc-enhanced-markdown nil)
  (setq lsp-ui-doc-delay 0.01)
  (setq lsp-prefer-capf t)
  (when (display-graphic-p)
    (setq lsp-ui-doc-use-childframe t)
    (setq lsp-ui-doc-text-scale-level -1.0)
    (setq lsp-ui-doc-max-width 80)
    (setq lsp-ui-doc-max-height 25)
    (setq lsp-ui-doc-position 'at-point))
  (setq lsp-ui-doc-include-signature t)
  (setq lsp-ui-doc-border (face-foreground 'font-lock-comment-face))
  (setq lsp-ui-sideline-diagnostic-max-line-length 80)
  (setq lsp-ui-sideline-diagnostic-max-lines 2)
  (setq lsp-ui-peek-always-show t)
  (setq lsp-ui-sideline-delay 0.05))

(use-package lin
  :config
  (setq lin-face 'lin-blue)

  (setq lin-mode-hooks
	'(bongo-mode-hook
          dired-mode-hook
          elfeed-search-mode-hook
          git-rebase-mode-hook
          grep-mode-hook
          ibuffer-mode-hook
          ilist-mode-hook
          ledger-report-mode-hook
          log-view-mode-hook
          magit-log-mode-hook
          mu4e-headers-mode-hook
          notmuch-search-mode-hook
          notmuch-tree-mode-hook
          occur-mode-hook
          org-agenda-mode-hook
          pdf-outline-buffer-mode-hook
          proced-mode-hook
          tabulated-list-mode-hook))
  (lin-global-mode 1))

(use-package prescient
  :after counsel
  :config
  (prescient-persist-mode 1))

;; Python
(use-package lsp-pyright
  :ensure t
  :hook (python-mode . (lambda ()
                         (require 'lsp-pyright)
                         (lsp))))
;; Java
(use-package lsp-java
  :after lsp)

(use-package dap-mode
  ;; Uncomment the config below if you want all UI panes to be hidden by default!
  ;; :custom
  ;; (lsp-enable-dap-auto-configure nil)
  ;; :config
  ;; (dap-ui-mode 1)

  :config
  (require 'dap-java))


;; (use-package java-mode
;;   :ensure nil
;;   :after lsp-java)

(use-package company
  :hook (prog-mode . company-mode)
  :config
  (setq company-idle-delay 0)
  (setq company-minimum-prefix-length 1)
  (setq company-tooltip-align-annotations t)
  (setq company-require-match nil)
  (setq company-dabbrev-ignore-case t)
  (setq company-dabbrev-downcase t)
  ;; (setq company-text-icons-add-background t)
  ;; (setq company-text-icons-mapping t)
  ;; (setq company-text-icons-margin t)
  (setq company-format-margin-function  #'company-text-icons-margin)
  (setq company-frontends '(company-pseudo-tooltip-frontend ; show tooltip even for single candidate
                            company-echo-metadata-frontend))
  (unless (display-graphic-p)
    (define-key company-active-map (kbd "C-h") #'backward-kill-word)
    (define-key company-active-map (kbd "C-w") #'backward-kill-word))
  (define-key company-active-map (kbd "C-j") nil) ; avoid conflict with emmet-mode
  (define-key company-active-map (kbd "C-n") #'company-select-next)
  (define-key company-active-map (kbd "C-p") #'company-select-previous)
  (if (display-graphic-p)
      (define-key company-active-map (kbd "<tab>") 'company-select-next)
    (define-key company-active-map (kbd "TAB") 'company-select-next))
  (define-key company-active-map (kbd "<backtab>") 'company-select-previous))

(use-package company-prescient
  :after (prescient company)
  :config
  (company-prescient-mode +1))

(use-package flycheck
  :hook ((prog-mode . flycheck-mode)
         (markdown-mode . flycheck-mode)
         (org-mode . flycheck-mode))
  :custom-face
  (flycheck-error   ((t (:inherit error :underline t))))
  (flycheck-warning ((t (:inherit warning :underline t))))
  :config
  (setq flycheck-check-syntax-automatically '(save mode-enabled))
  (setq flycheck-display-errors-delay 0.1)
  (setq-default flycheck-disabled-checkers '(python-pylint))
  (setq flycheck-flake8rc "~/.config/flake8")
  (setq flycheck-checker-error-threshold 1000)
  (setq flycheck-indication-mode nil)
  (define-key flycheck-mode-map (kbd "<f8>") #'flycheck-next-error)
  (define-key flycheck-mode-map (kbd "<S-f8>") #'flycheck-previous-error)
  (flycheck-define-checker proselint
    "A linter for prose. Install the executable with `pip3 install proselint'."
    :command ("proselint" source-inplace)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": "
	      (id (one-or-more (not (any " "))))
	      (message) line-end))
    :modes (markdown-mode org-mode))
  (add-to-list 'flycheck-checkers 'proselint))

(use-package lua-mode)

(use-package json-mode)

(use-package vimrc-mode)

;; YAML
(use-package yaml-mode
  :mode "\\.ya?ml\\'")

;; Compile
(use-package compile
  :straight nil
  :custom
  (compilation-scroll-output t))

(defun auto-recompile-buffer ()
  (interactive)
  (if (member #'recompile after-save-hook)
      (remove-hook 'after-save-hook #'recompile t)
    (add-hook 'after-save-hook #'recompile nil t)))

(use-package yasnippet
  :hook (prog-mode . yas-minor-mode)
  :config
  (yas-reload-all))

(use-package smartparens
  :config
  (smartparens-global-mode t)
  (sp-pair "'" nil :actions nil)
  (sp-pair "`" nil :actions nil)
  (setq sp-highlight-pair-overlay nil))

;; Autoindent
(defun indent-between-pair (&rest _ignored)
  (newline)
  (indent-according-to-mode)
  (forward-line -1)
  (indent-according-to-mode))

(sp-local-pair 'prog-mode "{" nil :post-handlers '((indent-between-pair "RET")))
(sp-local-pair 'prog-mode "[" nil :post-handlers '((indent-between-pair "RET")))
(sp-local-pair 'prog-mode "(" nil :post-handlers '((indent-between-pair "RET")))

;; Automatically dim buffers that don’t have focus
(use-package auto-dim-other-buffers
  :ensure
  :defer
  :commands auto-dim-other-buffers-mode
  :config
  (setq auto-dim-other-buffers-dim-on-switch-to-minibuffer nil)
  (setq auto-dim-other-buffers-dim-on-focus-out t))

;; Dashboard
(use-package dashboard
  :ensure t
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-startup-banner 'logo)
  (setq dashboard-banner-logo-title "( E M A C S )")
  (setq dashboard-init-info "")
  (setq dashboard-items nil)
  (setq dashboard-set-footer t)
  (setq dashboard-footer-icon "")
  ;; (setq dashboard-footer-messages '("😈 Happy hacking!   "))
  (define-key dashboard-mode-map (kbd "<f5>") #'(lambda ()
                                                  (interactive)
                                                  (dashboard-refresh-buffer)
                                                  (message "Refreshing Dashboard...done"))))
(use-package ace-window
  :bind (("M-o" . ace-window))
  :custom
  (aw-scope 'frame)
  (aw-keys '(?a ?s ?d ?f ?g ?h ?j ?k ?l))
  (aw-minibuffer-flag t)
  :config
  (ace-window-display-mode 1))

;; Evil-Nerd2-commenter
(use-package evil-nerd-commenter
  :init
  (evilnc-default-hotkeys nil t))
(global-set-key (kbd "M-;") 'evilnc-comment-or-uncomment-lines)

;; (use-package minions
;;   :config
;;   (setq minions-mode-line-lighter "")
;;   (setq minions-mode-line-delimiters '("" . ""))
;;   (minions-mode +1))

(use-package org
  :hook ((org-mode . visual-line-mode)
	 (org-mode . auto-fill-mode)
	 (org-mode . org-indent-mode)
	 (org-mode . (lambda ()
		       (setq-local olivetti-body-width (+ fill-column 5)))))
  :config
  (require 'org-tempo)
  (setq org-link-descriptive nil)
  (setq org-startup-folded nil)
  (setq org-todo-keywords '((sequence "TODO" "DOING" "DONE")))
  (add-to-list 'org-file-apps '("\\.pdf\\'" . emacs))
  (setq org-html-checkbox-type 'html))

(use-package org-bullets
  :hook (org-mode . org-bullets-mode))

(use-package undo-fu-session
  :config
  (setq undo-fu-session-incompatible-files '("/COMMIT_EDITMSG\\'" "/git;-rebase-todo\\'"))
  (undo-fu-session-global-mode))

(use-package undo-fu
  :config
  (global-unset-key (kbd "C-z"))
  (global-set-key (kbd "C-z")   'undo-fu-only-undo)
  (global-set-key (kbd "C-S-z") 'undo-fu-only-redo))

(use-package magit
  :bind ("C-x g" . magit-status)
  :config
  (local-unset-key (kbd "f"))
  (define-key magit-mode-map (kbd "<f5>") #'(lambda ()
                                              (interactive)
                                              (magit-refresh)
                                              (message "Refreshing Magit...done"))))

;; Markdown
(use-package markdown-mode
  :straight t
  :mode "\\.md\\'"
  :config
  (setq markdown-command "marked"))

;; clang-format
(use-package clang-format)
(setq clang-format-style-option "llvm")

(defun clang-format-buffer-llvm ()
  (interactive)
  (clang-format-buffer)
  (save-buffer))

;; format
(use-package format-all
  :preface
  (defun ian/format-code ()
    "Auto-format whole buffer."
    (interactive)
    (if (derived-mode-p 'prolog-mode)
        (prolog-indent-buffer)
      (format-all-buffer))
    (save-buffer))
  :config
  (global-set-key (kbd "C-f") #'ian/format-code)
  (add-hook 'prog-mode-hook #'format-all-ensure-formatter))

(define-key java-mode-map (kbd "C-f") #'clang-format-buffer-llvm)

;; Compile
(add-hook 'java-mode-hook
	  (lambda ()
	    (set (make-local-variable 'compile-command)
                 (concat "java " buffer-file-name))))

;; HTML
(use-package web-mode
  :mode "(\\.\\(html?\\|ejs\\|tsx\\|jsx\\)\\'"
  :config
  (setq-default web-mode-code-indent-offset 2)
  (setq-default web-mode-markup-indent-offset 2)
  (setq-default web-mode-attribute-indent-offset 2))

;; 1. Start the server with `httpd-start'
;; 2. Use `impatient-mode' on any buffer
(use-package impatient-mode
  :straight t)

(use-package skewer-mode
  :straight t)

;; ivy
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-f" . ivy-alt-done)
         ("C-l" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         :map ivy-switch-buffer-map
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-done)
         ("C-d" . ivy-switch-buffer-kill)
         :map ivy-reverse-i-search-map
         ("C-k" . ivy-previous-line)
         ("C-d" . ivy-reverse-i-search-kill))
  :init
  (ivy-mode 1)
  :config
  (setq ivy-use-virtual-buffers t)
  (setq ivy-wrap t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)

  ;; Use different regex strategies per completion command
  (push '(completion-at-point . ivy--regex-fuzzy) ivy-re-builders-alist) ;; This doesn't seem to work...
  (push '(swiper . ivy--regex-ignore-order) ivy-re-builders-alist)
  (push '(counsel-M-x . ivy--regex-ignore-order) ivy-re-builders-alist)

  ;; Set minibuffer height for different commands
  (setf (alist-get 'counsel-projectile-ag ivy-height-alist) 15)
  (setf (alist-get 'counsel-projectile-rg ivy-height-alist) 15)
  (setf (alist-get 'swiper ivy-height-alist) 15)
  (setf (alist-get 'counsel-switch-buffer ivy-height-alist) 7))

(use-package ivy-hydra
  :defer t
  :after hydra)

(use-package ivy-rich
  :init
  (ivy-rich-mode 1)
  :after counsel
  :config
  (setcdr (assq t ivy-format-functions-alist)
	  'ivy-format-function-line))

;; swiper
(use-package swiper
  :ensure t
  :after ivy
  :custom
  (swiper-action-recenter t)
  (swiper-goto-start-of-match t)
  (swiper-include-line-number-in-search t))

(use-package ivy-posframe
  :demand t
  :after ivy
  :custom
  (ivy-posframe-display-functions-alist
   '((t . ivy-posframe-display-at-frame-center)
     (swiper . ivy-posframe-display-at-frame-bottom-left)
     (complete-symbol . ivy-posframe-display-at-point)
     (counsel-M-x . ivy-posframe-display-at-frame-center)))
  :config
  (ivy-posframe-mode))

;; ivy-prescient
(use-package ivy-prescient
  :after prescient
  :config
  (ivy-prescient-mode 1))

;; Counsel
(use-package counsel
  :demand t
  :bind (("M-x" . counsel-M-x)
         ;; ("C-x b" . counsel-ibuffer)
         ("C-x C-f" . counsel-find-file)
         ("C-M-l" . counsel-imenu)
         :map minibuffer-local-map
         ("C-r" . 'counsel-minibuffer-history))
  :custom
  (counsel-linux-app-format-function #'counsel-linux-app-format-function-name-only)
  :config
  (setq ivy-initial-inputs-alist nil)) ;; Don't start searches with ^

(use-package amx
  :ensure t
  :after ivy
  :custom
  (amx-backend 'auto)
  ;; (amx-sava-file "~/.emacs.d/amx-items")
  (amx-history-length 50)
  (amx-show-key-bindings nil)
  :config
  (amx-mode 1))

(use-package real-auto-save
  :demand
  :delight
  :init
  (setq real-auto-save-interval 10) ;; in seconds

  ;; Patching this in until https://github.com/ChillarAnand/real-auto-save/pull/55 is merged
  (defun turn-on-real-auto-save () (real-auto-save-mode 1))
  (defun turn-off-real-auto-save () (real-auto-save-mode -1))
  (define-globalized-minor-mode global-real-auto-save-mode
    real-auto-save-mode turn-on-real-auto-save)

  (global-real-auto-save-mode 1)
  (add-hook 'message-mode-hook #'turn-off-real-auto-save))

(use-package goggles
  :hook ((prog-mode text-mode) . goggles-mode)
  :config
  (setq-default goggles-pulse t)) ;; set to nil to disable pulsing

(use-package pulsar)
(setq pulsar-delay 0.095)
(setq pulsar-iterations 10)
(setq pulsar-face 'pulsar-blue)
(setq pulsar-highlight-face 'pulsar-blue)
(setq pulsar-pulse t)
(pulsar-global-mode 1)
(add-hook 'next-error-hook #'pulsar-pulse-line)
(add-hook 'minibuffer-setup-hook #'pulsar-pulse-line)
(add-hook 'imenu-after-jump-hook #'pulsar-recenter-top)
(add-hook 'imenu-after-jump-hook #'pulsar-reveal-entry)
(define-key global-map (kbd "C-x l") #'pulsar-pulse-line-blue)

(use-package avy
  :commands (avy-goto-char avy-goto-word-0 avy-goto-line))

(use-package flx  ;; Improves sorting for fuzzy-matched results
  :after ivy
  :defer t
  :init
  (setq ivy-flx-limit 10000))

(use-package wgrep)

(defun bb/init ()
  "Windows or GNU/Linux."
  (pcase system-type
    ('windows-nt
     (customize-save-variable 'custom-file "c:/Users/cculpc/AppData/Roaming/.emacs.d/custom.el")
     (add-to-list 'load-path "C:/Users/cculpc/AppData/Roaming/.emacs.d/lisp/"))
    ('gnu/linux
     (customize-save-variable 'custom-file "~/.emacs.d/custom.el")
     (add-to-list 'load-path "~/.emacs.d/lisp/")))
  (load "font_rc")
  (load "keybindings_rc")
  (load "theme_rc")
  ;; (load "mood-line")
  (load "options_rc")
  (load-file custom-file))
(bb/init)

;; Profile emacs startup
(add-hook 'emacs-startup-hook
          (lambda ()
            (message "*** Emacs loaded in %s with %d garbage collections."
                     (format "%.2f seconds"
                             (float-time
			      (time-subtract after-init-time before-init-time)))
                     gcs-done)))

(provide 'init)
;;; init.el ends here
