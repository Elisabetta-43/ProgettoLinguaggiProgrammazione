;;;; Elisabetta Locatelli 914621
;;;; Matteo Lorenzin 914593
;;;; Simone Frijio 914366

;;;; -*- Mode: Lisp -*-
;;;; urilib-parse.lisp starts here.
;;;; RFC3986 (http://tools.ietf.org/html/rfc3986)

;;; Struct containing all the components of a URI string.
(defstruct urilib-structure schema userinfo host port path query fragment)

;;; Struct containing all the fields of the authority.
(defstruct authority-structure userinfo host port)

;;; Each of this function represents the extraction of a single
;;; component from the URILIB-STRUCTURE.
;;; These are accessor functions for the structure.
(defun urilib-scheme (uri) (urilib-structure-schema uri))
(defun urilib-userinfo (uri) (urilib-structure-userinfo uri))
(defun urilib-host (uri) (urilib-structure-host uri))
(defun urilib-port (uri) (urilib-structure-port uri))
(defun urilib-path (uri) (urilib-structure-path uri))
(defun urilib-query (uri) (urilib-structure-query uri))
(defun urilib-fragment (uri) (urilib-structure-fragment uri))

;;; Urilib-display: debug method to print the input URI to the destination
;;; stream or to the current stream, if not specified as input.
(defun urilib-display (uri &optional (stream T))
  (format stream "Schema:~13T~S~%" (urilib-scheme uri))
  (format stream "Userinfo:~13T~S~%" (urilib-userinfo uri))
  (format stream "Host:~13T~S~%" (urilib-host uri))
  (format stream "Port:~13T~D~%" (urilib-port uri))
  (format stream "Path:~13T~S~%" (urilib-path uri))
  (format stream "Query:~13T~S~%" (urilib-query uri))
  (format stream "Fragment:~13T~S" (urilib-fragment uri))
  (if (not (equal stream T))
      (close stream)
    T))

;;; Urilib-parse: main method for decomposing the URI into
;;; its components, populating a URILIB-STRUCTURE. The method starts
;;; with parsing the Schema, determining if it's standard or special, 
;;; and decomposing it according to the respective specifications.
(defun urilib-parse (uri)
  (if (stringp uri)
      (multiple-value-bind (schema after)
          (extract-schema (coerce uri 'list))
        (if (and (not (standard-schema-p (coerce schema 'string)))
                 (not (special-schema-p (coerce schema 'string))))
            (error "Schema not recognized"))
        (if (null after) 
            (make-urilib-structure
             :schema (coerce schema 'string)
             :userinfo (if (or (string= (coerce schema 'string) "mailto")
                               (string= (coerce schema 'string) "tel")
                               (string= (coerce schema 'string) "fax"))
                           (error "Missing userinfo")
                         NIL)
             :host (if (string= (coerce schema 'string) "news")
                       (error  "Missing host")
                     NIL)
             :port (coerce (default-port schema) 'string)
             :path (if (string= (coerce schema 'string) "zos")
                       (error "Missing Path")
                     NIL)
             :query NIL
             :fragment NIL)
          (if (special-schema-p (coerce schema 'string))
              (extract-special-uri (coerce schema 'string) after)
            (multiple-value-bind (authority after)
                (extract-authority after schema)
              (multiple-value-bind (path after)
                  (extract-path after)
                (multiple-value-bind (query after)
                    (if (contains-separator after "?")
                        (extract-query after)
                      (values NIL after))
                  (multiple-value-bind (fragment)
                      (if (contains-separator after "#")
                          (values (coerce (extract-fragment after) 'string))
                        (values NIL))
                    (make-urilib-structure
                     :schema (coerce schema 'string)
                     :userinfo (if (equal
                                    (authority-structure-userinfo authority)
                                    NIL)
                                   NIL
                                 (coerce
                                  (authority-structure-userinfo authority)
                                  'string))
                     :host (coerce
                            (authority-structure-host authority)
                            'string)
                     :port (if (null (authority-structure-port authority))
                               (error "Invalid port")
                             (parse-integer
                              (coerce
                              (authority-structure-port authority) 'string)))
                     :path (if (null path)
                               NIL
                             (coerce path 'string))
                     :query (if (null query)
                                NIL
                              (coerce query 'string))
                     :fragment (if (null fragment)
                                   NIL
                                 (coerce fragment 'string))))))))))
    NIL))

;;; Extract-schema: function that extracts the Schema from the input string.
(defun extract-schema (chars &optional (schema-chars '()))
  (cond ((null chars)
         (error "Schema is not valid"))
	((string= (first chars) ":")
	 (values (reverse schema-chars)
                 (rest chars)))
	(T (if (valid-character (first chars))
               (multiple-value-bind (schema-chars after)
                   (extract-schema (rest chars) schema-chars)
                 (values (cons (first chars) schema-chars) after))
             (error "Invalid Schema character")))))

;;; Standard-schema-p: predicate for defining the presence of a Schema
;;; characterized by "standard syntax".
(defun standard-schema-p (schema)
  (or (string= schema "http")
      (string= schema "https")
      (string= schema "ftp")))

;;; Special-schema-p: predicate for defining the presence of a Schema 
;;; characterized by "special syntax".
(defun special-schema-p (schema)
  (or (string= schema "mailto")
      (string= schema "news")
      (string= schema "tel")
      (string= schema "fax")
      (string= schema "zos")))

;;; Extract-authority: function that extracts the Authority components and
;;; returns them inside an AUTHORITY-STRUCTURE.
(defun extract-authority (chars schema)
  (cond ((and (string= (first chars) "/")
              (string= (second chars) "/"))
         (multiple-value-bind (authority after)
            (extract-authority-chars (rest (rest chars)))
           (let ((authority-struct
                  (make-authority-structure
                   :userinfo (if (contains-separator authority "@")
                                 (extract-userinfo authority)
                               NIL)
                   :host (extract-host authority)
                   :port (if (contains-separator authority ":")
                             (extract-port authority)
                           (coerce (default-port schema) 'string)))))
             (values authority-struct after))))
        ((and (> (length chars) 0)
              (not (string= (second chars) "/")))
         (multiple-value-bind (authority after)
             (make-authority-structure
              :userinfo NIL
              :host NIL
              :port (coerce (default-port schema) 'string))
           (values authority chars)))
        (T (error "Authority not recognized"))))

;;; Extract-authority-chars: functions that recursively extracts the
;;; characters that compose the Authority, until it finds a special
;;; character indicating its termination.
(defun extract-authority-chars (chars &optional (authority-rest '()))
  (cond  ((null chars)
          (values (reverse authority-rest)
                  NIL))
         ((string= (first chars) "/")
          (values (reverse authority-rest)
                  chars))
         ((or (string= (first chars) "?")
              (string= (first chars) "#"))
          (error "Invalid format: '/' is expected"))
         (T (multiple-value-bind (authority-rest after)
                (extract-authority-chars (rest chars) authority-rest)
              (values (cons (first chars) authority-rest) after)))))

;;; Contains-separator: "helper" function that returns T if the
;;; separator, passed as input, is present or NIL otherwise.
(defun contains-separator (chars separator)
  (cond ((null chars) NIL)
	((string= (first chars) separator) T)
	(T (contains-separator (rest chars) separator))))

;;; Extract-userinfo: function that ricursively extracts the characters
;;; that compose the Userinfo.
(defun extract-userinfo (chars)
  (cond ((null chars) NIL)
        (T (extract-userinfo-chars chars))))

;;; Extract-userinfo-chars: function that checks if the characters are 
;;; valid, returning control to the caller when it finds the '@' separator.
(defun extract-userinfo-chars (chars)
  (cond ((string= (first chars) "@") NIL)
	(T (if (valid-character (first chars))
               (cons (first chars)
                     (extract-userinfo (rest chars)))
             (error "Invalid userinfo character")))))

;;; Extract-host: function that extracts the '@' character from the list
;;; and calls the "is-ip" function for the further evaluations.
(defun extract-host (chars)
  (cond ((null chars)
         (error "Missing host"))
        ((contains-separator chars "@")
         (if (string= (first chars) "@")
             (is-ip chars)
           (extract-host (rest chars))))
        (T (is-ip chars ))))

;;; Is-ip: function that checks the format of the Host and calls the
;;; respective functions needed for extracting the individual characters.
(defun is-ip (chars)
  (cond ((alpha-char-p (first chars))
         (extract-host-chars chars))
        ((if (and
              (numberp (digit-char-p (first chars)))
              (= (count-dots chars) 3)
              (not (contains-separator chars "@")))
             (extract-host-ip chars)))
        ((contains-separator chars "@")
         (is-ip (rest chars)))
        (T (error "Invalid Host"))))

;;; Count-dots: function that counts the number of occurrences of the
;;; character '.', to assess the correctness of the IP address format.
(defun count-dots (chars)
  (cond ((null chars) 0)
        ((string= (first chars) ".")
         (+ 1 (count-dots (rest chars))))
        (T (count-dots (rest chars)))))

;;; Extract-host-chars: function that recursively extracts the 
;;; characters that compose the Host, ensuring that the '.' character
;;; is always followed by an alphabetical character, and that the
;;; following characters are alphanumeric.
(defun extract-host-chars (chars &optional (host-chars '()))
  (cond ((null chars) NIL)
        ((or (string= (first chars) ":")
             (string= (first chars) "/"))
         NIL)
	(T (if (or (and (string= (first chars) ".")
                        (alpha-char-p (first (rest chars))))
                   (alphanumericp (first chars)))
               (multiple-value-bind (host-chars after)
                   (extract-host-chars (rest chars) host-chars)
                 (values (cons (first chars) host-chars) after))
             (error "Invalid host")))))

;;; Extract-host-ip: function that recursively extracts the characters
;;; that make up the IP address, ensuring that each number, separated
;;; by the '.' character is within the range [0,255], via the
;;; "valid-number-ip" function.
(defun extract-host-ip (chars)
  (cond ((null chars) NIL)
        ;; Handling the case of a single-digit numbers
        ((and (string= (second chars) ".")
              (valid-number-ip
               (parse-integer (coerce (list (first chars)) 'string))))
         (append (display-digits chars)
                 (extract-host-ip (rest (rest chars)))))
        ;; Handling the case of a two-digit number
        ((and (string= (third chars) ".")
              (valid-number-ip
               (parse-integer
                (coerce (concatenate-digits chars) 'string))))
         (append (display-digits chars)
                 (extract-host-ip (rest (rest (rest chars))))))
        ;; Handling the case of a three-digit number
        ((and (string= (fourth chars) ".")
              (valid-number-ip
               (parse-integer
                (coerce (concatenate-digits chars) 'string))))
         (append (display-digits chars)
                 (extract-host-ip (rest (rest (rest (rest chars)))))))
        ;; Handling the case of the last number
        ((and (not (contains-separator chars "."))
              (valid-number-ip
               (parse-integer
                (coerce (concatenate-digits chars) 'string))))
         (append (display-digits chars)  NIL))
        (T (error "IP Address not recognized"))))

;;; Concatenate-digits: function that, given NNN digits, trasforms 
;;; them into a single number.
(defun concatenate-digits (chars)
  (cond ((null chars) NIL)
        ((or (string= (first chars) ".")
             (string= (first chars) ":")
             (string= (first chars) "/"))
         NIL)
        ((not (numberp 
               (parse-integer (coerce (list (first chars)) 'string))))
         NIL)
        (T (append (list (first chars))
                   (concatenate-digits (rest chars))))))

;;; Display-digits: function that prints n-tuples of digits that
;;; make up the IP address.
(defun display-digits (chars)
  (cond ((null chars) NIL)
        ((string= (first chars) ".") (list '#\.))
        ((string= (first chars) ":") NIL)
        (T (append (list (first chars))
                   (display-digits (rest chars))))))

;;; Extract-port: function that recursively extracts characters that
;;; make up the Port, checking that they are of type "digit".
(defun extract-port (chars)
  (cond ((contains-separator chars ":")
	 (extract-port (rest chars)))
	((null chars) NIL)
	(T (if (numberp (digit-char-p (first chars)))
	       (append (list (first chars))
		       (extract-port (rest chars)))
             (error "Invalid port character")))))

;;; Default-port: predicate that defines the default Port related
;;; to the URI Schema.
(defun default-port (schema)
  (cond ((string= (coerce schema 'string) "http") "80")
        ((string= (coerce schema 'string) "https") "443")
        ((string= (coerce schema 'string) "ftp") "21")
        ((string= (coerce schema 'string) "zos") "3270")
        (T "80")))

;;; Extract-path: function that removes the charcater '/' if present
;;; before extracting the various character of the Path.
(defun extract-path (chars)
  (cond ((string= (first chars) "/")
	 (extract-path-chars (rest chars)))
        (T (extract-path-chars chars))))

;;; Extract-path-chars: function that recursively extracts the valid
;;; characters that make up the path, returning an error if an invalid
;;; character is found.
(defun extract-path-chars (chars &optional (path-chars '()))
  (cond ((null chars)
         (values (reverse path-chars)
                 chars))
	((or (string= (first chars) "?")
	     (string= (first chars) "#"))
         (values (reverse path-chars)
                 chars))
	(T (if (or (valid-character (first chars))
		   (string= (first chars) "/"))
	       (multiple-value-bind (path-chars after)
                   (extract-path-chars (rest chars) path-chars)
                 (values (cons (first chars) path-chars) after))
             (error "Invalid path character")))))

;;; Extract-query: function that checks for the presence of "special"
;;; characters at the start of the list and removes them if present
;;; before extracting the following characters.
(defun extract-query (chars)
  (cond ((and (string= (first chars) "/")
              (string= (second chars) "?"))
         (extract-query-chars (rest (rest chars))))
        ((string= (first chars) "?")
	 (extract-query-chars (rest chars)))))

;;; Extract-query-chars: function that recursively extracts the characters
;;; that make up the Query.
(defun extract-query-chars (chars &optional (query-chars '()))
  (cond ((null chars)
         (values (reverse query-chars)
                 chars))
	((string= (first chars) "#")
         (values (reverse query-chars)
                 chars))
	(T (if (valid-character (first chars))
               (multiple-value-bind (query-chars after)
                   (extract-query-chars (rest chars) query-chars)
                 (values (cons (first chars) query-chars) after))
             (error "Invalid query character")))))

;;; Extract-fragment: function that checks the presence of "special"
;;; characters at the beginning of the list and remove them
;;; before passing control to the "extract-fragment-chars" function.
(defun extract-fragment (chars)
  (cond ((string= (first chars) "#")
	 (extract-fragment-chars (rest chars)))
        ((and (string= (first chars) "/")
              (string= (second chars) "#"))
         (extract-fragment-chars (rest (rest chars))))))

;;; Extract-fragment-chars: function that recursively extracts the
;;; charcaters that make up the Fragment.
(defun extract-fragment-chars (chars &optional (fragment-chars '()))
  (cond ((null chars) NIL)
        (T (if (valid-character (first chars))
               (multiple-value-bind (fragment-chars)
                   (extract-fragment-chars (rest chars) fragment-chars)
                 (values (cons (first chars) fragment-chars)))
             (error "Invalid fragment character")))))

;;; Extract-special-host: function that checks the presence of the
;;; Host in special cases.
(defun extract-special-host (chars schema)
  (cond ((null chars)
         (error "Missing host"))
        ((contains-separator chars "@")
         (if (string= (first chars) "@")
             (is-special-ip  chars schema)
           (extract-special-host (rest chars) schema)))
        (T (is-special-ip chars schema))))

;;; Is-special-ip: function that checks the Host format in special cases.
(defun is-special-ip (chars schema)
  (cond ((alpha-char-p (first chars))
         (extract-special-host-chars chars schema))
        ((if (and (numberp (digit-char-p (first chars)))
                  (= (count-dots chars) 3)
                  (not (contains-separator chars "@")))
             (extract-host-ip chars)))
        ((contains-separator chars "@")
         (is-special-ip (rest chars) schema))
        (T (error "Invalid  Host"))))

;;; Extract-special-host-chars: function that recursively extracts the
;;; characters that make up the Host, with the peculiarities that special
;;; cases do not contain any further invalid fields.
(defun extract-special-host-chars (chars schema)
  (cond ((null chars) NIL)
        ((and (or (string= schema "mailto")
                  (string= schema  "news"))
              (or (string= (first chars) ":")
                  (string= (first chars) "#")
                  (string= (first chars) "?")
                  (string= (first chars) "/")))
         (error "Invalid format"))
	((string= (first chars) ":") NIL)
        ((and (string= (first chars) ".")
              (alpha-char-p (first (rest chars))))
         (append (list (first chars))
                 (extract-special-host-chars (rest chars) schema)))
	(T (if (alphanumericp (first chars))
	       (append (list (first chars))
		       (extract-special-host-chars (rest chars) schema))
             (error "Invalid host")))))

;;; Extract-special-uri: method for decomposing URI in the case of
;;; Schemes characterized by "special syntax".
(defun extract-special-uri (schema chars)
  (cond ((string= schema "mailto")
         (if (contains-separator chars "@")
             (make-urilib-structure
              :schema schema
              :userinfo (coerce (extract-userinfo chars) 'string)
              :host (coerce (extract-special-host chars schema) 'string)
              :port "80")
           (make-urilib-structure
            :schema schema
            :userinfo (coerce (extract-userinfo chars) 'string)
            :port "80")))
        ((string= schema "news")
         (make-urilib-structure
          :schema schema
          :host (if (or (contains-separator chars "@")
                        (contains-separator chars ":"))
                    (error "Invalid host character")
                  (coerce (extract-special-host chars schema) 'string))
          :port "80"))
        ((or (string= schema "tel")
             (string= schema "fax"))
         (make-urilib-structure
          :schema schema
          :userinfo (if (contains-separator chars "@")
                        (error "Invalid userinfo")
                      (coerce (extract-userinfo chars) 'string))
          :port "80"))
        ((string= schema "zos")
         (multiple-value-bind (authority after)
             (extract-authority chars schema)
           (cond ((or (null after)
                      (and (string= (first chars) "/")
                           (null (second chars))))
                  (error "Missing Zos' path"))
                 ((and (contains-separator after "/")
                       (not (alpha-char-p (first (rest after)))))
                  (error "Invalid Zos' path"))
                 ((and (not (contains-separator after "/"))
                       (not (alpha-char-p (first after))))
                  (error "Invalid Zos' path")))
           (multiple-value-bind (zos-path after2)
               (if (contains-separator after "/")
                   (extract-zos-path (rest after))
                 (extract-zos-path after))
             (multiple-value-bind (query after3)
                 (if (contains-separator after2 "?")
                     (extract-query after2)
                   (values NIL after2))
               (multiple-value-bind (fragment)
                   (if (contains-separator after3 "#")
                       (extract-fragment after3)
                     (values NIL))
                 (make-urilib-structure
                  :schema (coerce schema 'string)
                  :userinfo (if (equal
                                 (authority-structure-userinfo authority) NIL)
                                NIL
                              (coerce
                               (authority-structure-userinfo authority)
                               'string))
                  :host (coerce (authority-structure-host authority) 'string)
                  :port (coerce (authority-structure-port authority) 'string)
                  :path (coerce zos-path 'string)
                  :query (if query (coerce query 'string) NIL)
                  :fragment (if fragment
                                (coerce fragment 'string)
                              NIL)))))))))


;;; Extract-zos-path: function that extracts the Path of a 
;;; corresponding to the "Zos" Schema. The function checks the
;;; correctness of parentheses and that both components of the Path, 
;;; Id44 and Id8, begin with an alphabetic character.
;;; After extracting Id44 and Id8, a further check is performed on
;;; the length of both components.
(defun extract-zos-path (chars)
  (cond ((or (and (contains-separator chars "(")
                  (not (contains-separator chars ")")))
             (and (not (contains-separator chars "("))
                  (contains-separator chars ")")))
         (error "Invalid Zos' path"))
        ((and (contains-separator chars "(")
              (contains-separator chars ")"))
         (multiple-value-bind (id44-chars after)
             (extract-id44 chars)
           (if (string= (first (reverse id44-chars)) ".")
               (error "Invalid Zos'path")
             (multiple-value-bind (id8-chars after2)
                 (extract-id8 after)
               (if (not (alpha-char-p (first id8-chars)))
                   (error "Invalid Zos character")
                 (cond ((or (< (length id44-chars) 1)
                            (> (length id44-chars) 44)
                            (< (length id8-chars) 1)
                            (> (length id8-chars) 8))
                        (error "Path length not allowed"))
                       (T (values
                           (append id44-chars '(#\() id8-chars '(#\)))
                           after2))))))))
        (T (multiple-value-bind (id44-chars after)
               (extract-id44 chars)
             (if (string= (first (reverse id44-chars)) ".")
                 (error "Invalid Zos'path"))
             (cond ((or (< (length id44-chars) 1)
                        (> (length id44-chars) 44))
                    (error "Path length not allowed"))
                   (T (values id44-chars after)))))))

;;; Extract-id44: function that recursively extracts the characters
;;; of Id44, checking that the characters are alphanumeric.
(defun extract-id44 (chars &optional (chars-id44 '()))
  (cond ((null chars)
         (values (reverse chars-id44)
                 chars))
        ((or (string= (first chars) "(")
             (string= (first chars) "?")
             (string= (first chars) "#"))
         (values (reverse chars-id44)
                 chars))
        ((or (alphanumericp (first chars))
             (string= (first chars) "."))
         (multiple-value-bind (chars-id44 after)
             (extract-id44 (rest chars) chars-id44)
           (values (cons (first chars) chars-id44) after)))
        (T (error "Invalid id44 character"))))

;;; Extract-id8: function that recursively extracts the characters of
;;; Id8, checking that the characters are alphanumeric.
(defun extract-id8 (chars &optional (chars-id8 '()))
  (cond ((string= (first chars) "(")
	 (extract-id8 (rest chars)))
	((string= (first chars) ")")
         (values (reverse chars-id8)
                 (rest chars)))
        ((null chars)
         (error "Invalid id8"))
	((alphanumericp (first chars))
         (multiple-value-bind (chars-id8 after)
             (extract-id8 (rest chars) chars-id8)
           (values (cons (first chars) chars-id8) after)))
	(T (error "Invalid id8 character"))))

;;; Valid-character: predicate that determines whether the passed
;;; character is considered valid, as it corresponds to one of the
;;; accepted characters in the specification.
(defun valid-character (char)
  (or (alphanumericp char)
      (string= char "_")
      (string= char "=")
      (string= char "+")
      (string= char "-")))

;;; Valid-number-ip: predicate that determines whether the passed number
;;; is within the valid range of values for an IP address ([0,255]).
(defun valid-number-ip (number)
  (and (integerp number)
       (>= number 0)
       (<= number 255)))

;;;; urilib-parse.lisp ends here.
