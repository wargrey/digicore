#lang typed/racket

(provide (all-defined-out))

(require racket/path)
(require racket/symbol)

(require digimon/archive)
(require digimon/digitama/bintext/zipinfo)

(require digimon/cmdopt)
(require digimon/format)
(require digimon/date)

(require digimon/echo)
(require digimon/debug)
(require digimon/dtrace)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define-cmdlet-option zipinfo-flags #: ZipInfo-Flags
  #:program 'zipinfo
  #:args [file.zip]

  #:once-each
  [[(#\A)                    "list all entries, including those not in the central directory"]

   [(#\h)                    "display the header line"]
   [(#\t)                    "display the trailer line"]
   [(#\z)                    "display file comment"]

   [(#\T)                    "print the file dates and times in the sortable decimal format"]
   [(#\v)   #:=> zip-verbose "run with verbose messages"]]

  #:once-any
  [[(#\1)                    "list filenames only"]
   [(#\2)                    "list filenames, but allow other information"]
   [(#\s)                    "list zip info with short format"]
   [(#\m)                    "list zip info with medium format"]
   [(#\l)                    "list zip info with long format"]])

(define zip-verbose : (Parameterof Boolean) (make-parameter #false))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define main : (-> (U (Listof String) (Vectorof String)) Nothing)
  (lambda [argument-list]
    (define-values (options λargv) (parse-zipinfo-flags argument-list #:help-output-port (current-output-port)))

    (define file.zip : String (λargv))

    (parameterize ([current-logger /dev/dtrace]
                   [pretty-print-columns 160]
                   [date-display-format 'iso-8601])
      (exit (time** (let ([tracer (thread (make-zip-log-trace))])
                      (with-handlers ([exn:fail? (λ [[e : exn:fail]] (dtrace-exception e #:brief? #false))])
                        (zipinfo options file.zip))
                      (dtrace-sentry-notice #:end? #true eof "")
                      (thread-wait tracer)))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define make-zip-log-trace : (-> (-> Void))
  (lambda []
    (make-dtrace-loop (if (zip-verbose) 'trace 'info))))

(define zip-entry-info : (-> (U ZIP-Directory ZIP-File) ZipInfo-Flags (Listof String))
  (lambda [ze opts]
    (filter string?
            (if (zip-directory? ze)
                (let-values ([(_ rsize csize) (zip-entry-metrics ze)])
                  (list (zip-version (zip-directory-cversion ze)) (symbol->immutable-string (zip-directory-csystem ze))
                        (zip-version (zip-directory-eversion ze)) (symbol->immutable-string (zip-directory-esystem ze))
                        (zip-size rsize) (cond [(zipinfo-flags-m opts) (zip-cfactor csize rsize)] [(zipinfo-flags-l opts) (zip-size csize)])
                        (symbol->immutable-string (zip-directory-compression ze))
                        (zip-datetime (zip-directory-mdate ze) (zip-directory-mtime ze) (zipinfo-flags-T opts))
                        (zip-directory-filename ze)))
                (let-values ([(_ rsize csize) (zip-entry-metrics ze)])
                  (list (zip-version (zip-file-eversion ze)) (symbol->immutable-string (zip-file-esystem ze))
                        (zip-size rsize) (cond [(zipinfo-flags-m opts) (zip-cfactor csize rsize)] [(zipinfo-flags-l opts) (zip-size csize)])
                        (symbol->immutable-string (zip-file-compression ze))
                        (zip-datetime (zip-file-mdate ze) (zip-file-mtime ze) (zipinfo-flags-T opts))
                        (zip-file-name ze)))))))

(define zip-display-tail-info : (->* (Path-String) (Term-Color) Void)
  (lambda [zip [fgc #false]]
    (define-values (csize rsize) (zip-content-size* zip))
    
    (echof "~a, ~a uncompressed, ~a compressed: ~a~n" #:fgcolor fgc
           (~n_w (length (zip-directory-list* zip)) "entry") (~size rsize) (~size csize)
           (zip-cfactor csize rsize 1))))

(define zipinfo : (-> ZipInfo-Flags String Any)
  (lambda [opts file.zip]
    (define zip-entries : (U (Listof ZIP-Directory) (Listof ZIP-File))
      (if (zipinfo-flags-A opts)
          (map (inst car ZIP-File Natural) (zip-local-file-list* file.zip))
          (zip-directory-list* file.zip)))

    (define zip-comments : (Pairof String (Listof (Pairof String String)))
      (if (zipinfo-flags-z opts)
          (zip-comment-list* file.zip)
          (cons "" null)))
    
    (when (zipinfo-flags-1 opts)
      (for-each displayln (zip-list zip-entries))
      (exit 0))

    (when (zipinfo-flags-h opts)
      (printf "Archive: ~a~n" (simple-form-path file.zip))
      (printf "Zip file size: ~a, number of entries: ~a~n"
              (~size (file-size file.zip)) (length zip-entries)))

    (define entries : (Listof (Listof String))
      (cond [(zipinfo-flags-2 opts)
             (map (inst list String) (zip-list zip-entries))]
            [(or (zipinfo-flags-s opts) (zipinfo-flags-m opts) (zipinfo-flags-l opts)
                 (not (or (zipinfo-flags-h opts) (zipinfo-flags-t opts))))
             (for/list ([ze (in-list zip-entries)])
               (zip-entry-info ze opts))]
            [else null]))

    (when (> (string-length (car zip-comments)) 0)
      (displayln (car zip-comments)))
    
    (when (pair? entries)
      (cond [(= (length (car entries)) 1) (for ([e entries]) (displayln (car e)))]
            [else (let ([widths (text-column-widths entries)])
                    (for ([e (in-list entries)])
                      (for ([col (in-list e)]
                            [wid (in-list widths)]
                            [idx (in-naturals)])
                        (when (> idx 0) (display #\space))

                        (let ([numerical? (memq (string-ref col (sub1 (string-length col))) (list #\% #\B))])
                          (display (~a col #:min-width (+ wid 1) #:align (if numerical? 'right 'left)))))

                      (let ([?comment (assoc (last e) (cdr zip-comments))])
                        (when (and ?comment (> (string-length (cdr ?comment)) 0))
                          (display #\space)
                          (display (cdr ?comment))))

                      (newline)))]))

    (when (zipinfo-flags-t opts)
      (zip-display-tail-info file.zip))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(define zip-cfactor : (->* (Natural Natural) (Byte) String)
  (lambda [csize rsize [precision 0]]
    (~% #:precision (if (= precision 0) 0 `(= ,precision))
        (- 1 (if (= rsize 0) 1 (/ csize rsize))))))

(define zip-size : (-> Natural String)
  (lambda [size]
    (~size size
           #:precision '(= 3)
           #:bytes->string (λ [n u] (~a n " B")))))

(define zip-version : (-> Index String)
  (lambda [version]
    (number->string (/ (real->double-flonum version) 10.0))))

(define zip-datetime : (-> Index Index Boolean String)
  (lambda [date time T?]
    (define the-date (seconds->date (zip-entry-modify-seconds date time) #true))

    (if (not T?)
        (date->string the-date #true)
        (string-append (number->string (date-year the-date)) (~0time (date-month the-date)) (~0time (date-day the-date))
                       "." (~0time (date-hour the-date)) (~0time (date-minute the-date)) (~0time (date-second the-date))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
(module+ main
  (main (current-command-line-arguments)))
