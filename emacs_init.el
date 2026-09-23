;; -*- lexical-binding: t; -*-
(setq gc-cons-threshold (* 100 1024 1024))
(add-hook 'emacs-startup-hook
          (lambda ()
            (setq gc-cons-threshold (* 800 1024))))

(menu-bar-mode -1)
(setq inhibit-startup-screen t)
(setq-default truncate-lines t)


(setq make-backup-files nil)

(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(display-line-numbers-width-start t)
 '(package-selected-packages nil))

;; ============================================================
;; Memo 
;; ============================================================

(defun memo ()
  "Open memo.md"
  (interactive)
  (find-file (expand-file-name "Documents/memo.md" "~")))

(global-set-key (kbd "C-c m") #'memo)


;; ============================================================
;; GUI
;; ============================================================

;; (defun my/gui-setup ()
;;   (set-face-attribute 'default nil :font "JetBrainsMono Nerd Font" :height 120)
;;   (set-fontset-font nil 'japanese-jisx0208
;; 		    (font-spec :family "Noto Sans CJK JP"))
;;   (scroll-bar-mode -1)
;;   (tool-bar-mode -1))
;; 
;; (add-hook 'after-make-frame-functions
;; 	  (lambda (frame)
;; 	    (with-selected-frame frame
;; 	      (my/gui-setup))))
;; (when (display-graphic-p)
;;   (my/gui-setup))
    



;; ============================================================
;; Line Number
;; ============================================================

(global-display-line-numbers-mode t)
(setq display-line-numbers-type 'visual)



;; ============================================================
;; Smooth Scrolling
;; ============================================================

(if (fboundp 'pixel-scroll-precision-mode)
    (pixel-scroll-precision-mode 1))
(setq scroll-conservatively 101)       
(setq scroll-margin 3)                
(setq scroll-step 1)                 
(setq fast-but-imprecise-scrolling t)
(setq redisplay-skip-initial-frame t)



;; ============================================================
;; Package Manager
;; ============================================================

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
	("elpa" . "https://elpa.gnu.org/packages/")))
(package-initialize)
(setq use-package-always-defer t)
(unless package-archive-contents (package-refresh-contents))
(when (fboundp 'native-compile-async)
  (setq native-comp-async-report-warnings-errors nil)
  (setq comp-deferred-compilation t))



;; ============================================================
;; Color Scheme
;; ============================================================

(use-package catppuccin-theme
  :ensure t
  :init
  (setq catppuccin-flavor 'mocha)
  (load-theme 'catppuccin :no-confirm))



;; ============================================================
;; VIM keybind
;; ============================================================

(setq evil-undo-system 'undo-redo)
(setq evil-want-C-u-scroll t)
(setq evil-search-module 'evil-search)
(setq evil-ex-search-vim-style-regexp t)

(use-package evil
  :ensure t
  :defer nil
  :init
  (setq evil-want-integration t)
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

(use-package evil-collection
  :after evil
  :ensure t
  :defer nil
  :config
  (evil-collection-init))

(use-package evil-goggles
  :ensure t
  :defer nil
  :config
  (evil-goggles-mode)
  (setq evil-goggles-duration 0.1)
  (setq evil-goggles-enable-delete nil))



;; ============================================================
;; Tab bar
;; ============================================================

(use-package centaur-tabs
  :ensure t
  :defer nil
  :config
  (centaur-tabs-mode 1))

(with-eval-after-load 'evil
  (with-eval-after-load 'centaur-tabs
    (evil-define-key 'normal 'global (kbd "H") 'centaur-tabs-backward)
    (evil-define-key 'normal 'global (kbd "L") 'centaur-tabs-forward)))



;; ============================================================
;; Terminal
;; ============================================================

(use-package vterm
  :ensure t
  :bind (("C-c v" . vterm))
  :hook (vterm-mode . (lambda () (display-line-numbers-mode -1)))
  :config
  (evil-set-initial-state 'vterm-mode 'emacs)
  (setq explicit-shell-file-name "zsh")
  (setq vterm-shell "zsh")
  (setq vterm-max-scrollback 10000)
  (with-eval-after-load 'vterm
    (define-key vterm-mode-map (kbd "<escape>") #'vterm-send-escape)))



;; ============================================================
;; moodline
;; ============================================================

(use-package doom-modeline
  :ensure t
  :init
  (setq doom-modeline-battery t)
  (setq doom-modeline-battery-percentage t)
  (setq doom-modeline-battery-refresh-rate 120)
  (setq doom-modeline-time t)
  :hook (after-init . doom-modeline-mode))



;; ============================================================
;; HTTP Proxy
;; ============================================================

(defvar proxy-url "po.cc.ibaraki-ct.ac.jp:3128")

(defun proxy-on ()
  (interactive)
  (setq url-proxy-services
	'(("http" . proxy-url)
	  ("https" . proxy-url)
	  ("no_proxy" . "^\\(localhost\\|127\\.0\\.0\\.1\\)")))
  (setenv "http_proxy" (concat "http://" proxy-url))
  (setenv "https_proxy" (concat "http://" proxy-url))
  (setenv "no_proxy" "localhost,127.0.0.1")
  (message "Proxy enabled: %s" (concat "http://" proxy-url)))

(defun proxy-off ()
  (interactive)
  (setq url-proxy-services nil)
  (setenv "http_proxy" nil)
  (setenv "https_proxy" nil)
  (setenv "no_proxy" nil)
  (message "Proxy disabled"))


;; ============================================================
;; LaTeX
;; ============================================================

(use-package tex
  :ensure auctex
  :defer t
  :config
  (setq-default TeX-engine 'luatex)
  (setq-default Japanese-TeX-engine 'luatex)
  (setq TeX-auto-save t)
  (setq TeX-parse-self t))


;; ============================================================
;; LSP
;; ============================================================

(use-package eglot
  :ensure t
  :hook ((c-mode c++-mode python-mode rust-mode) . eglot-ensure)
  :config
  (add-hook 'before-save-hook 'eglot-format-buffer nil t)
  (add-to-list 'eglot-server-programs
               '(python-mode . (lambda (interactive)
                                 (let ((py-path (pet-executable-find "python"))
                                       (venv-path (pet-virtualenv-root)))
                                   (when venv-path
                                     (setenv "CONDA_PREFIX" venv-path)
                                     (setenv "VIRTUAL_ENV" venv-path))
                                   '("basedpyright-langserver" "--stdio")))))
  (setq-default eglot-workspace-configuration
                '((:basedpyright . (:analysis (:reportMissingTypeStubs "none"))))))



;; ============================================================
;; Languages
;; ============================================================

;; C
(use-package cc-mode
  :ensure nil
  :config
  (setq-default c-basic-offset 4
		tab-width 4
		indent-tabs-mode nil)
  (add-hook 'c-mode-common-hook
            (lambda () (c-set-style "linux"))))


;; Python
(use-package python
  :ensure t
  :hook (python-mode . eglot-ensure))

(use-package pet
  :ensure t
  :config
  (add-hook 'python-mode-hook 'pet-mode)
  (add-hook 'python-mode-hook
            (lambda ()
              (setq-local python-shell-interpreter (pet-executable-find "python")
                          python-shell-interpreter-args "-i"))))

;; Rust
(use-package rust-mode
  :ensure t)

;; Common Lisp
(use-package sly
  :ensure t
  :config
  ;; Lisp処理系を指定
  (setq inferior-lisp-program "sbcl")) 

;; Scheme (Gauche)
(use-package geiser-gauche
  :ensure t
  :config
  ;; Gauche
  (setq geiser-gauche-binary "gosh"))

;; Markdown
(use-package markdown-mode
  :ensure t
  :mode ("\\.md\\'" . gfm-mode)
  :config
  (setq-default markdown-hide-markup t)
  (setq markdown-display-inline-images t)
  (setq markdown-fontify-code-blocks-natively t)
  (defun markdown-preview-firefox ()
      (interactive)
      (let* ((input-file (buffer-file-name))
          (output-file (concat "/tmp/" (file-name-base input-file) ".html")))
      (shell-command (format "pandoc -f markdown+pipe_tables -t html %s -o %s && /usr/bin/firefox %s &" 
                              input-file output-file output-file))
      (message "Opening in Firefox: %s" output-file)))
  (define-key markdown-mode-map (kbd "C-c C-c f") 'markdown-preview-firefox)
  :custom
  (markdown-header-scaling t))


(use-package valign
  :ensure t
  :hook ((markdown-mode . valign-mode)
         (gfm-mode . valign-mode))
  :config (setq valign-fancy-bar t))



;; ============================================================
;; Clipboard
;; ============================================================

(setq select-enable-clipboard t)
(setq select-enable-primary t)

(use-package xclip
  :ensure t
  :config
  (setq xclip-method 'wl-copy)
  (xclip-mode 1))


;; ============================================================
;; Auto Complete
;; ============================================================

(use-package corfu
  :ensure t
  :init
  (global-corfu-mode)
  :config
  (setq corfu-auto t
        corfu-auto-delay 0.1
        corfu-auto-prefix 1))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
