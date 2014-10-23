;;; alchemist-buffer.el --- Define a custom compilation mode for Elixir executions

;;; Commentary:
;;

(require 'compile)
(require 'ansi-color)

(defvar alchemist-buffer--buffer-name nil
  "Used to store compilation name so recompilation works as expected.")
(make-variable-buffer-local 'alchemist-buffer--buffer-name)

(defvar alchemist-buffer--error-link-options
  '(elixir "\\([a-z./_]+\\):\\([0-9]+\\)\\(: warning\\)?" 1 2 nil (3) 1)
  "File link matcher for `compilation-error-regexp-alist-alist' (matches path/to/file:line).")

(defun alchemist-buffer--kill-any-orphan-proc ()
  "Ensure any dangling buffer process is killed."
  (let ((orphan-proc (get-buffer-process (buffer-name))))
    (when orphan-proc
      (kill-process orphan-proc))))

(define-compilation-mode alchemist-buffer-mode "Elixir"
  "Elixir compilation mode."
  (progn
    (font-lock-add-keywords nil
                            '(("^Finished in .*$" . font-lock-string-face)
                              ("^Elixir.*$" . font-lock-string-face)))
    ;; Set any bound buffer name buffer-locally
    (setq alchemist-buffer--buffer-name alchemist-buffer--buffer-name)
    (set (make-local-variable 'kill-buffer-hook)
         'alchemist-buffer--kill-any-orphan-proc)))

(defvar alchemist-buffer--save-buffers-predicate
  (lambda ()
    (not (string= (substring (buffer-name) 0 1) "*"))))

(defun alchemist-buffer--handle-compilation-once ()
  (remove-hook 'compilation-filter-hook 'alchemist-buffer--handle-compilation-once t)
  (delete-matching-lines "\\(-*- mode:\\|elixir-compilation;\\|Elixir started\\|^$\\)" (point-min) (point)))

(defun alchemist-buffer--handle-compilation ()
  (ansi-color-apply-on-region compilation-filter-start (point)))

(defun alchemist-buffer-run (cmdlist buffer-name)
  "run CMDLIST in `alchemist-buffer-mode'.
Returns the compilation buffer."
  (save-some-buffers (not compilation-ask-about-save) alchemist-buffer--save-buffers-predicate)

  (let* ((alchemist-buffer--buffer-name buffer-name)
         (compilation-filter-start (point-min)))
    (with-current-buffer
        (compilation-start (mapconcat 'shell-quote-argument cmdlist " ")
                           'alchemist-buffer-mode
                           (lambda (b) alchemist-buffer--buffer-name))
      (setq-local compilation-error-regexp-alist-alist
                  (cons alchemist-buffer--error-link-options compilation-error-regexp-alist-alist))
      (setq-local compilation-error-regexp-alist (cons 'elixir compilation-error-regexp-alist))
      (add-hook 'compilation-filter-hook 'alchemist-buffer--handle-compilation nil t)
      (add-hook 'compilation-filter-hook 'alchemist-buffer--handle-compilation-once nil t))))

(provide 'alchemist-buffer)

;;; alchemist-buffer.el ends here
