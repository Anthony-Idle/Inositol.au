import Foundation
import AudioToolbox
import Combine

class ReviewViewModel: ObservableObject {

    // MARK: - Setup state
    @Published var steps: [ReviewStep] = ReviewStep.defaultSteps
    @Published var totalMinutes: Int = 60 {
        didSet { redistributeTime() }
    }

    // MARK: - Review state
    @Published var currentStepIndex: Int = 0
    @Published var secondsRemaining: Int = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var isComplete: Bool = false
    @Published var sessionElapsedSeconds: Int = 0
    @Published var stepExpired: Bool = false

    private var ticker: Timer?

    init() {
        redistributeTime()
    }

    // MARK: - Computed

    var currentStep: ReviewStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }

    var stepProgress: Double {
        guard let step = currentStep, step.durationSeconds > 0 else { return 0 }
        let elapsed = step.durationSeconds - secondsRemaining
        return Double(elapsed) / Double(step.durationSeconds)
    }

    var overallProgress: Double {
        let totalAll = steps.reduce(0) { $0 + $1.durationSeconds }
        guard totalAll > 0 else { return 0 }
        let done = steps.prefix(currentStepIndex).reduce(0) { $0 + $1.durationSeconds }
        let stepElapsed = (currentStep?.durationSeconds ?? 0) - secondsRemaining
        return Double(done + stepElapsed) / Double(totalAll)
    }

    var formattedRemaining: String {
        format(seconds: secondsRemaining)
    }

    var formattedElapsed: String {
        format(seconds: sessionElapsedSeconds)
    }

    var totalAllocatedMinutes: Int {
        steps.reduce(0) { $0 + $1.durationSeconds } / 60
    }

    // MARK: - Setup

    func redistributeTime() {
        let total = totalMinutes * 60
        let defaultTotal = ReviewStep.defaultTotalSeconds
        for i in steps.indices {
            let defaultDuration = ReviewStep.defaultSteps[i].durationSeconds
            let fraction = Double(defaultDuration) / Double(defaultTotal)
            steps[i].durationSeconds = max(30, Int(fraction * Double(total)))
        }
    }

    func stepMinutes(_ index: Int) -> Int {
        steps[index].durationSeconds / 60
    }

    func setStepMinutes(_ index: Int, minutes: Int) {
        steps[index].durationSeconds = max(1, minutes) * 60
    }

    // MARK: - Review control

    func startReview() {
        currentStepIndex = 0
        isComplete = false
        sessionElapsedSeconds = 0
        beginStep()
    }

    func nextStep() {
        stopTimer()
        currentStepIndex += 1
        if currentStepIndex >= steps.count {
            finishReview()
        } else {
            beginStep()
        }
    }

    func previousStep() {
        guard currentStepIndex > 0 else { return }
        stopTimer()
        currentStepIndex -= 1
        beginStep()
    }

    func pause() {
        stopTimer()
        isPaused = true
    }

    func resume() {
        isPaused = false
        startTimer()
    }

    func reset() {
        stopTimer()
        currentStepIndex = 0
        secondsRemaining = 0
        sessionElapsedSeconds = 0
        isComplete = false
        isPaused = false
        stepExpired = false
        redistributeTime()
    }

    // MARK: - Private

    private func beginStep() {
        guard currentStepIndex < steps.count else { finishReview(); return }
        secondsRemaining = steps[currentStepIndex].durationSeconds
        stepExpired = false
        isPaused = false
        startTimer()
    }

    private func startTimer() {
        isRunning = true
        ticker = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }

    private func stopTimer() {
        ticker?.invalidate()
        ticker = nil
        isRunning = false
    }

    private func tick() {
        sessionElapsedSeconds += 1
        if secondsRemaining > 0 {
            secondsRemaining -= 1
        } else if !stepExpired {
            stepExpired = true
            playAlarm()
        }
    }

    private func finishReview() {
        isRunning = false
        isComplete = true
        playCompletion()
    }

    private func playAlarm() {
        // Vibrate + system alert sound
        AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate) {}
        AudioServicesPlaySystemSound(1304) // "Anticipate" style ping
    }

    private func playCompletion() {
        AudioServicesPlaySystemSound(1025)
    }

    private func format(seconds: Int) -> String {
        let m = seconds / 60
        let s = seconds % 60
        return String(format: "%02d:%02d", m, s)
    }
}
