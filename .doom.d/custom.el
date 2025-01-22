(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-safe-themes
   '("13096a9a6e75c7330c1bc500f30a8f4407bd618431c94aeab55c9855731a95e1" default))
 '(magit-todos-insert-after '(bottom) nil nil "Changed by setter of obsolete option `magit-todos-insert-at'")
 '(org-agenda-files
   '("~/Dropbox/todo.org" "/home/peverill/Dropbox/org-roam/daily/2024-10-01.org"))
 '(package-selected-packages
   '(org-babel-eval-in-repl org-roam-timestamps org-pomodoro org-anki))
 '(warning-suppress-types
   '(((org-element org-element-cache))
     ((org-element org-element-cache))
     (defvaralias))))

(setq fancy-splash-image (concat doom-user-dir "emacs-1-logo-svg-vector.svg"))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

;; set up slime
(after! slime
  (load (expand-file-name "~/quicklisp/slime-helper.el"))
  ;; Replace "sbcl" with the path to your implementation
  (setq inferior-lisp-program "/usr/bin/sbcl"))


;; These functions were added to allow word counts in headings
(defun org-element-parse-headline (&optional granularity visible-only)
  "Parse current headline.
GRANULARITY and VISIBLE-ONLY are like the args of `org-element-parse-buffer'."
  (let ((level (org-current-level)))
    (org-element-map
    (org-element-parse-buffer granularity visible-only)
    'headline
      (lambda (el)
    (and
     (eq (org-element-property :level el) level)
     (<= (org-element-property :begin el) (point))
     (<= (point) (org-element-property :end el))
     el))
      nil 'first-match 'no-recursion)))

(cl-defun org+-count-words-of-heading (&key (worthy '(paragraph bold italic underline code footnote-reference link strike-through subscript superscript table table-row table-cell))
                        (no-recursion nil))
  "Count words in the section of the current heading.
WORTHY is a list of things worthy to be counted.
This list should at least include the symbols:
paragraph, bold, italic, underline and strike-through.

If NO-RECURSION is non-nil don't count the words in subsections."
  (interactive (and current-prefix-arg
            (list :no-recursion t)))
  (let ((word-count 0))
    (org-element-map
    (org-element-contents (org-element-parse-headline))
    '(paragraph table)
      (lambda (par)
    (org-element-map
        par
        worthy
        (lambda (el)
          (cl-incf
           word-count
           (cl-loop
        for txt in (org-element-contents el)
        when (eq (org-element-type txt) 'plain-text)
        sum
        (with-temp-buffer
          (insert txt)
          (count-words (point-min) (point-max))))
           ))))
      nil nil (and no-recursion 'headline)
      )
      (when (called-interactively-p 'any)
      (message "Word count in section: %d" word-count))
    word-count))




;; keybind for previous date page.

;;(after! org (define-key org-mode-map (kbd "<f9>") #'org-roam-dailies-goto-previous-node))
;;(global-set-key (kbd "<f9>") 'org-roam-dailies-goto-previous-node)
;;(map! "<f9>" #'org-roam-dailies-goto-previous-node
;;      "<f10>" #'org-roam-dailies-goto-next-node)

(after! julia-repl
  (julia-repl-set-terminal-backend 'vterm)
  (define-key julia-repl-mode-map (kbd "<M-RET>") 'julia-repl-send-line)
  (define-key julia-repl-mode-map (kbd "<S-return>") 'julia-repl-send-buffer)
   )


;; Org/Org Roam custom configuration
(setq org-roam-directory (file-truename "~/Dropbox/org-roam"))

;; set up todo workflow states.
(after! org (setq org-todo-keywords
      '((sequence "TODO" "|" "DONE" ">>>>" "<<<<" "XXXX"))))

;; don't gray out DONE headlines.
(after! org (setq org-fontify-done-headline nil))

(add-hook! 'org-mode-hook 'real-auto-save-mode)
(add-hook! 'org-mode-hook 'auto-revert-mode)

;; Capture template definitions
(setq org-roam-capture-templates
      '(("d" "default" plain "%?" :target
	 (file+head "%<%Y%m%d%H%M%S>-${slug}.org" "#+title: ${title}\n#+begindate: %U\n")
	 :unnarrowed t)
      ("r" "reference" plain "%?"
         :if-new
         (file+head "reference/${slug}.org" "#+title: ${title}\n#+author: \n#+type: \n#+begindate: %U\n#+finishdate: \n")
         :immediate-finish f
         :unnarrowed t)
        ))


;; Org Roam dailies configuration
(setq org-roam-dailies-directory "daily/")

;; Not sure what this is from but probably defunct?
;; (setq org-roam-dailies-capture-templates
;;       '(("d" "default" entry
;;          "* %?"
;;          :target (file+head "%<%Y-%m-%d>.org"
;;                             "#+title: %<%Y-%m-%d>\n"))))

(setq org-roam-dailies-capture-templates
      '(("d" "daily" entry "* %?"
	 :target (file+head "%<%Y-%m-%d>.org"
			    "#+TITLE: %<%Y-%m-%d %A>
* Journal
* Time
#+BEGIN: clocktable :scope file :maxlevel 3
#+END:
* Agenda
** Journal/Email
* Deferred/Do Later"))))

(defun my/org-roam-dailies-goto-today ()
  (interactive)
  (org-roam-dailies-goto-today "d"))

;; This is an old function to defer todo tasks. It's not great and I haven't used it.
;; it should be modified to just insert the heading into the daily page.
;; (defun org-bujo-defer ()
;;   "Set the workflow state of an Org Mode heading with status 'TODO' to '>>>>'
;; and copy the entire line into the kill ring.
;; The original form of the heading, still with the state 'TODO', is also captured."
;;   (interactive)
;;   (save-excursion
;;     (org-back-to-heading t)
;;     (when (looking-at org-complex-heading-regexp)
;;       (let* ((element (org-element-at-point))
;;              (todo-type (org-element-property :todo-type element))
;;              (headline (org-element-property :raw-value element))
;;              (state-change (if (eq todo-type 'todo)
;;                                ">>>>"
;;                              nil)))
;;         (when state-change
;;           (let* ((line-start (line-beginning-position))
;;                  (line-end (line-end-position)))
;;             (kill-new (buffer-substring-no-properties line-start line-end))
;;             (kill-ring-save line-start line-end)
;;             (org-todo state-change)))))))
