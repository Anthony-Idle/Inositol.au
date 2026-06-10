import Foundation

struct QuarterRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var quarterLabel: String
    var startDate: Date
    var completedDate: Date?
    var sessionElapsedSeconds: Int = 0
    var stepsCompleted: Int = 0
    var biggestWin: String = ""
    var mainAvoided: String = ""
    var mostCostly: String = ""
    var carryingForward: String = ""
    var oneThingForSuccess: String = ""
    var focusGoals: [String] = Array(repeating: "", count: 5)
    var stopDoingItems: [String] = Array(repeating: "", count: 3)
    var nextReviewDate: Date?

    init(quarterLabel: String) {
        self.quarterLabel = quarterLabel
        self.startDate = Date()
    }

    var formattedElapsed: String {
        let m = sessionElapsedSeconds / 60
        let s = sessionElapsedSeconds % 60
        return String(format: "%02d:%02d", m, s)
    }

    static func currentQuarterLabel() -> String {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: Date())
        let year = calendar.component(.year, from: Date())
        let quarter = (month - 1) / 3 + 1
        return "Q\(quarter) \(year)"
    }
}
