;; STX GreenGrid - Renewable Energy Trading Smart Contract

;; Define constants
(define-constant grid-operator tx-sender)
(define-constant err-operator-only (err u100))
(define-constant err-insufficient-power (err u101))
(define-constant err-transaction-failed (err u102))
(define-constant err-invalid-tariff (err u103))
(define-constant err-invalid-capacity (err u104))
(define-constant err-invalid-percentage (err u105))
(define-constant err-compensation-failed (err u106))
(define-constant err-self-trading-prohibited (err u107))
(define-constant err-grid-capacity-exceeded (err u108))
(define-constant err-invalid-capacity-limit (err u109))

;; Define data variables
(define-data-var green-tariff uint u100) ;; Tariff per kWh in microstacks (1 STX = 1,000,000 microstacks)
(define-data-var max-producer-capacity uint u10000) ;; Maximum energy a producer can contribute (in kWh)
(define-data-var platform-fee-rate uint u5) ;; Platform fee rate in percentage (e.g., 5 means 5%)
(define-data-var buyback-rate uint u90) ;; Buyback rate in percentage (e.g., 90 means 90% of current tariff)
(define-data-var total-grid-capacity uint u1000000) ;; Total grid capacity limit (in kWh)
(define-data-var active-power-supply uint u0) ;; Current total power in the grid (in kWh)

;; Define data maps
(define-map producer-power-balance principal uint)
(define-map consumer-credit-balance principal uint)
(define-map power-marketplace {producer: principal} {capacity: uint, tariff: uint})

;; Private functions

;; Calculate platform fee
(define-private (calculate-platform-fee (amount uint))
  (/ (* amount (var-get platform-fee-rate)) u100))

;; Calculate buyback compensation
(define-private (calculate-buyback-compensation (amount uint))
  (/ (* amount (var-get green-tariff) (var-get buyback-rate)) u100))

;; Update grid power supply
(define-private (update-grid-supply (amount int))
  (let (
    (current-supply (var-get active-power-supply))
    (new-supply (if (< amount 0)
                     (if (>= current-supply (to-uint (- 0 amount)))
                         (- current-supply (to-uint (- 0 amount)))
                         u0)
                     (+ current-supply (to-uint amount))))
  )
    (asserts! (<= new-supply (var-get total-grid-capacity)) err-grid-capacity-exceeded)
    (var-set active-power-supply new-supply)
    (ok true)))

;; Public functions

;; Set green energy tariff (only grid operator)
(define-public (set-green-tariff (new-tariff uint))
  (begin
    (asserts! (is-eq tx-sender grid-operator) err-operator-only)
    (asserts! (> new-tariff u0) err-invalid-tariff) ;; Ensure tariff is greater than 0
    (var-set green-tariff new-tariff)
    (ok true)))

;; Set platform fee rate (only grid operator)
(define-public (set-platform-fee-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender grid-operator) err-operator-only)
    (asserts! (<= new-rate u100) err-invalid-percentage) ;; Ensure rate is not more than 100%
    (var-set platform-fee-rate new-rate)
    (ok true)))

;; Set buyback rate (only grid operator)
(define-public (set-buyback-rate (new-rate uint))
  (begin
    (asserts! (is-eq tx-sender grid-operator) err-operator-only)
    (asserts! (<= new-rate u100) err-invalid-percentage) ;; Ensure rate is not more than 100%
    (var-set buyback-rate new-rate)
    (ok true)))

;; Set total grid capacity (only grid operator)
(define-public (set-total-grid-capacity (new-capacity uint))
  (begin
    (asserts! (is-eq tx-sender grid-operator) err-operator-only)
    (asserts! (>= new-capacity (var-get active-power-supply)) err-invalid-capacity-limit)
    (var-set total-grid-capacity new-capacity)
    (ok true)))

;; List power for trading
(define-public (list-power-for-trading (capacity uint) (tariff uint))
  (let (
    (current-balance (default-to u0 (map-get? producer-power-balance tx-sender)))
    (current-listed (get capacity (default-to {capacity: u0, tariff: u0} (map-get? power-marketplace {producer: tx-sender}))))
    (new-listed (+ capacity current-listed))
  )
    (asserts! (> capacity u0) err-invalid-capacity) ;; Ensure capacity is greater than 0
    (asserts! (> tariff u0) err-invalid-tariff) ;; Ensure tariff is greater than 0
    (asserts! (>= current-balance new-listed) err-insufficient-power)
    (try! (update-grid-supply (to-int capacity)))
    (map-set power-marketplace {producer: tx-sender} {capacity: new-listed, tariff: tariff})
    (ok true)))

;; Remove power from trading
(define-public (remove-power-from-trading (capacity uint))
  (let (
    (current-listed (get capacity (default-to {capacity: u0, tariff: u0} (map-get? power-marketplace {producer: tx-sender}))))
  )
    (asserts! (>= current-listed capacity) err-insufficient-power)
    (try! (update-grid-supply (to-int (- capacity))))
    (map-set power-marketplace {producer: tx-sender} 
             {capacity: (- current-listed capacity), 
              tariff: (get tariff (default-to {capacity: u0, tariff: u0} (map-get? power-marketplace {producer: tx-sender})))})
    (ok true)))

;; Purchase power from producer
(define-public (purchase-power-from-producer (producer principal) (capacity uint))
  (let (
    (marketplace-data (default-to {capacity: u0, tariff: u0} (map-get? power-marketplace {producer: producer})))
    (power-cost (* capacity (get tariff marketplace-data)))
    (platform-fee (calculate-platform-fee power-cost))
    (total-payment (+ power-cost platform-fee))
    (producer-power (default-to u0 (map-get? producer-power-balance producer)))
    (consumer-credits (default-to u0 (map-get? consumer-credit-balance tx-sender)))
    (producer-credits (default-to u0 (map-get? consumer-credit-balance producer)))
    (operator-credits (default-to u0 (map-get? consumer-credit-balance grid-operator)))
  )
    (asserts! (not (is-eq tx-sender producer)) err-self-trading-prohibited)
    (asserts! (> capacity u0) err-invalid-capacity) ;; Ensure capacity is greater than 0
    (asserts! (>= (get capacity marketplace-data) capacity) err-insufficient-power)
    (asserts! (>= producer-power capacity) err-insufficient-power)
    (asserts! (>= consumer-credits total-payment) err-insufficient-power)
    
    ;; Update producer's power balance and marketplace listing
    (map-set producer-power-balance producer (- producer-power capacity))
    (map-set power-marketplace {producer: producer} 
             {capacity: (- (get capacity marketplace-data) capacity), tariff: (get tariff marketplace-data)})
    
    ;; Update consumer's credit and power balance
    (map-set consumer-credit-balance tx-sender (- consumer-credits total-payment))
    (map-set producer-power-balance tx-sender (+ (default-to u0 (map-get? producer-power-balance tx-sender)) capacity))
    
    ;; Update producer's and grid operator's credit balance
    (map-set consumer-credit-balance producer (+ producer-credits power-cost))
    (map-set consumer-credit-balance grid-operator (+ operator-credits platform-fee))
    
    (ok true)))

;; Buyback power to grid
(define-public (buyback-power-to-grid (capacity uint))
  (let (
    (producer-power (default-to u0 (map-get? producer-power-balance tx-sender)))
    (compensation-amount (calculate-buyback-compensation capacity))
    (grid-credits (default-to u0 (map-get? consumer-credit-balance grid-operator)))
  )
    (asserts! (> capacity u0) err-invalid-capacity) ;; Ensure capacity is greater than 0
    (asserts! (>= producer-power capacity) err-insufficient-power)
    (asserts! (>= grid-credits compensation-amount) err-compensation-failed)
    
    ;; Update producer's power balance
    (map-set producer-power-balance tx-sender (- producer-power capacity))
    
    ;; Update producer's and grid operator's credit balance
    (map-set consumer-credit-balance tx-sender (+ (default-to u0 (map-get? consumer-credit-balance tx-sender)) compensation-amount))
    (map-set consumer-credit-balance grid-operator (- grid-credits compensation-amount))
    
    ;; Add power back to grid operator's balance
    (map-set producer-power-balance grid-operator (+ (default-to u0 (map-get? producer-power-balance grid-operator)) capacity))
    
    ;; Update grid supply
    (try! (update-grid-supply (to-int (- capacity))))
    
    (ok true)))

;; Read-only functions

;; Get current green tariff
(define-read-only (get-green-tariff)
  (ok (var-get green-tariff)))

;; Get current platform fee rate
(define-read-only (get-platform-fee-rate)
  (ok (var-get platform-fee-rate)))

;; Get current buyback rate
(define-read-only (get-buyback-rate)
  (ok (var-get buyback-rate)))

;; Get producer's power balance
(define-read-only (get-power-balance (producer principal))
  (ok (default-to u0 (map-get? producer-power-balance producer))))

;; Get consumer's credit balance
(define-read-only (get-credit-balance (consumer principal))
  (ok (default-to u0 (map-get? consumer-credit-balance consumer))))

;; Get power listing in marketplace
(define-read-only (get-power-marketplace-listing (producer principal))
  (ok (default-to {capacity: u0, tariff: u0} (map-get? power-marketplace {producer: producer}))))

;; Get maximum producer capacity
(define-read-only (get-max-producer-capacity)
  (ok (var-get max-producer-capacity)))

;; Get active power supply
(define-read-only (get-active-power-supply)
  (ok (var-get active-power-supply)))

;; Get total grid capacity
(define-read-only (get-total-grid-capacity)
  (ok (var-get total-grid-capacity)))

;; Set maximum producer capacity (only grid operator)
(define-public (set-max-producer-capacity (new-max uint))
  (begin
    (asserts! (is-eq tx-sender grid-operator) err-operator-only)
    (asserts! (> new-max u0) err-invalid-capacity) ;; Ensure new max is greater than 0
    (var-set max-producer-capacity new-max)
    (ok true)))