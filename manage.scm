#!/usr/bin/env gosh

(use file.util)
(use srfi.13)

;; --- Target Config Files ---
(define *dotfiles*
  ;; (dotfiles-name source-path tag ...)
  ;; tags:
  ;;   optional -- ask whether to install it (y/n) on `install`
  '(("emacs_init.el"        ".emacs.d/init.el")
    ("nvim"                 ".config/nvim")
    ("tmux.conf"            ".tmux.conf")
    ("config.fish"          ".config/fish/config.fish"          optional)
    ("foot.ini"             ".config/foot/foot.ini"             optional)
    ("zshrc"                ".zshrc")
    ("macskk_dict"          "Library/Containers/net.mtgto.inputmethod.macSKK/Data/Documents/Dictionaries/skk-jisyo.utf8"   optional)
    ("skk_user.dict"        ".local/share/fcitx5/skk/user.dict" optional)))


(define *dotfiles-dir* (string-append (current-directory) "/"))
(define *home-dir* (string-append (home-directory) "/"))

(define (dotfile-name entry) (car entry))
(define (dotfile-origin entry) (cadr entry))
(define (dotfile-tags entry) (cddr entry))
(define (optional? entry) (memq 'optional (dotfile-tags entry)))

;; Ask a yes/no question. Empty input or EOF means "no".
(define (ask-yes-no? question)
  (display #"~|question| [y/N]: ")
  (flush)
  (let ((line (read-line)))
    (cond ((eof-object? line) (newline) #f)
          ((member (string-downcase line) '("y" "yes")) #t)
          ((member (string-downcase line) '("" "n" "no")) #f)
          (else (ask-yes-no? question)))))

(define (remove-path path)
  (cond ((file-is-symlink? path) (sys-unlink path))
        ((file-is-directory? path) (remove-directory* path))
        ((file-exists? path) (sys-unlink path))))

;; Directories are replaced as a whole, so files deleted in src also disappear from dst.
;; Copy to a temporary path first to keep dst intact if the copy fails.
(define (replace-directory src dst)
  (let ((tmp (string-append dst ".manage-tmp")))
    (remove-path tmp)
    (copy-directory* src tmp)
    (remove-path dst)
    (move-file tmp dst)))

(define (copy-path src dst)
  (create-directory* (sys-dirname dst))
  (if (file-is-directory? src)
      (replace-directory src dst)
      (copy-file src dst :if-exists :supersede)))

(define (copy-config-files operation-type)
  (dolist (entry *dotfiles*)
    (let* ((repo-path (string-append *dotfiles-dir* (dotfile-name entry)))
           (origin-path (string-append *home-dir* (dotfile-origin entry)))
           (src (if (eq? operation-type 'install) repo-path origin-path))
           (dst (if (eq? operation-type 'install) origin-path repo-path)))
      (cond ((not (file-exists? src))
             ;; Keep dst untouched when the source doesn't exist in this environment
             (print #"skip: ~src (not found)"))
            ((and (eq? operation-type 'install)
                  (optional? entry)
                  (not (ask-yes-no? #"install ~(dotfile-name entry) -> ~dst ?")))
             (print #"skip: ~(dotfile-name entry)"))
            (else
             (copy-path src dst)
             (print #"~src -> ~dst"))))))


(define (main args)
  (let ((cmd (if (null? (cdr args)) "" (cadr args))))
    (cond ((string=? cmd "install") (copy-config-files 'install) 0)
	  ((string=? cmd "collect") (copy-config-files 'collect) 0)
	  (else (print "Usage: gosh manage.scm [install|collect]") 1))))
