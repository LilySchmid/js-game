(ql:quickload "cl-glu")
(ql:quickload "cl-glfw3")
(ql:quickload "alexandria")

(defparameter *my-error-log* nil)
(defparameter *my-main-window* nil)
(defparameter *update-queue* nil)

(declaim (optimize (debug 3) (safety 3) (speed 1) (space 0)))
;(declaim (optimize (speed 3) (space 2) (debug 0) (safety 0)))

(defun hash-keys (table)
  (loop for key being the hash-keys of table collect key))

(defun hash-values (table)
  (loop for key in (hash-keys table)
		  collect (gethash key table)))

(load "maps.lisp")
(load "tiles.lisp")
(load "agents.lisp")
(load "input.lisp")
(load "graphics.lisp")

(defun initialize-game ()
  (setf *my-error-log* (open "error.log" :direction :output :if-exists :supersede))
  (initialize-agent :player)
  (initialize-agent :item)
  (initialize-agent :item)
  (initialize-agent :enemy)
  (initialize-agent :enemy)
  (initialize-agent :enemy)
  (initialize-main-window))

(defun update ()
  (update-agents *update-queue*)
  (dolist (visible-tile (hash-keys (agent-visible-tiles (get-player))))
	 (let ((y-offset (nth 0 visible-tile))
			 (x-offset (nth 1 visible-tile)))
		(set-tile-memory y-offset x-offset (get-tile-value y-offset x-offset))))
  (setf *update-queue* nil))

(defun close-down ()
  (close *my-error-log*)
  (close-glfw-and-window))

(defun run-game (main-window)
  (unless (%glfw:window-should-close-p main-window)
	 (input-processing)
	 (if *update-queue*
		(update)
		(compute-vision (get-player)))
	 (render (agent-location (get-player)))
	 (run-game main-window)))

(defun start ()
  (load "game.lisp")
  (let ((main-window (initialize-game)))
	 (setf *my-main-window* main-window)
	 (run-game main-window))
  (close-down))
