#lang racket

(provide graph?
        pagerank?
        num-pages
        num-links
        get-backlinks
        mk-initial-pagerank
        step-pagerank
        iterate-pagerank-until
        rank-pages)

;; This program accepts graphs as input. Graphs are represented as a
;; list of links, where each link is a list `(,src ,dst) that signals
;; page src links to page dst.
;; (-> any? boolean?)
(define (graph? glst)
  (and (list? glst)
      (andmap
        (lambda (element)
          (match element
                [`(,(? symbol? src) ,(? symbol? dst)) #t]
                [else #f]))
        glst)))

;; The test graphs for this assignment adhere to several constraints:
;; + There are no "terminal" nodes. All nodes link to at least one
;; other node.
;; + There are no "self-edges," i.e., there will never be an edge `(n0
;; n0).
;; + To maintain consistenty with the last two facts, each graph will
;; have at least two nodes.
;; + There will be no "repeat" edges. I.e., if `(n0 n1) appears once
;; in the graph, it will not appear a second time.
;;
;; (-> any? boolean?)
(define (pagerank? pr)
  (and (hash? pr)
      (andmap symbol? (hash-keys pr))
      (andmap rational? (hash-values pr))
      ;; All the values in the PageRank must sum to 1. I.e., the
      ;; PageRank forms a probability distribution.
      (= 1 (foldl + 0 (hash-values pr)))))

;; Takes some input graph and computes the number of pages in the
;; graph. For example, the graph '((n0 n1) (n1 n2)) has 3 pages, n0,
;; n1, and n2.
;;
;; (-> graph? nonnegative-integer?)

;; This function is helping the funtion num-pages
(define (extract-nodes edges)
  (foldl (lambda (edge acc)
          (append (list (car edge) (cadr edge)) acc))
        '()
        edges))

(define (num-pages graph)
  (define (extract-nodes edges)
    (foldl (lambda (edge acc)
            (append (list (car edge) (cadr edge)) acc))
          '()
          edges))

  (length (remove-duplicates (extract-nodes graph) equal?)))

;; Takes some input graph and computes the number of links emanating
;; from page. For example, (num-links '((n0 n1) (n1 n0) (n0 n2)) 'n0)
;; should return 2, as 'n0 links to 'n1 and 'n2.
;;
;; (-> graph? symbol? nonnegative-integer?)
(define (num-links graph page)
  (define (count-links edges page)
    (foldl (lambda (edge acc)
            (if (equal? (car edge) page)(+ acc 1)
                acc))
          0
          edges))

  (count-links graph page))

;; Calculates a set of pages that link to page within graph. For
;; example, (get-backlinks '((n0 n1) (n1 n2) (n0 n2)) n2) should
;; return (set 'n0 'n1).
;;
;; (-> graph? symbol? (set/c symbol?))
(define (get-backlinks graph page)
  (define (keep-backlinks edges page)
  (foldl (lambda (edge acc)
    (if (equal? (cadr edge) page)
      (cons (car edge) acc)
        acc))
        '()
    edges))

(list->set (keep-backlinks graph page)))

;; Generate an initial pagerank for the input graph g. The returned
;; PageRank must satisfy pagerank?, and each value of the hash must be
;; equal to (/ 1 N), where N is the number of pages in the given
;; graph.
;; (-> graph? pagerank?)
(define (mk-initial-pagerank graph)
  (define N (num-pages graph))
  (define initial-rank (/ 1 N))
  (let ((pagerank (make-hash)))
    (for-each (lambda (link)
      (hash-set! pagerank (car link) initial-rank))
      graph)
    pagerank))

;; Perform one step of PageRank on the specified graph. Return a new
;; PageRank with updated values after running the PageRank
;; calculation. The next iteration's PageRank is calculated as
;;
;; NextPageRank(page-i) = (1 - d) / N + d * S
;;
;; Where:
;;  + d is a specified "dampening factor." in range [0,1]; e.g., 0.85
;;  + N is the number of pages in the graph
;;  + S is the sum of P(page-j) for all page-j.
;;  + P(page-j) is CurrentPageRank(page-j)/NumLinks(page-j)
;;  + NumLinks(page-j) is the number of outbound links of page-j
;;  (i.e., the number of pages to which page-j has links).
;;
;; (-> pagerank? rational? graph? pagerank?)
(define (step-pagerank pr d graph)
  (define N (num-pages graph))
  (let ((new-pagerank (make-hash)))
    (let loop ((pages (hash-keys pr)))
      [cond
        ((null? pages) new-pagerank)
        (else (let* ((page (car pages))
              (backlinks (get-backlinks graph page))
              (s (for/sum ((backlink backlinks))
          (/ (hash-ref pr backlink) (num-links graph backlink)))))
          (hash-set! new-pagerank page (+ (* (- 1 d) (/ 1 N)) (* d s)))
          (loop (cdr pages))))])))

;; Iterate PageRank until the largest change in any page's rank is
;; smaller than a specified delta.
;;
;; (-> pagerank? rational? graph? rational? pagerank?)
(define (iterate-pagerank-until pr d graph delta)
  (let loop ((pr pr) (new-pr (step-pagerank pr d graph)))
    (if (pagerank-converged? pr new-pr delta)
        new-pr
        (loop new-pr (step-pagerank new-pr d graph)))))

;; Helper Functions for iterate-pagerank-until function
(define (pagerank-converged? pr1 pr2 delta)
  (<= (maximum-difference pr1 pr2) delta))

(define (maximum-difference pr1 pr2)
  (apply max (map abs (hash-map pr1 (lambda (k v) (- v (hash-ref pr2 k)))))))

;; Given a PageRank, returns the list of pages it contains in ranked
;; order (from least-popular to most-popular) as a list. You may
;; assume that the none of the pages in the pagerank have the same
;; value (i.e., there will be no ambiguity in ranking)
;;
;; (-> pagerank? (listof symbol?))
(define (rank-pages pr)
  (sort (hash-keys pr) 
  (lambda (page1 page2) (< (hash-ref pr page1) (hash-ref pr page2)))))
