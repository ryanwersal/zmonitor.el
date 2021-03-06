;; vars
(defvar zmonitor-port 31415
  "Port to listen for logs on.")

(defvar zmonitor-buffer-name "*zmonitor*"
  "Name of the zmonitor buffer.")

(defvar zmonitor-process-name "zmonitor"
  "Name of the zmonitor process.")

;; faces
(defface zmonitor-debug-face
  '((default :foreground "green"))
  "Face used for debug keywords.")

(defface zmonitor-info-face
  '((default :foreground "blue"))
  "Face used for info keywords.")

(defface zmonitor-warn-face
  '((default :foreground "yellow"))
  "Face used for warn keywords.")

(defface zmonitor-error-face
  '((default :foreground "red"))
  "Face used for error keywords.")

(defface zmonitor-critical-face
  '((default :foreground "black")
	(((class color) (min-colors 88) (background light))
	 :background "red")
	(((class color) (min-colors 88) (background dark))
	 :background "red"))
  "Face used for critical keywords.")

;; defuns
(defun zmonitor-start ()
  (interactive)
  (unless (process-status zmonitor-process-name)
	(make-network-process :name zmonitor-process-name :buffer zmonitor-buffer-name
						  :server 't :family 'ipv4 :service zmonitor-port
						  :filter 'zmonitor-filter))
  (with-current-buffer zmonitor-buffer-name
	(read-only-mode)
	(zmonitor-mode 1))
  (display-buffer zmonitor-buffer-name display-buffer--same-window-action))

(defun zmonitor-stop ()
  (interactive)
  (let ((proc zmonitor-process-name))
	(if (process-status proc)
		(delete-process proc))
	(kill-buffer zmonitor-buffer-name)))

(defun zmonitor-restart ()
  (interactive)
  (zmonitor-stop)
  (zmonitor-start))

(defun zmonitor-filter (proc string)
  (let ((buff zmonitor-buffer-name))
	(if (get-buffer buff)
		(zmonitor-append-to-buffer buff string))))

(defun zmonitor-append-to-buffer (buffer string)
  (let ((win (get-buffer-window buffer))
		(inhibit-read-only t))
	(if (eq win nil)
		(with-current-buffer buffer
		  (goto-char (point-max))
		  (insert string))
	  (with-selected-window
		  (get-buffer-window buffer)
		(goto-char (point-max))
		(insert string)))))

;;;###autoload
(define-minor-mode zmonitor-mode
  "Font locks and provides additional features for the zmonitor buffer."
  :lighter " zmonitor"
  (font-lock-mode)
  (font-lock-add-keywords nil '(("debug:" . 'zmonitor-debug-face)
								("info:" . 'zmonitor-info-face)
								("warn:" . 'zmonitor-warn-face)
								("error:" . 'zmonitor-error-face)
								("critical:" . 'zmonitor-critical-face))))

(provide 'zmonitor)
