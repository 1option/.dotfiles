;;; theme_rc.el --- -*- lexical-binding: t -*-
;;  Author: Maksim Rozhkov
;;; Commentary:
;;  This is my theme configuration
;;; Code:

;; GUI theme
(defun bb/system-dark-mode-enabled-p ()
  "Check if dark mode is currently enabled."
  (pcase system-type
    ('darwin
     ;; Have to use osascript here as defaults returns inconsistent results
     ;; - AppleInterfaceStyleSwitchesAutomatically == 1 ;; exists only if the theme is set to auto
     ;; - AppleInterfaceStyle == Dark ;; exists only if the theme is set to dark
     ;; How to determine if theme is light or dark when Automatic Theme switching is in place?
     ;; Luckily, osascript can provide that detail
     (if (string= (shell-command-to-string "printf %s \"$( osascript -e \'tell application \"System Events\" to tell appearance preferences to return dark mode\' )\"") "true") t))
    ('gnu/linux
     ;; prefer-dark and default are possible options
     (if (string= (shell-command-to-string "gsettings get org.gnome.desktop.interface color-scheme") "\'prefer-dark\'\n") t))))

(defun bb/set-emacs-frames (variant)
  "Set GTK theme for Emacs; VARIANT=theme."
  (dolist (frame (frame-list))
    (let* ((window-id (frame-parameter frame 'outer-window-id))
	   (id (string-to-number window-id))
	   (cmd (format "xprop -id 0x%x -f _GTK_THEME_VARIANT 8u -set _GTK_THEME_VARIANT \"%s\""
			id variant)))
      (call-process-shell-command cmd))))

(defun bb/set-modus-theme ()
  "Load dark/light variant depending on the system theme."
  (interactive)
  (if (bb/system-dark-mode-enabled-p)
      (progn
	(modus-themes-load-vivendi)
	(bb/set-emacs-frames "dark"))
    (progn
      (modus-themes-load-operandi)
      (bb/set-emacs-frames "light"))))

(defun bb/toggle-theme ()
  "Toggle between modus-operandi and modus-vivendi with GTK frame colors."
  (interactive)
  (if (eq (car custom-enabled-themes) 'modus-vivendi)
      (progn
	(disable-theme 'modus-vivendi)
	(bb/set-emacs-frames "light"))
    (progn
      (load-theme 'modus-vivendi t)
      (bb/set-emacs-frames "dark"))))

;; Standard detect (GTK_THEME=light/dark)
;; (bb/set-modus-theme)

;; Manual
(bb/set-emacs-frames "light")
(load-theme 'modus-operandi t)

(define-key global-map (kbd "<f12>") #'bb/toggle-theme)

(with-eval-after-load "modus-themes"
  (with-eval-after-load "mlscroll"
    (defun ct/modus-themes-mlscroll-colors ()
      ('modus-themes-with-colors
        (customize-set-variable 'mlscroll-in-color "#0a84ff")
        (customize-set-variable 'mlscroll-out-color "black")))
    (add-hook 'modus-themes-after-load-theme-hook #'ct/modus-themes-mlscroll-colors)))

(provide 'theme_rc)
;;; theme_rc.el ends here
