#lang typed/racket/base

(require racket/path)

(require "../engine.rkt")

(require "../../exec.rkt")

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define latex-post-exec : Tex-Post-Exec
  (lambda [func-name TEXNAME.pdf]
    (define-values (dvips ps2pdf) (values 'dvips 'pstopdf))
    (define TEXNAME.dvi : Path (path-replace-extension TEXNAME.pdf #".dvi"))
    (define TEXNAME.ps : Path (path-replace-extension TEXNAME.pdf #".ps"))
    (define /bin/dvips : (Option Path) (tex-find-binary-path dvips))
    (define /bin/ps2pdf : (Option Path) (tex-find-binary-path ps2pdf))

    (cond [(not /bin/dvips)  (raise-user-error func-name "cannot find `~a`" dvips)]
          [(not /bin/ps2pdf) (raise-user-error func-name "cannot find `~a`" ps2pdf)]
          [else (parameterize ([current-directory (or (path-only TEXNAME.pdf) (current-directory))])
                  (fg-recon-exec func-name /bin/dvips (list (list (path->string TEXNAME.dvi))) #:silent '(stderr))
                  (fg-recon-exec func-name /bin/ps2pdf (list (list (path->string TEXNAME.ps))) #:silent '(stderr)))])

    TEXNAME.pdf))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(module+ register
  (require "../tex.rkt")
  
  (tex-register-engine 'latex #:draftmode "-draftmode" #:post-exec latex-post-exec)
  (tex-register-engine 'pdflatex #:draftmode "-draftmode"))
