
(load "centered-window-mode/centered-window.el")
(load "mpages/mpages.el")
(load "markdown-mode/markdown-mode.el")

(require 'package) ;; MELPA config
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)
(package-initialize)

;;Rmarkdown config
(add-to-list 'auto-mode-alist
             '("\\.[rR]md\\'" . poly-gfm+r-mode))

;;(autoload 'markdown-mode "markdown-mode"
;;   "Major mode for editing Markdown files" t)
(add-to-list 'auto-mode-alist '("\\.markdown\\'" . markdown-mode))
(add-to-list 'auto-mode-alist '("\\.md\\'" . markdown-mode))

(autoload 'gfm-mode "markdown-mode"
   "Major mode for editing GitHub Flavored Markdown files" t)
(add-to-list 'auto-mode-alist '("README\\.md\\'" . gfm-mode))

;; Save temp files in tmp
(setq backup-directory-alist
`((".*" . ,temporary-file-directory)))
(setq auto-save-file-name-transforms
`((".*" ,temporary-file-directory t)))

;; Don't show startup
(setq inhibit-startup-screen t)

;; use the recycling
(setq delete-by-moving-to-trash t)

;;system specific variables
(custom-set-variables
 ;; where are mpages stored?
 (let ((default-directory system-user-path-dropbox))
   '(mpages-content-directory (expand-file-name "mpages/"))
   )
 '(smtpmail-smtp-server "Smtp.gmail.com")
 '(smtpmail-smtp-service 25)
 )

;; font and theme settings.
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes '(wombat))
 '(package-selected-packages '(csv-mode)))

;; Save recent files (recentf)
(require 'recentf)
(recentf-mode 1)
(setq recentf-max-menu-items 15)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)
