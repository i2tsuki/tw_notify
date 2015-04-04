;;; package --- notify new tweets for twittering-mode.

;;; code:
(defun my-twmode-growl-notify ()
  (when (equal twittering-new-tweets-spec
	       '(home))
    (mapc (lambda (status)
	    (my-twmode-growl-notify-1 (cdr (assq 'user-screen-name status))
				      (cdr (assq 'text status))
				      (cdr (assq 'user-profile-image-url status))
				      twittering-new-tweets-spec))
	  twittering-new-tweets-statuses)))
(defvar twmode-growl-notify-icon-path-directory "/tmp/twmode/")
  (defun my-twmode-growl-notify-1 (user text icon-uri spec)
    (cond
     ((and (or (equal spec '(home)) (equal spec '(replies)))
	   (not (string= user twittering-username)))
      (mkdir twmode-growl-notify-icon-path-directory t)
      (with-temp-buffer
	(setq icon-base (expand-file-name
			 (sha1 icon-uri)
			 twmode-growl-notify-icon-path-directory))
	(if (not (file-exists-p icon-base))
	    (call-process-shell-command (concat "wget -O" icon-base " " icon-uri)))
	(insert "@" user "\n" text)
	(setq notification (concatenate 'string "@" user ": " text))
	(call-process-region (point-min) (point-max) "/usr/bin/notify-send" nil t nil "TWmode:: timeline" notification "-i" icon-base "-t" "9000")
	))))
(add-hook 'twittering-new-tweets-hook
	  'my-twmode-growl-notify)
