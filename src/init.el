
(setq org-agenda-files (directory-files-recursively "~/Nextcloud/Org/" "\\.org$"))
(require 'org)

(global-set-key (kbd "<f12>") 'org-agenda)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-cb" 'org-iswitchb)


(setq org-directory "~/Nextcloud/Org")
(setq org-default-notes-file "~/Nextcloud/Org/refile.org")

;; I use C-c c to start capture mode
(global-set-key (kbd "C-c c") 'org-capture)

;; Capture templates for: TODO tasks, Notes, appointments, phone calls, meetings, and org-protocol
(setq org-capture-templates
      (quote (("t" "todo" entry (file "~/Nextcloud/Org/refile.org")
               "* TODO %?\n%U\n%a\n" :clock-in t :clock-resume t)
              ("r" "respond" entry (file "~/Nextcloud/Org/refile.org")
               "* NEXT Respond to %:from on %:subject\nSCHEDULED: %t\n%U\n%a\n" :clock-in t :clock-resume t :immediate-finish t)
              ("n" "note" entry (file "~/Nextcloud/Org/refile.org")
               "* %? :NOTE:\n%U\n%a\n" :clock-in t :clock-resume t)
              ("j" "Journal" entry (file+datetree "~/Nextcloud/Org/diary.org")
               "* %?\n%U\n" :clock-in t :clock-resume t)
              ("w" "org-protocol" entry (file "~/Nextcloud/Org/refile.org")
               "* TODO Review %c\n%U\n" :immediate-finish t)
              ("m" "Meeting" entry (file "~/Nextcloud/Org/refile.org")
               "* MEETING with %? :MEETING:\n%U" :clock-in t :clock-resume t)
              ("p" "Phone call" entry (file "~/Nextcloud/Org/refile.org")
               "* PHONE %? :PHONE:\n%U" :clock-in t :clock-resume t)
              ("h" "Habit" entry (file "~/Nextcloud/Org/refile.org")
               "* NEXT %?\n%U\n%a\nSCHEDULED: %(format-time-string \"%<<%Y-%m-%d %a .+1d/3d>>\")\n:PROPERTIES:\n:STYLE: habit\n:REPEAT_TO_STATE: NEXT\n:END:\n"))))

(load-theme 'solarized-dark t)

(require 'neotree)
(global-set-key [f8] 'neotree-toggle)

(require 'nix-mode)
(add-to-list 'auto-mode-alist '("\\.nix\\'" . nix-mode))

(require 'evil)
(evil-mode 1)

(autoload 'go-mode "go-mode" nil t)
(add-to-list 'auto-mode-alist '("\\.go\\'" . go-mode))

(require 'yaml-mode)
(add-to-list 'auto-mode-alist '("\\.yml\\'" . yaml-mode))
(add-to-list 'auto-mode-alist '("\\.yaml\\'" . yaml-mode))

(add-hook 'after-init-hook 'global-company-mode)

;(require 'company-tabnine)
;(add-to-list 'company-backends #'company-tabnine)

;; Trigger completion immediately.
(setq company-idle-delay 0)

;; Number the candidates (use M-1, M-2 etc to select completions).
(setq company-show-numbers t)

(require 'dockerfile-mode)
(add-to-list 'auto-mode-alist '("\\Dockerfile\\'" . dockerfile-mode))

(global-set-key (kbd "<f5>") #'deadgrep)

;; Disable evil in term mode (e.g. fixes C-r in zsh)
(evil-set-initial-state 'term-mode 'emacs)

(custom-set-faces
 '(default ((t (:family "Cozette" :foundry "slavfox" :slant normal :weight normal :height 98 :width normal)))))
