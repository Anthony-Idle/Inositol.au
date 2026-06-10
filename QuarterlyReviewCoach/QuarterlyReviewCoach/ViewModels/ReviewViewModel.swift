import Foundation
import AudioToolbox

enum AppScreen: Equatable {
    case home, setup, review, debrief, complete
}

class ReviewViewModel: ObservableObject {

    // MARK: - Navigation
    @Published var screen: AppScreen = .home

    // MARK: - Areas
    @Published var areaNames: [String] = AreaSettings.load()

    // MARK: - Setup
    @Published var steps: [ReviewStep] = []
    @Published var totalMinutes: Int = 120 {
        didSet { redistributeTime() }
    }

    // MARK: - Review
    @Published var currentStepIndex: Int = 0
    @Published var secondsRemaining: Int = 0
    @Published var isRunning: Bool = false
    @Published var isPaused: Bool = false
    @Published var stepExpired: Bool = false
    @Published var sessionElapsedSeconds: Int = 0

    // MARK: - Records
    @Published var currentRecord: QuarterRecord = QuarterRecord(quarterLabel: QuarterRecord.currentQuarterLabel())
    @Published var pastRecords: [QuarterRecord] = []

    private var ticker: Timer?
    private let storageKey = "quarterlyReviewRecords"

    init() {
        steps = ReviewStep.generateSteps(areaNames: areaNames)
        redistributeTime()
        loadRecords()
    }

    // MARK: - Computed

    var currentStep: ReviewStep? {
        guard currentStepIndex < steps.count else { return nil }
        return steps[currentStepIndex]
    }

    var stepProgress: Double {
        guard let step = currentStep, step.durationSeconds > 0 else { return 0 }
        return Double(step.durationSeconds - secondsRemaining) / Double(step.durationSeconds)
    }

    var overallProgress: Double {
        let totalAll = steps.reduce(0) { $0 + $1.durationSeconds }
        guard totalAll > 0 else { return 0 }
        let done = steps.prefix(currentStepIndex).reduce(0) { $0 + $1.durationSeconds }
        let stepElapsed = (currentStep?.durationSeconds ?? 0) - secondsRemaining
        return Double(done + stepElapsed) / Double(totalAll)
    }

    var formattedRemaining: String { format(seconds: secondsRemaining) }
    var formattedElapsed: String   { format(seconds: sessionElapsedSeconds) }

    var totalAllocatedMinutes: Int {
        steps.reduce(0) { $0 + $1.durationSeconds } / 60
    }

    var currentPhaseSteps: [ReviewStep] {
        guard let current = currentStep else { return [] }
        return steps.filter { $0.phase == current.phase }
    }

    var currentPhaseStepNumber: Int {
        guard let current = currentStep else { return 0 }
        return (currentPhaseSteps.firstIndex(where: { $0.id == current.id }) ?? 0) + 1
    }

    // MARK: - Area configuration

    func saveAreaNames() {
        AreaSettings.save(areaNames)
        let oldDurations = steps.map { $0.durationSeconds }
        steps = ReviewStep.generateSteps(areaNames: areaNames)
        for i in steps.indices where i < oldDurations.count {
            steps[i].durationSeconds = oldDurations[i]
        }
    }

    // MARK: - Time setup

    func redistributeTime() {
        let total = totalMinutes * 60
        let defaultTotal = steps.reduce(0) { $0 + $1.defaultDurationSeconds }
        guard defaultTotal > 0 else { return }
        for i in steps.indices {
            let fraction = Double(steps[i].defaultDurationSeconds) / Double(defaultTotal)
            steps[i].durationSeconds = max(30, Int(fraction * Double(total)))
        }
    }

    func stepMinutes(_ index: Int) -> Int { steps[index].durationSeconds / 60 }

    func setStepMinutes(_ index: Int, minutes: Int) {
        steps[index].durationSeconds = max(1, minutes) * 60
    }

    // MARK: - Flow

    func startSetup() {
        currentRecord = QuarterRecord(quarterLabel: QuarterRecord.currentQuarterLabel())
        currentRecord.areaNames = areaNames
        screen = .setup
    }

    func startReview() {
        currentStepIndex = 0
        sessionElapsedSeconds = 0
        beginStep()
        screen = .review
    }

    func nextStep() {
        stopTimer()
        currentStepIndex += 1
        if currentStepIndex >= steps.count {
            finishTimer()
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

    func pause()  { stopTimer(); isPaused = true }
    func resume() { isPaused = false; startTimer() }

    func finishTimer() {
        stopTimer()
        currentRecord.sessionElapsedSeconds = sessionElapsedSeconds
        currentRecord.stepsCompleted = steps.count
        currentRecord.achievementRates = Array(repeating: 50, count: areaNames.count)
        screen = .debrief
    }

    func completeDebrief() {
        currentRecord.completedDate = Date()
        screen = .complete
    }

    func saveAndGoHome() {
        pastRecords.append(currentRecord)
        saveRecords()
        reset()
        screen = .home
    }

    func cancelToHome() {
        reset()
        screen = .home
    }

    func reset() {
        stopTimer()
        currentStepIndex = 0
        secondsRemaining = 0
        sessionElapsedSeconds = 0
        isRunning = false
        isPaused = false
        stepExpired = false
        steps = ReviewStep.generateSteps(areaNames: areaNames)
        redistributeTime()
        currentRecord = QuarterRecord(quarterLabel: QuarterRecord.currentQuarterLabel())
    }

    // MARK: - Timer

    private func beginStep() {
        guard currentStepIndex < steps.count else { finishTimer(); return }
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
            AudioServicesPlayAlertSoundWithCompletion(kSystemSoundID_Vibrate) {}
            AudioServicesPlaySystemSound(1304)
        }
    }

    private func format(seconds: Int) -> String {
        String(format: "%02d:%02d", seconds / 60, seconds % 60)
    }

    // MARK: - Persistence

    private func loadRecords() {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let decoded = try? JSONDecoder().decode([QuarterRecord].self, from: data)
        else { return }
        pastRecords = decoded
    }

    private func saveRecords() {
        guard let encoded = try? JSONEncoder().encode(pastRecords) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}
