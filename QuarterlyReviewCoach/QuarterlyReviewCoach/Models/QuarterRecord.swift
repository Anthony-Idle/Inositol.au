import Foundation

struct QuarterRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var quarterLabel: String
    var startDate: Date
    var completedDate: Date?
    var sessionElapsedSeconds: Int = 0
    var stepsCompleted: Int = 0
    var areaNames: [String] = AreaSettings.defaultNames
    var achievementRates: [Int] = Array(repeating: 50, count: 8)
    var causeAnalysis: String = ""
    var oneThingForSuccess: String = ""
    var nextReviewDate: Date?

    init(quarterLabel: String) {
        self.quarterLabel = quarterLabel
        self.startDate = Date()
    }

    var formattedElapsed: String {
        String(format: "%02d:%02d", sessionElapsedSeconds / 60, sessionElapsedSeconds % 60)
    }

    var averageAchievement: Int {
        guard !achievementRates.isEmpty else { return 0 }
        return achievementRates.reduce(0, +) / achievementRates.count
    }

    static func currentQuarterLabel() -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let year = calendar.component(.year, from: Date())
        let quarter = (month - 1) / 3 + 1
        return "Q\(quarter) \(year)"
    }
}
