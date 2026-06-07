import SwiftUI

struct SetupView: View {
    @ObservedObject var vm: ReviewViewModel

    var body: some View {
        NavigationView {
            Form {
                Section {
                    totalTimePicker
                } header: {
                    Text("Total Review Duration")
                } footer: {
                    Text("Time is distributed across steps proportionally. Adjust individual steps below.")
                }

                Section {
                    ForEach(vm.steps.indices, id: \.self) { i in
                        StepAllocationRow(
                            step: vm.steps[i],
                            minutes: vm.stepMinutes(i),
                            onDecrement: {
                                let current = vm.stepMinutes(i)
                                if current > 1 { vm.setStepMinutes(i, minutes: current - 1) }
                            },
                            onIncrement: {
                                vm.setStepMinutes(i, minutes: vm.stepMinutes(i) + 1)
                            }
                        )
                    }
                } header: {
                    HStack {
                        Text("Step Allocations")
                        Spacer()
                        Text("Total: \(vm.totalAllocatedMinutes) min")
                            .foregroundColor(
                                abs(vm.totalAllocatedMinutes - vm.totalMinutes) <= 1
                                    ? .secondary : .orange
                            )
                    }
                }

                Section {
                    Button(action: vm.startReview) {
                        HStack {
                            Spacer()
                            Label("Start Weekly Review", systemImage: "play.circle.fill")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.accentColor)
                }
            }
            .navigationTitle("GTD Weekly Review")
        }
        .navigationViewStyle(.stack)
    }

    private var totalTimePicker: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.accentColor)
                Text("\(vm.totalMinutes) minutes")
                    .font(.title2.bold())
                Spacer()
            }
            Slider(
                value: Binding(
                    get: { Double(vm.totalMinutes) },
                    set: { vm.totalMinutes = Int($0) }
                ),
                in: 30...180,
                step: 5
            )
            HStack {
                Text("30 min").font(.caption).foregroundColor(.secondary)
                Spacer()
                Text("3 hr").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StepAllocationRow: View {
    let step: ReviewStep
    let minutes: Int
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(step.name)
                    .font(.subheadline)
                Text("\(minutes) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 0) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(minutes <= 1 ? .secondary : .accentColor)
                }
                .buttonStyle(.plain)
                .disabled(minutes <= 1)

                Text("\(minutes)")
                    .font(.body.monospacedDigit())
                    .frame(width: 36)
                    .multilineTextAlignment(.center)

                Button(action: onIncrement) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 2)
    }
}
