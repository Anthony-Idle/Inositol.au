import Foundation

enum ReviewPhase: String, Codable, Equatable {
    case getClear = "Get Clear"
    case getCurrent = "Get Current"
    case getCreative = "Get Creative"

    var number: Int {
        switch self {
        case .getClear:   return 1
        case .getCurrent: return 2
        case .getCreative: return 3
        }
    }

    var icon: String {
        switch self {
        case .getClear:   return "tray.full"
        case .getCurrent: return "magnifyingglass"
        case .getCreative: return "lightbulb"
        }
    }
}

struct ReviewStep: Identifiable, Codable {
    var id: UUID = UUID()
    var name: String
    var instructions: [String]
    var durationSeconds: Int
    var phase: ReviewPhase
    var subSection: String?

    static let defaultSteps: [ReviewStep] = [
        // PHASE 1 — GET CLEAR
        ReviewStep(
            name: "Process All Inboxes",
            instructions: [
                "Email inbox to zero — action, archive, or delete everything",
                "Clear phone notes, voice memos, and photos of whiteboards",
                "Process any physical paper into your system"
            ],
            durationSeconds: 900, phase: .getClear
        ),
        ReviewStep(
            name: "Full Brain Dump",
            instructions: [
                "Write down everything still floating in your head",
                "Incomplete thoughts, nagging worries, half-formed ideas — all of it",
                "Don't organise yet, just capture"
            ],
            durationSeconds: 600, phase: .getClear
        ),
        ReviewStep(
            name: "Review Open Loops",
            instructions: [
                "Look at last quarter's open loops",
                "For each: close it, capture it properly, or kill it",
                "Nothing carries over uncaptured"
            ],
            durationSeconds: 600, phase: .getClear
        ),

        // PHASE 2 — GET CURRENT
        ReviewStep(
            name: "Projects Audit",
            instructions: [
                "Open your Projects database",
                "For each project: still active? Still relevant? Archive if not",
                "Every active project needs at least one Next Action",
                "Flag anything not moved in 30+ days — it needs a decision"
            ],
            durationSeconds: 1200, phase: .getCurrent, subSection: "Projects"
        ),
        ReviewStep(
            name: "Areas of Responsibility",
            instructions: [
                "Review each Area: Work, Health, Finance, Home, Relationships, Creative",
                "What's been neglected this quarter? Name it honestly",
                "Does any Area need a new project to address what's slipping?"
            ],
            durationSeconds: 900, phase: .getCurrent, subSection: "Areas"
        ),
        ReviewStep(
            name: "Goals Review",
            instructions: [
                "Open your Goals database",
                "Are your current projects actually moving each goal forward?",
                "Archive any Goals that no longer reflect where you're heading",
                "Review milestones — what got hit? What got ignored?"
            ],
            durationSeconds: 900, phase: .getCurrent, subSection: "Goals"
        ),
        ReviewStep(
            name: "Previous Quarter Review",
            instructions: [
                "What did you say mattered last quarter?",
                "What actually got done vs. what got avoided?",
                "Name the gap honestly — this is where you learn the most"
            ],
            durationSeconds: 900, phase: .getCurrent, subSection: "Previous Quarter"
        ),

        // PHASE 3 — GET CREATIVE
        ReviewStep(
            name: "Set Next Quarter Goals",
            instructions: [
                "Write 3–5 focus goals for the coming quarter",
                "Concrete outcomes, not activities",
                "For each goal: does a project exist? Create one if not"
            ],
            durationSeconds: 900, phase: .getCreative
        ),
        ReviewStep(
            name: "Stop Doing List",
            instructions: [
                "Identify at least 1–2 things to cut or pause this quarter",
                "What cost you the most energy with least return?",
                "Be specific — vague intentions don't stick"
            ],
            durationSeconds: 600, phase: .getCreative
        ),
        ReviewStep(
            name: "Review Your Vision",
            instructions: [
                "Look at your Horizon 4–5 vision",
                "Still pointing the right direction?",
                "Does anything need updating based on this quarter?"
            ],
            durationSeconds: 600, phase: .getCreative
        ),
        ReviewStep(
            name: "Schedule Next Review",
            instructions: [
                "Pick a date for your next Quarterly Review before closing",
                "Book it in your calendar now — protect the time",
                "Aim for a consistent cadence: start of each new quarter"
            ],
            durationSeconds: 300, phase: .getCreative
        ),
    ]

    static var defaultTotalSeconds: Int {
        defaultSteps.reduce(0) { $0 + $1.durationSeconds }
    }
}
