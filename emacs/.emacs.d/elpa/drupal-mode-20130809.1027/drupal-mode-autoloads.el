;;; drupal-mode-autoloads.el --- automatically extracted autoloads
;;
;;; Code:


;;;### (autoloads (drupal-mode-bootstrap drupal-mode drupal-info-modes
;;;;;;  drupal-js-modes drupal-css-modes drupal-php-modes drupal-drush-program)
;;;;;;  "drupal-mode" "drupal-mode.el" (21044 63038))
;;; Generated autoloads from drupal-mode.el

(put 'drupal-search-url 'safe-local-variable 'string-or-null-p)

(defvar drupal-drush-program (executable-find "drush") "\
Name of the Drush executable.
Include path to the executable if it is not in your $PATH.")

(custom-autoload 'drupal-drush-program "drupal-mode" t)

(defvar drupal-php-modes (list 'php-mode 'php+-mode 'web-mode) "\
Major modes to consider PHP in Drupal mode.")

(custom-autoload 'drupal-php-modes "drupal-mode" t)

(defvar drupal-css-modes (list 'css-mode) "\
Major modes to consider CSS in Drupal mode.")

(custom-autoload 'drupal-css-modes "drupal-mode" t)

(defvar drupal-js-modes (list 'javascript-mode 'js-mode 'js2-mode) "\
Major modes to consider JavaScript in Drupal mode.")

(custom-autoload 'drupal-js-modes "drupal-mode" t)

(defvar drupal-info-modes (list 'conf-windows-mode) "\
Major modes to consider info files in Drupal mode.")

(custom-autoload 'drupal-info-modes "drupal-mode" t)

(autoload 'drupal-mode "drupal-mode" "\
Advanced minor mode for Drupal development.

\\{drupal-mode-map}

\(fn &optional ARG)" t nil)

(autoload 'drupal-mode-bootstrap "drupal-mode" "\
Activate Drupal minor mode if major mode is supported.
The command will activate `drupal-mode' if the current major mode
is a mode supported by `drupal-mode' (currently only
`php-mode').

The function is suitable for adding to the supported major modes
mode-hook.

\(fn)" nil nil)

(dolist (mode (append drupal-php-modes drupal-css-modes drupal-js-modes drupal-info-modes)) (when (intern (concat (symbol-name mode) "-hook")) (add-hook (intern (concat (symbol-name mode) "-hook")) #'drupal-mode-bootstrap)))

(add-to-list 'auto-mode-alist '("[^/]\\.\\(module\\|test\\|install\\|profile\\|tpl\\.php\\|theme\\|inc\\)\\'" . php-mode))

(add-to-list 'auto-mode-alist '("[^/]\\.info\\'" . conf-windows-mode))

(eval-after-load 'pcomplete '(require 'drupal/pcomplete))

(eval-after-load 'webjump '(require 'drupal/webjump))

;;;***

;;;### (autoloads (drush-make-mode) "drush-make-mode" "drush-make-mode.el"
;;;;;;  (21044 63038))
;;; Generated autoloads from drush-make-mode.el

(autoload 'drush-make-mode "drush-make-mode" "\
A major mode for editing drush make files.

\\{drush-make-mode-map}

\(fn)" t nil)

(add-to-list 'auto-mode-alist '("[^/]\\.make\\'" . drush-make-mode))

;;;***

;;;### (autoloads nil nil ("drupal-mode-pkg.el") (21044 63038 86134))

;;;***

(provide 'drupal-mode-autoloads)
;; Local Variables:
;; version-control: never
;; no-byte-compile: t
;; no-update-autoloads: t
;; coding: utf-8
;; End:
;;; drupal-mode-autoloads.el ends here
