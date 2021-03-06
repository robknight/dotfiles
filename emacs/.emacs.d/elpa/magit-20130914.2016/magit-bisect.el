;;; magit-bisect.el --- bisect support for Magit

;; Copyright (C) 2011-2013  The Magit Project Developers.
;;
;; For a full list of contributors, see the AUTHORS.md file
;; at the top-level directory of this distribution and at
;; https://raw.github.com/magit/magit/master/AUTHORS.md

;; Author: Moritz Bunkus <moritz@bunkus.org>
;; Package: magit

;; Magit is free software; you can redistribute it and/or modify it
;; under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; Magit is distributed in the hope that it will be useful, but WITHOUT
;; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
;; or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public
;; License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with Magit.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Control git-bisect from Magit.

;;; Code:

(require 'magit)

(defvar-local magit--bisect-last-pos nil)
(put 'magit--bisect-info 'permanent-local t)

(defvar-local magit--bisect-info nil)
(put 'magit--bisect-info 'permanent-local t)

(defun magit--bisecting-p (&optional required-status)
  "Return t if a bisect session is running.
If REQUIRED-STATUS is not nil then the current status must also
match REQUIRED-STATUS."
  (and (file-exists-p (magit-git-dir "BISECT_LOG"))
       (or (not required-status)
           (eq (plist-get (magit--bisect-info) :status)
               required-status))))

(defun magit--bisect-info ()
  (with-current-buffer (magit-find-status-buffer)
    (or (and (local-variable-p 'magit--bisect-info) magit--bisect-info)
        (list :status (if (magit--bisecting-p) 'running 'not-running)))))

(defun magit--bisect-cmd (&rest args)
  "Run `git bisect ...' and update the status buffer."
  (with-current-buffer (magit-find-status-buffer)
    (let* ((output (apply 'magit-git-lines (append '("bisect") args)))
           (cmd (car args))
           (first-line (car output)))
      (save-match-data
        (setq magit--bisect-info
              (cond ((string= cmd "reset")
                     (list :status 'not-running))
                    ;; Bisecting: 78 revisions left to test after this (roughly 6 steps)
                    ((string-match "^Bisecting:\\s-+\\([0-9]+\\).+roughly\\s-+\\([0-9]+\\)"
                                   first-line)
                     (list :status 'running
                           :revs (match-string 1 first-line)
                           :steps (match-string 2 first-line)))
                    ;; e2596955d9253a80aec9071c18079705597fa102 is the first bad commit
                    ((string-match "^\\([a-f0-9]+\\)\\s-.*first bad commit" first-line)
                     (list :status 'finished
                           :bad (match-string 1 first-line)))
                    (t
                     (list :status 'error)))))))
  (magit-refresh))

(defun magit--bisect-info-for-status ()
  "Return bisect info suitable for display in the status buffer."
  (let ((info (magit--bisect-info)))
    (cl-case (plist-get info :status)
      (running
       (format "(bisecting; %s revisions & %s steps left)"
               (or (plist-get info :revs) "unknown number of")
               (or (plist-get info :steps) "unknown number of")))
      (finished
       (format "(bisected: first bad revision is %s)" (plist-get info :bad)))
      (t
       "(bisecting; unknown error occured)"))))

(defun magit-bisect-start ()
  "Start a bisect session."
  (interactive)
  (when (magit--bisecting-p)
    (error "Already bisecting"))
  (let ((bad (magit-read-rev "Start bisect with known bad revision" "HEAD"))
        (good (magit-read-rev "Good revision" (magit-default-rev))))
    (magit--bisect-cmd "start" bad good)))

(defun magit-bisect-reset ()
  "Quit a bisect session."
  (interactive)
  (unless (magit--bisecting-p)
    (error "Not bisecting"))
  (magit--bisect-cmd "reset"))

(defun magit-bisect-good ()
  "Tell git that the current revision is good during a bisect session."
  (interactive)
  (unless (magit--bisecting-p 'running)
    (error "Not bisecting"))
  (magit--bisect-cmd "good"))

(defun magit-bisect-bad ()
  "Tell git that the current revision is bad during a bisect session."
  (interactive)
  (unless (magit--bisecting-p 'running)
    (error "Not bisecting"))
  (magit--bisect-cmd "bad"))

(defun magit-bisect-skip ()
  "Tell git to skip the current revision during a bisect session."
  (interactive)
  (unless (magit--bisecting-p 'running)
    (error "Not bisecting"))
  (magit--bisect-cmd "skip"))

(defun magit-bisect-log ()
  "Show the bisect log."
  (interactive)
  (unless (magit--bisecting-p)
    (error "Not bisecting"))
  (magit-run-git "bisect" "log")
  (magit-display-process))

(defun magit-bisect-visualize ()
  "Show the remaining suspects with gitk."
  (interactive)
  (unless (magit--bisecting-p)
    (error "Not bisecting"))
  (magit-run-git "bisect" "visualize")
  (unless (getenv "DISPLAY")
    (magit-display-process)))

(easy-mmode-defmap magit-bisect-minibuffer-local-map
  '(("\C-i" . comint-dynamic-complete-filename))
  "Keymap for minibuffer prompting of rebase command."
  :inherit minibuffer-local-map)

(defvar magit-bisect-mode-history nil
  "Previously run bisect commands.")

(defun magit-bisect-run (command)
  "Bisect automatically by running commands after each step."
  (interactive
   (list
    (read-from-minibuffer "Run command (like this): "
                          ""
                          magit-bisect-minibuffer-local-map
                          nil
                          'magit-bisect-mode-history)))
  (unless (magit--bisecting-p)
    (error "Not bisecting"))
  (let ((file (magit-git-dir "magit-bisect-run"))
        process buffer)
    (with-temp-buffer
      (insert "#!/bin/sh\n" command "\n")
      (write-region (point-min) (point-max) file))
    (set-file-modes file #o755)
    (setq process (magit-run-git-async "bisect" "run" file)
          buffer  (process-buffer process))
    (magit-display-process)
    (with-current-buffer buffer
      (setq magit--bisect-last-pos 0))
    (set-process-filter process 'magit--bisect-run-filter)
    (set-process-sentinel process
                          (apply-partially 'magit--bisect-run-sentinel
                                           buffer))))

(defun magit--bisect-run-filter (process output)
  (with-current-buffer (process-buffer process)
    (save-match-data
      (let ((inhibit-read-only t)
            line new-info)
        (insert output)
        (goto-char magit--bisect-last-pos)
        (beginning-of-line)
        (while (< (point) (point-max))
          (cond
           ( ;; Bisecting: 78 revisions left to test after this (roughly 6 steps)
            (looking-at "^Bisecting:\\s-+\\([0-9]+\\).+roughly\\s-+\\([0-9]+\\)")
            (setq new-info (list :status 'running
                                 :revs (match-string 1)
                                 :steps (match-string 2))))
           ( ;; e2596955d9253a80aec9071c18079705597fa102 is the first bad commit
            (looking-at "^\\([a-f0-9]+\\)\\s-.*first bad commit")
            (setq new-info (list :status 'finished
                                 :bad (match-string 1)))))
          (forward-line 1))
        (goto-char (point-max))
        (setq magit--bisect-last-pos (point))
        (when new-info
          (with-current-buffer (magit-find-status-buffer)
            (setq magit--bisect-info new-info)
            (save-excursion
              (let ((inhibit-read-only t))
                (goto-char (point-min))
                (when (re-search-forward "^Local:" nil t)
                  (beginning-of-line)
                  (kill-line)
                  (magit-insert-status-local-line))))))))))

(defun magit--bisect-run-sentinel (command-buf process event)
  (when (string-match-p "^finish" event)
    (with-current-buffer (process-buffer process)
      (delete-file (magit-git-dir "magit-bisect-run"))))
  (magit-process-sentinel command-buf process event))

(provide 'magit-bisect)
;;; magit-bisect.el ends here
