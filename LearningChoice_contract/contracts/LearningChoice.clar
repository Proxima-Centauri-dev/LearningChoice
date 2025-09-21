
;; title: LearningChoice
;; version: 1.0.0
;; summary: Collaborative educational system for course content selection and academic standards
;; description: A smart contract that enables educators and institutions to collaboratively
;;              select course content, vote on academic standards, and manage educational resources

;; traits
;;

;; token definitions
;;

;; constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-COURSE-NOT-FOUND (err u101))
(define-constant ERR-CONTENT-NOT-FOUND (err u102))
(define-constant ERR-ALREADY-VOTED (err u103))
(define-constant ERR-INVALID-VOTE (err u104))
(define-constant ERR-COURSE-ALREADY-EXISTS (err u105))
(define-constant ERR-INSUFFICIENT-PERMISSIONS (err u106))

(define-constant CONTRACT-OWNER tx-sender)

;; data vars
(define-data-var next-course-id uint u1)
(define-data-var next-content-id uint u1)

;; data maps
;; Courses: stores course information
(define-map courses
  { course-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    creator: principal,
    created-at: uint,
    is-active: bool,
    required-votes: uint,
    academic-level: (string-ascii 50)
  }
)

;; Course content proposals
(define-map content-proposals
  { content-id: uint }
  {
    course-id: uint,
    title: (string-ascii 100),
    description: (string-ascii 500),
    content-type: (string-ascii 50), ;; "video", "text", "quiz", "assignment"
    proposer: principal,
    votes-for: uint,
    votes-against: uint,
    is-approved: bool,
    created-at: uint
  }
)

;; Educator permissions
(define-map educators
  { educator: principal }
  {
    institution: (string-ascii 100),
    verified: bool,
    reputation-score: uint
  }
)

;; Voting records to prevent double voting
(define-map votes
  { voter: principal, content-id: uint }
  { vote: bool, timestamp: uint }
)

;; Academic standards
(define-map academic-standards
  { standard-id: uint }
  {
    title: (string-ascii 100),
    description: (string-ascii 500),
    level: (string-ascii 50),
    subject-area: (string-ascii 100),
    votes-for: uint,
    votes-against: uint,
    is-ratified: bool
  }
)

;; public functions

;; Register as an educator
(define-public (register-educator (institution (string-ascii 100)))
  (begin
    (map-set educators
      { educator: tx-sender }
      {
        institution: institution,
        verified: false,
        reputation-score: u0
      }
    )
    (ok true)
  )
)

;; Verify an educator (only contract owner can do this)
(define-public (verify-educator (educator principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (match (map-get? educators { educator: educator })
      educator-data
      (begin
        (map-set educators
          { educator: educator }
          (merge educator-data { verified: true })
        )
        (ok true)
      )
      ERR-NOT-AUTHORIZED
    )
  )
)

;; Create a new course
(define-public (create-course
  (title (string-ascii 100))
  (description (string-ascii 500))
  (required-votes uint)
  (academic-level (string-ascii 50)))
  (let
    (
      (course-id (var-get next-course-id))
    )
    (begin
      ;; Check if sender is a verified educator
      (asserts! (is-verified-educator tx-sender) ERR-INSUFFICIENT-PERMISSIONS)

      ;; Create the course
      (map-set courses
        { course-id: course-id }
        {
          title: title,
          description: description,
          creator: tx-sender,
          created-at: block-height,
          is-active: true,
          required-votes: required-votes,
          academic-level: academic-level
        }
      )

      ;; Increment course ID for next course
      (var-set next-course-id (+ course-id u1))

      (ok course-id)
    )
  )
)

;; Propose content for a course
(define-public (propose-content
  (course-id uint)
  (title (string-ascii 100))
  (description (string-ascii 500))
  (content-type (string-ascii 50)))
  (let
    (
      (content-id (var-get next-content-id))
    )
    (begin
      ;; Check if course exists
      (asserts! (is-some (map-get? courses { course-id: course-id })) ERR-COURSE-NOT-FOUND)

      ;; Check if sender is a verified educator
      (asserts! (is-verified-educator tx-sender) ERR-INSUFFICIENT-PERMISSIONS)

      ;; Create content proposal
      (map-set content-proposals
        { content-id: content-id }
        {
          course-id: course-id,
          title: title,
          description: description,
          content-type: content-type,
          proposer: tx-sender,
          votes-for: u0,
          votes-against: u0,
          is-approved: false,
          created-at: block-height
        }
      )

      ;; Increment content ID
      (var-set next-content-id (+ content-id u1))

      (ok content-id)
    )
  )
)

;; Vote on content proposal
(define-public (vote-on-content (content-id uint) (vote bool))
  (let
    (
      (existing-vote (map-get? votes { voter: tx-sender, content-id: content-id }))
      (content-data (unwrap! (map-get? content-proposals { content-id: content-id }) ERR-CONTENT-NOT-FOUND))
    )
    (begin
      ;; Check if content exists
      (asserts! (is-some (map-get? content-proposals { content-id: content-id })) ERR-CONTENT-NOT-FOUND)

      ;; Check if already voted
      (asserts! (is-none existing-vote) ERR-ALREADY-VOTED)

      ;; Check if sender is a verified educator
      (asserts! (is-verified-educator tx-sender) ERR-INSUFFICIENT-PERMISSIONS)

      ;; Record the vote
      (map-set votes
        { voter: tx-sender, content-id: content-id }
        { vote: vote, timestamp: block-height }
      )

      ;; Update vote counts
      (if vote
        (map-set content-proposals
          { content-id: content-id }
          (merge content-data { votes-for: (+ (get votes-for content-data) u1) })
        )
        (map-set content-proposals
          { content-id: content-id }
          (merge content-data { votes-against: (+ (get votes-against content-data) u1) })
        )
      )

      ;; Check if content should be approved
      (let
        (
          (updated-content (unwrap-panic (map-get? content-proposals { content-id: content-id })))
          (course-data (unwrap-panic (map-get? courses { course-id: (get course-id updated-content) })))
          (required-votes (get required-votes course-data))
        )
        (if (>= (get votes-for updated-content) required-votes)
          (map-set content-proposals
            { content-id: content-id }
            (merge updated-content { is-approved: true })
          )
          true
        )
      )

      (ok true)
    )
  )
)

;; read only functions

;; Check if an educator is verified
(define-read-only (is-verified-educator (educator principal))
  (match (map-get? educators { educator: educator })
    educator-data (get verified educator-data)
    false
  )
)

;; Get course information
(define-read-only (get-course (course-id uint))
  (map-get? courses { course-id: course-id })
)

;; Get content proposal information
(define-read-only (get-content-proposal (content-id uint))
  (map-get? content-proposals { content-id: content-id })
)

;; Get educator information
(define-read-only (get-educator (educator principal))
  (map-get? educators { educator: educator })
)

;; Check if user has voted on content
(define-read-only (has-voted (voter principal) (content-id uint))
  (is-some (map-get? votes { voter: voter, content-id: content-id }))
)

;; Get vote information
(define-read-only (get-vote (voter principal) (content-id uint))
  (map-get? votes { voter: voter, content-id: content-id })
)

;; Get current course ID counter
(define-read-only (get-next-course-id)
  (var-get next-course-id)
)

;; Get current content ID counter
(define-read-only (get-next-content-id)
  (var-get next-content-id)
)

;; private functions
;;

