;; Assessment Coordination Contract
;; Coordinates competency assessments and evaluations

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u400))
(define-constant ERR_ASSESSMENT_NOT_FOUND (err u401))
(define-constant ERR_INVALID_STATUS (err u402))
(define-constant ERR_INVALID_SCORE (err u403))

;; Assessment status constants
(define-constant STATUS_SCHEDULED u1)
(define-constant STATUS_IN_PROGRESS u2)
(define-constant STATUS_COMPLETED u3)
(define-constant STATUS_CANCELLED u4)

;; Assessment types
(define-constant TYPE_PRACTICAL u1)
(define-constant TYPE_THEORETICAL u2)
(define-constant TYPE_PROJECT u3)
(define-constant TYPE_PEER_REVIEW u4)

;; Data structures
(define-map assessments
  { assessment-id: uint }
  {
    competency-id: uint,
    assessor: principal,
    candidate: principal,
    assessment-type: uint,
    status: uint,
    scheduled-date: uint,
    completion-date: uint,
    score: uint,
    max-score: uint,
    feedback: (string-ascii 500),
    created-at: uint
  }
)

(define-map assessment-criteria
  { assessment-id: uint, criteria-id: uint }
  {
    description: (string-ascii 200),
    weight: uint,
    score: uint,
    max-score: uint
  }
)

(define-map assessor-qualifications
  { assessor: principal, competency-id: uint }
  {
    qualified: bool,
    qualification-date: uint,
    expires-at: uint
  }
)

(define-data-var next-assessment-id uint u1)

;; Public functions
(define-public (schedule-assessment
  (competency-id uint)
  (assessor principal)
  (candidate principal)
  (assessment-type uint)
  (scheduled-date uint)
  (max-score uint)
)
  (let ((assessment-id (var-get next-assessment-id)))
    (asserts! (is-assessor-qualified assessor competency-id) ERR_UNAUTHORIZED)

    (map-set assessments
      { assessment-id: assessment-id }
      {
        competency-id: competency-id,
        assessor: assessor,
        candidate: candidate,
        assessment-type: assessment-type,
        status: STATUS_SCHEDULED,
        scheduled-date: scheduled-date,
        completion-date: u0,
        score: u0,
        max-score: max-score,
        feedback: "",
        created-at: block-height
      }
    )

    (var-set next-assessment-id (+ assessment-id u1))
    (ok assessment-id)
  )
)

(define-public (start-assessment (assessment-id uint))
  (begin
    (match (map-get? assessments { assessment-id: assessment-id })
      assessment-data
      (begin
        (asserts! (or (is-eq tx-sender (get assessor assessment-data))
                     (is-eq tx-sender (get candidate assessment-data))) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status assessment-data) STATUS_SCHEDULED) ERR_INVALID_STATUS)

        (map-set assessments
          { assessment-id: assessment-id }
          (merge assessment-data { status: STATUS_IN_PROGRESS })
        )
        (ok true)
      )
      ERR_ASSESSMENT_NOT_FOUND
    )
  )
)

(define-public (complete-assessment
  (assessment-id uint)
  (score uint)
  (feedback (string-ascii 500))
)
  (begin
    (match (map-get? assessments { assessment-id: assessment-id })
      assessment-data
      (begin
        (asserts! (is-eq tx-sender (get assessor assessment-data)) ERR_UNAUTHORIZED)
        (asserts! (is-eq (get status assessment-data) STATUS_IN_PROGRESS) ERR_INVALID_STATUS)
        (asserts! (<= score (get max-score assessment-data)) ERR_INVALID_SCORE)

        (map-set assessments
          { assessment-id: assessment-id }
          (merge assessment-data {
            status: STATUS_COMPLETED,
            completion-date: block-height,
            score: score,
            feedback: feedback
          })
        )
        (ok true)
      )
      ERR_ASSESSMENT_NOT_FOUND
    )
  )
)

(define-public (qualify-assessor (assessor principal) (competency-id uint) (expires-at uint))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)

    (map-set assessor-qualifications
      { assessor: assessor, competency-id: competency-id }
      {
        qualified: true,
        qualification-date: block-height,
        expires-at: expires-at
      }
    )
    (ok true)
  )
)

(define-public (add-assessment-criteria
  (assessment-id uint)
  (criteria-id uint)
  (description (string-ascii 200))
  (weight uint)
  (max-score uint)
)
  (begin
    (match (map-get? assessments { assessment-id: assessment-id })
      assessment-data
      (begin
        (asserts! (is-eq tx-sender (get assessor assessment-data)) ERR_UNAUTHORIZED)

        (map-set assessment-criteria
          { assessment-id: assessment-id, criteria-id: criteria-id }
          {
            description: description,
            weight: weight,
            score: u0,
            max-score: max-score
          }
        )
        (ok true)
      )
      ERR_ASSESSMENT_NOT_FOUND
    )
  )
)

;; Read-only functions
(define-read-only (get-assessment (assessment-id uint))
  (map-get? assessments { assessment-id: assessment-id })
)

(define-read-only (get-assessment-criteria (assessment-id uint) (criteria-id uint))
  (map-get? assessment-criteria { assessment-id: assessment-id, criteria-id: criteria-id })
)

(define-read-only (is-assessor-qualified (assessor principal) (competency-id uint))
  (match (map-get? assessor-qualifications { assessor: assessor, competency-id: competency-id })
    qualification-data
    (and (get qualified qualification-data)
         (> (get expires-at qualification-data) block-height))
    false
  )
)

(define-read-only (get-next-assessment-id)
  (var-get next-assessment-id)
)
