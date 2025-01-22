;; org mode experimentation
(global-set-key "\C-ca" 'org-agenda)
(require 'org-habit)
(add-to-list 'org-modules 'org-habit)
(add-to-list 'package-archives
	     '("melpa" . "https://melpa.org/packages/") t)
(setq org-agenda-files '("~/Dropbox/mpages"))


;; https://emacs.stackexchange.com/questions/69924/count-words-under-subtree-ignoring-the-properties-drawer-and-the-subheading
(require 'cl-lib)
(require 'org-element)

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

(with-eval-after-load 'org       
  (setq org-startup-indented t) ; Enable `org-indent-mode' by default
  (add-hook 'org-mode-hook #'visual-line-mode))

;; org-roam setup

(setq org-roam-directory (file-truename "~/Dropbox/org-roam"))

(setq org-roam-dailies-directory "daily/")

(setq org-roam-dailies-capture-templates
      '(("d" "default" entry
         "* %?"
         :target (file+head "%<%Y-%m-%d>.org"
                            "#+title: %<%Y-%m-%d>\n"))))

;; set up todo workflow states.
(setq org-todo-keywords
      '((sequence "TODO" "|" "DONE" ">>>>" "<<<<")))


; this should be modified to just insert the heading into the daily page.
(defun org-bujo-defer ()
  "Set the workflow state of an Org Mode heading with status 'TODO' to '>>>>'
and copy the entire line into the kill ring.
The original form of the heading, still with the state 'TODO', is also captured."
  (interactive)
  (save-excursion
    (org-back-to-heading t)
    (when (looking-at org-complex-heading-regexp)
      (let* ((element (org-element-at-point))
             (todo-type (org-element-property :todo-type element))
             (headline (org-element-property :raw-value element))
             (state-change (if (eq todo-type 'todo)
                               ">>>>"
                             nil)))
        (when state-change
          (let* ((line-start (line-beginning-position))
                 (line-end (line-end-position)))
            (kill-new (buffer-substring-no-properties line-start line-end))
            (kill-ring-save line-start line-end)
            (org-todo state-change)))))))


;; Org roam dailies template

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
