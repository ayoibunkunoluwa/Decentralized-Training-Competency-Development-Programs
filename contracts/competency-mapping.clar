;; Competency Mapping Contract
;; Defines and manages competency frameworks

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u200))
(define-constant ERR_COMPETENCY_EXISTS (err u201))
(define-constant ERR_COMPETENCY_NOT_FOUND (err u202))
(define-constant ERR_INVALID_LEVEL (err u203))

;; Competency levels
(define-constant LEVEL_BEGINNER u1)
(define-constant LEVEL_INTERMEDIATE u2)
(define-constant LEVEL_ADVANCED u3)
(define-constant LEVEL_EXPERT u4)

;; Data structures
(define-map competencies
  { competency-id: uint }
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    category: (string-ascii 50),
    level: uint,
    prerequisites: (list 10 uint),
    skills: (list 20 (string-ascii 100)),
    created-by: principal,
    created-at: uint
  }
)

(define-map competency-relationships
  { parent-id: uint, child-id: uint }
  { relationship-type: (string-ascii 20) }
)

(define-data-var next-competency-id uint u1)

;; Public functions
(define-public (create-competency
  (name (string-ascii 100))
  (description (string-ascii 500))
  (category (string-ascii 50))
  (level uint)
  (prerequisites (list 10 uint))
  (skills (list 20 (string-ascii 100)))
)
  (let ((competency-id (var-get next-competency-id)))
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (and (>= level LEVEL_BEGINNER) (<= level LEVEL_EXPERT)) ERR_INVALID_LEVEL)
    (asserts! (is-none (map-get? competencies { competency-id: competency-id })) ERR_COMPETENCY_EXISTS)

    (map-set competencies
      { competency-id: competency-id }
      {
        name: name,
        description: description,
        category: category,
        level: level,
        prerequisites: prerequisites,
        skills: skills,
        created-by: tx-sender,
        created-at: block-height
      }
    )
    (var-set next-competency-id (+ competency-id u1))
    (ok competency-id)
  )
)

(define-public (add-competency-relationship (parent-id uint) (child-id uint) (relationship-type (string-ascii 20)))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (is-some (map-get? competencies { competency-id: parent-id })) ERR_COMPETENCY_NOT_FOUND)
    (asserts! (is-some (map-get? competencies { competency-id: child-id })) ERR_COMPETENCY_NOT_FOUND)

    (map-set competency-relationships
      { parent-id: parent-id, child-id: child-id }
      { relationship-type: relationship-type }
    )
    (ok true)
  )
)

(define-public (update-competency-level (competency-id uint) (new-level uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (asserts! (and (>= new-level LEVEL_BEGINNER) (<= new-level LEVEL_EXPERT)) ERR_INVALID_LEVEL)

    (match (map-get? competencies { competency-id: competency-id })
      competency-data
      (begin
        (map-set competencies
          { competency-id: competency-id }
          (merge competency-data { level: new-level })
        )
        (ok true)
      )
      ERR_COMPETENCY_NOT_FOUND
    )
  )
)

;; Read-only functions
(define-read-only (get-competency (competency-id uint))
  (map-get? competencies { competency-id: competency-id })
)

(define-read-only (get-competency-relationship (parent-id uint) (child-id uint))
  (map-get? competency-relationships { parent-id: parent-id, child-id: child-id })
)

(define-read-only (get-next-competency-id)
  (var-get next-competency-id)
)
