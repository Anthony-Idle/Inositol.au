import Foundation

struct ReviewStep: Identifiable {
    var id = UUID()
    var name: String
    var instructions: [String]
    var durationSeconds: Int

    static let defaultSteps: [ReviewStep] = [
        ReviewStep(
            name: "Collect Loose Papers",
            instructions: [
                "Gather all physical loose papers from your desk, bag, and pockets",
                "Collect sticky notes, receipts, business cards, and any physical reminders",
                "Drop everything into your physical in-tray"
            ],
            durationSeconds: 300
        ),
        ReviewStep(
            name: "Process Your Notes",
            instructions: [
                "Go through notebook pages and digital notes since your last review",
                "Extract any actions, projects, or reference material",
                "Add each item to the appropriate list or reference file"
            ],
            durationSeconds: 300
        ),
        ReviewStep(
            name: "Empty Your Head",
            instructions: [
                "Do a full mind sweep — capture everything that has your attention",
                "Use the GTD trigger list if needed (projects, commitments, worries, ideas)",
                "Write each item on a separate capture note",
                "Don't process yet — just get it out of your head"
            ],
            durationSeconds: 600
        ),
        ReviewStep(
            name: "Process Your Inbox",
            instructions: [
                "Process every item in your physical and digital in-trays to zero",
                "For each item: Is it actionable? If yes, do it (2 min), delegate, or defer",
                "If not actionable: trash it, incubate it, or file it as reference"
            ],
            durationSeconds: 600
        ),
        ReviewStep(
            name: "Review Action Lists",
            instructions: [
                "Context lists are your Next Actions organised by where or how you work — e.g. @Computer, @Phone, @Errands, @Home, @Email",
                "Go through every Next Action on each of your context lists",
                "Mark off completed items",
                "Ensure every remaining item is still current and in the right list",
                "Delete or move items that are no longer relevant"
            ],
            durationSeconds: 600
        ),
        ReviewStep(
            name: "Review Previous Calendar",
            instructions: [
                "Review the past two weeks of calendar entries",
                "Capture any outstanding actions from past meetings or events",
                "Note any follow-ups that haven't been added to your lists yet"
            ],
            durationSeconds: 300
        ),
        ReviewStep(
            name: "Review Upcoming Calendar",
            instructions: [
                "Review the next two to four weeks of calendar entries",
                "Identify prep work needed for upcoming meetings or events",
                "Add any required actions to your Next Actions lists"
            ],
            durationSeconds: 300
        ),
        ReviewStep(
            name: "Review Waiting For List",
            instructions: [
                "Review everything you are waiting on from others",
                "Send follow-up nudges for overdue items",
                "Remove items that have been received or are no longer relevant",
                "Add dates to waiting items that don't have them"
            ],
            durationSeconds: 300
        ),
        ReviewStep(
            name: "Review Project List",
            instructions: [
                "Review every active project — ensure each has at least one Next Action",
                "Identify any stalled projects and add an action to get them moving",
                "Mark completed projects as done",
                "Are there any new projects you should add?"
            ],
            durationSeconds: 600
        ),
        ReviewStep(
            name: "Review Project Plans & Support",
            instructions: [
                "Review project support materials and plans for key projects",
                "Capture any new actions or waiting-for items from project notes",
                "Update project plans if they have changed"
            ],
            durationSeconds: 300
        ),
        ReviewStep(
            name: "Review Someday/Maybe",
            instructions: [
                "Review your someday/maybe list",
                "Activate any items you now want to commit to — move to projects or actions",
                "Delete items that are no longer interesting",
                "Add any new someday/maybe ideas that surfaced during this review"
            ],
            durationSeconds: 300
        ),
        ReviewStep(
            name: "Review Goals & Vision",
            instructions: [
                "Review your 1–2 year goals and current areas of focus",
                "Review your 3–5 year vision and longer-term aspirations",
                "Consider your life purpose and guiding principles",
                "Capture any new projects or actions inspired by this altitude review"
            ],
            durationSeconds: 600
        ),
        ReviewStep(
            name: "Be Creative & Courageous",
            instructions: [
                "Is there anything you have been avoiding that needs attention?",
                "Are there bold moves or experiments you want to commit to?",
                "Any creative ideas not yet captured anywhere?",
                "Celebrate — you have just completed your Weekly Review!"
            ],
            durationSeconds: 300
        )
    ]

    static var defaultTotalSeconds: Int {
        defaultSteps.reduce(0) { $0 + $1.durationSeconds }
    }
}
