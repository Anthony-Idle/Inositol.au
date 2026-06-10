import SwiftUI

struct DebriefView: View {
    @ObservedObject var vm: ReviewViewModel

    var body: some View {
        NavigationView {
            Form {
                debriefSection
                goalsSection
                stopDoingSection
                completeSection
            }
            .navigationTitle("Debrief")
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Debrief questions

    private var debriefSection: some View {
        Section {
            debriefField(
                label: "What was this quarter's biggest win?",
                placeholder: "The thing you're most proud of...",
                text: Binding(
                    get: { vm.currentRecord.biggestWin },
                    set: { vm.currentRecord.biggestWin = $0 }
                )
            )
            debriefField(
                label: "What was the main thing you avoided?",
                placeholder: "Be honest — this is where the growth is...",
                text: Binding(
                    get: { vm.currentRecord.mainAvoided },
                    set: { vm.currentRecord.mainAvoided = $0 }
                )
            )
            debriefField(
                label: "What cost you the most time/energy with least return?",
                placeholder: "The thing you'd do differently...",
                text: Binding(
                    get: { vm.currentRecord.mostCostly },
                    set: { vm.currentRecord.mostCostly = $0 }
                )
            )
            debriefField(
                label: "What are you carrying into next quarter that should have been killed?",
                placeholder: "The zombie project or habit that needs to end...",
                text: Binding(
                    get: { vm.currentRecord.carryingForward },
                    set: { vm.currentRecord.carryingForward = $0 }
                )
            )
            debriefField(
                label: "The one thing that would make next quarter a success:",
                placeholder: "One specific, concrete outcome...",
                text: Binding(
                    get: { vm.currentRecord.oneThingForSuccess },
                    set: { vm.currentRecord.oneThingForSuccess = $0 }
                )
            )
        } header: {
            Label("Quarter Debrief", systemImage: "text.quote")
        }
    }

    // MARK: - Focus goals

    private var goalsSection: some View {
        Section {
            ForEach(0..<5, id: \.self) { i in
                HStack {
                    Text("\(i + 1).")
                        .font(.subheadline.monospacedDigit())
                        .foregroundColor(.secondary)
                        .frame(width: 20)
                    TextField("Goal \(i + 1)", text: goalBinding(i))
                        .font(.body)
                }
            }
        } header: {
            Label("Next Quarter Focus Goals", systemImage: "target")
        } footer: {
            Text("Write concrete outcomes, not activities.")
        }
    }

    // MARK: - Stop doing

    private var stopDoingSection: some View {
        Section {
            ForEach(0..<3, id: \.self) { i in
                HStack {
                    Image(systemName: "xmark.circle")
                        .foregroundColor(.red.opacity(0.6))
                    TextField("Stop doing this...", text: stopBinding(i))
                        .font(.body)
                }
            }
        } header: {
            Label("Stop Doing List", systemImage: "slash.circle")
        } footer: {
            Text("At least 1–2 things to cut or pause this quarter.")
        }
    }

    // MARK: - Complete button

    private var completeSection: some View {
        Section {
            Button(action: vm.completeDebrief) {
                HStack {
                    Spacer()
                    Label("Complete Review", systemImage: "checkmark.seal.fill")
                        .font(.headline)
                    Spacer()
                }
            }
            .foregroundColor(.white)
            .listRowBackground(Color.accentColor)
        }
    }

    // MARK: - Helpers

    private func debriefField(label: String, placeholder: String, text: Binding<String>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(label)
                .font(.subheadline.bold())
            TextField(placeholder, text: text, axis: .vertical)
                .font(.body)
                .lineLimit(3, reservesSpace: true)
        }
        .padding(.vertical, 4)
    }

    private func goalBinding(_ index: Int) -> Binding<String> {
        Binding(
            get: {
                index < vm.currentRecord.focusGoals.count
                    ? vm.currentRecord.focusGoals[index] : ""
            },
            set: {
                if index < vm.currentRecord.focusGoals.count {
                    vm.currentRecord.focusGoals[index] = $0
                }
            }
        )
    }

    private func stopBinding(_ index: Int) -> Binding<String> {
        Binding(
            get: {
                index < vm.currentRecord.stopDoingItems.count
                    ? vm.currentRecord.stopDoingItems[index] : ""
            },
            set: {
                if index < vm.currentRecord.stopDoingItems.count {
                    vm.currentRecord.stopDoingItems[index] = $0
                }
            }
        )
    }
}
