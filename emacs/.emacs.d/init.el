;; add the locations of emacs-org/ other extenstions
(add-to-list 'load-path "~/.emacs.d/")
(package-initialize)
(when (not (require 'org nil t))
  (package-install 'org))
;; set-up org babel
(setq org-babel-load-languages '((emacs-lisp . t)))
(setq org-confirm-babel-evaluate nil)
(require 'org-install)
(require 'org)

;; load neatly organized org file!
(org-babel-load-file "~/.emacs.d/emacs-config.org")
