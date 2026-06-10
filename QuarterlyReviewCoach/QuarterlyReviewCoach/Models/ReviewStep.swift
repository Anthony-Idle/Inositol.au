import Foundation

enum ReviewPhase: String, Codable, Equatable {
    case vision  = "Vision"
    case areas   = "Areas of Focus"
    case action  = "Cull & Plan"

    var number: Int {
        switch self {
        case .vision: return 1
        case .areas:  return 2
        case .action: return 3
        }
    }

    var icon: String {
        switch self {
        case .vision: return "mountain.2"
        case .areas:  return "square.grid.3x3"
        case .action: return "scissors"
        }
    }

    var altitude: String {
        switch self {
        case .vision: return "50,000 ft"
        case .areas:  return "40,000 ft"
        case .action: return "Ground Level"
        }
    }
}

struct ReviewStep: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var instructions: [String]
    var durationSeconds: Int
    var defaultDurationSeconds: Int
    var phase: ReviewPhase

    init(name: String, instructions: [String], durationSeconds: Int, phase: ReviewPhase) {
        self.name = name
        self.instructions = instructions
        self.durationSeconds = durationSeconds
        self.defaultDurationSeconds = durationSeconds
        self.phase = phase
    }

    static func generateSteps(areaNames: [String]) -> [ReviewStep] {
        var steps: [ReviewStep] = []

        steps.append(ReviewStep(
            name: "Life Goal",
            instructions: [
                "Read your life goal at the centre of your 9x9",
                "Is it still the right goal? Does it still pull you forward?",
                "If it needs updating, note it down — don't edit mid-session",
                "Reconnect with your deeper why before reviewing the areas below"
            ],
            durationSeconds: 300, phase: .vision
        ))

        for name in areaNames {
            steps.append(ReviewStep(
                name: name,
                instructions: [
                    "Is this area's goal for the year still right?",
                    "Do you have active projects supporting it?",
                    "What milestones were hit this quarter?",
                    "What's stalled or needs a decision?",
                    "Does anything need to change — goal, project, or approach?"
                ],
                durationSeconds: 600, phase: .areas
            ))
        }

        steps.append(ReviewStep(
            name: "Cull Last Quarter",
            instructions: [
                "What projects or commitments are not moving any area goal forward?",
                "Kill or archive anything that doesn't serve a goal — don't drag it forward",
                "What habits or routines stopped supporting your goals? End them now",
                "Be ruthless — dead weight costs more than it looks like"
            ],
            durationSeconds: 600, phase: .action
        ))

        steps.append(ReviewStep(
            name: "Next Quarter Commitments",
            instructions: [
                "For each area: what is the one project or milestone to hit next quarter?",
                "Are there any new projects to create?",
                "What will you deliberately not do next quarter?",
                "Schedule your next Quarterly Review before closing this session"
            ],
            durationSeconds: 600, phase: .action
        ))

        return steps
    }

    static func defaultTotalSeconds(areaCount: Int = 8) -> Int {
        300 + (areaCount * 600) + 600 + 600
    }
}
