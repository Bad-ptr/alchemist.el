;;; alchemist-compile.el --- Elixir's compile integration

;; Copyright © 2014 Samuel Tonini

;; Author: Samuel Tonini <tonini.samuel@gmail.com

;; This program is free software: you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;; This file is not part of GNU Emacs.

;;; Commentary:

;;; Code:

(defcustom alchemist-compile-command "elixirc"
  "The shell command for elixirc."
  :type 'string
  :group 'alchemist-compile)

(defvar alchemist-compile-buffer-name "*elixirc*"
  "Name of the elixir output buffer.")

(defun alchemist-compile-this-buffer ()
  "Run the current buffer through elixirc."
  (interactive)
  (alchemist-compile--file buffer-file-name))

(defun alchemist-compile-file (filename)
  "Run elixir with the given `FILENAME`."
  (interactive "Felixirc: ")
  (alchemist-compile--file (expand-file-name filename)))

(defun alchemist-compile--file (filename)
  (when (not (file-exists-p filename))
    (error "The given file doesn't exists"))
  (alchemist-compile-run (list alchemist-compile-command (expand-file-name filename))))

(defun alchemist-compile--read-command (command)
  (read-shell-command "elixirc command: " (concat command " ")))

(defun alchemist-compile-run (cmdlist)
  "Run a elixir with `CMDLIST`."
  (interactive (list (alchemist-compile--read-command alchemist-compile-command)))
  (alchemist-buffer-run (alchemist-utils--build-runner-cmdlist cmdlist)
                        alchemist-compile-buffer-name))

(provide 'alchemist-compile)

;;; alchemist-compile.el ends here
