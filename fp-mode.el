;; ----- Keywords -----
(defvar flagpole-keywords
  '("if" "then" "endif" "proc" "endproc" "return" "while" "then" "endwhile" "do" "$extern" "$inc")
  "List of Flagpole keywords.")

(defvar flagpole-builtin
  '("drop" "dup" "swap" "i+" "i-" "==" "i>" "i<" "i*" "i/" "not" "~" "ld8" "ld16" "ld32" "ld64" "st8" "st16" "st32" "st64")
  "List of Flagpole builtins (operators or built-in words).")

(defun flagpole-get-font-lock-keywords ()
  "Return font-lock rules for Flagpole mode."
  `(
    ;; Keywords
    (,(regexp-opt flagpole-keywords 'words) . font-lock-keyword-face)
    ;; Numbers
    ("\\b[0-9]+\\b" . font-lock-constant-face)
    ;; Builtins / operators
    (,(regexp-opt flagpole-builtin) . font-lock-builtin-face)
    ))

;; ----- Major Mode -----
(define-derived-mode flagpole-mode prog-mode "Flagpole"
  "Major mode for Flagpole files."
  (setq font-lock-defaults `(,(flagpole-get-font-lock-keywords) nil nil)))

;; ----- File Association -----
(add-to-list 'auto-mode-alist '("\\.fp\\'" . flagpole-mode))
