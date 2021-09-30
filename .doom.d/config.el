;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

(setq user-full-name "Aris Avgoustis"
      user-mail-address "aris.avgoustis@protonmail.com")

;; Font tweaks
(setq doom-font (font-spec :family "JetBrainsMono Nerd Font" :size 15)
      doom-variable-pitch-font (font-spec :family "JetbrainsMono Nerd Font" :size 15)
      doom-big-font (font-spec :family "JetBrainsMono Nerd Font" :size 24))
(after! doom-themes
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t))
(custom-set-faces!
  '(font-lock-comment-face :slant italic)
  '(font-lock-keyword-face :slant italic))
(setq global-prettify-symbols-mode t)

;; Org-mode tweaks
;; https://github.com/DogLooksGood/org-html-themify
(add-to-list 'load-path "~/elisp/org-html-themify")

(require 'org-html-themify)

(setq org-html-themify-themes
      '((dark . doom-dracula)
        (light . leuven)))

(add-hook 'org-mode-hook 'org-html-themify-mode)
;; end

(after! org
  (add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))
  (setq org-directory "~/Documents/org/"
        org-agenda-files '("~/Documents/org/agenda.org")
        org-default-notes-file (expand-file-name "notes.org" org-directory)
        org-ellipsis " ▼ "
        org-log-done 'time
        org-journal-dir "~/Org/journal/"
        org-journal-date-format "%B %d, %Y (%A) "
        org-journal-file-format "%d.%m.%Y.org"
        ;; org-hide-emphasis-markers t
        ;; ex. of org-link-abbrev-alist in action
        ;; [[arch-wiki:Name_of_Page][Description]]
        org-link-abbrev-alist    ; This overwrites the default Doom org-link-abbrev-list
          '(("google" . "http://www.google.com/search?q=")
            ("arch-wiki" . "https://wiki.archlinux.org/index.php/")
            ("ddg" . "https://duckduckgo.com/?q=")
            ("wiki" . "https://en.wikipedia.org/wiki/"))
        org-todo-keywords        ; This overwrites the default Doom org-todo-keywords
          '((sequence
             "TODO(t)"           ; A task that is ready to be tackled
             "BLOG(b)"           ; Blog writing assignments
             "PROJ(p)"           ; A project that contains other tasks
             "VIDEO(v)"          ; Video assignments
             "WAIT(w)"           ; Something is holding up this task
             "|"                 ; The pipe necessary to separate "active" states and "inactive" states
             "DONE(d)"           ; Task has been completed
             "CANCELLED(c)" )))) ; Task has been cancelled

(use-package ox-man) ; Export to Manpage format
(use-package ox-gemini) ; Export to Gemini

;; Elfeed
(use-package! elfeed-goodies)
(elfeed-goodies/setup)
  (setq elfeed-goodies/entry-pane-size 0.5)
(add-hook 'elfeed-show-mode-hook 'visual-line-mode)
(evil-define-key 'normal elfeed-show-mode-map
  (kbd "J") 'elfeed-goodies/split-show-next
  (kbd "K") 'elfeed-goodies/split-show-prev)
(evil-define-key 'normal elfeed-search-mode-map
  (kbd "J") 'elfeed-goodies/split-show-next
  (kbd "K") 'elfeed-goodies/split-show-prev)
(setq elfeed-feeds (quote
                    (
;;                     ("https://www.reddit.com/r/linux.rss" reddit linux)
;;                     ("https://www.reddit.com/r/commandline.rss" reddit commandline)
;;                     ("https://www.reddit.com/r/distrotube.rss" reddit linux distrotube)
;;                     ("https://www.reddit.com/r/emacs.rss" reddit linux emacs)
                     )))

;; Theme
(setq doom-theme 'doom-dracula)

;; Editor tweaks
(setq display-line-numbers-type t)

;; Indent using 2 spaces
(setq tab-stop-list (number-sequence 2 200 2))

;; Move between splits using SHIFT and the arrow keys
(windmove-default-keybindings)
(setq org-replace-disputed-keys t)

(add-to-list 'default-frame-alist '(alpha . (98 . 98)))
