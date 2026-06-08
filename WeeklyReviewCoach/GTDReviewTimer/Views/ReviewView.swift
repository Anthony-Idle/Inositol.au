import SwiftUI

struct ReviewView: View {
    @ObservedObject var vm: ReviewViewModel

    var body: some View {
        VStack(spacing: 0) {
            // Top bar
            topBar

            ScrollView {
                VStack(spacing: 24) {
                    // Timer ring
                    timerRing
                        .padding(.top, 24)

                    // Step info
                    if let step = vm.currentStep {
                        stepCard(step: step)
                    }

                    // Instructions
                    if let step = vm.currentStep {
                        instructionsCard(step: step)
                    }

                    Spacer(minLength: 120)
                }
                .padding(.horizontal)
            }

            // Bottom controls
            bottomControls
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    // MARK: - Top bar

    private var topBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Step \(vm.currentStepIndex + 1) of \(vm.steps.count)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Label(vm.formattedElapsed, systemImage: "clock")
                    .font(.subheadline.monospacedDigit())
                    .foregroundColor(.secondary)
            }

            ProgressView(value: vm.overallProgress)
                .tint(.accentColor)
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.systemBackground))
    }

    // MARK: - Timer ring

    private var timerRing: some View {
        ZStack {
            Circle()
                .stroke(Color(.systemGray5), lineWidth: 14)

            Circle()
                .trim(from: 0, to: vm.stepProgress)
                .stroke(
                    vm.stepExpired ? Color.red : Color.accentColor,
                    style: StrokeStyle(lineWidth: 14, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.linear(duration: 1), value: vm.stepProgress)

            VStack(spacing: 4) {
                Text(vm.formattedRemaining)
                    .font(.system(size: 52, weight: .thin, design: .monospaced))
                    .foregroundColor(vm.stepExpired ? .red : .primary)

                if vm.stepExpired {
                    Text("Time's up!")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                } else {
                    Text("remaining")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(width: 240, height: 240)
    }

    // MARK: - Step card

    private func stepCard(step: ReviewStep) -> some View {
        VStack(spacing: 4) {
            Text(step.name)
                .font(.title2.bold())
                .multilineTextAlignment(.center)

            Text("\(step.durationSeconds / 60) min allocated")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Instructions card

    private func instructionsCard(step: ReviewStep) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Instructions", systemImage: "list.bullet.clipboard")
                .font(.subheadline.bold())
                .foregroundColor(.accentColor)

            ForEach(step.instructions, id: \.self) { instruction in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark.circle")
                        .foregroundColor(.secondary)
                        .padding(.top, 1)
                    Text(instruction)
                        .font(.body)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }

    // MARK: - Next step preview

    private var upcomingStep: ReviewStep? {
        let next = vm.currentStepIndex + 1
        guard next < vm.steps.count else { return nil }
        return vm.steps[next]
    }

    // MARK: - Bottom controls

    private var bottomControls: some View {
        VStack(spacing: 12) {
            if let next = upcomingStep {
                HStack {
                    Text("Next up:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(next.name)
                        .font(.caption.bold())
                        .foregroundColor(.secondary)
                    Spacer()
                    Text("\(next.durationSeconds / 60) min")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 4)
                Divider()
            }

            HStack(spacing: 16) {
                // Previous
                Button(action: vm.previousStep) {
                    Image(systemName: "backward.fill")
                        .font(.title3)
                        .frame(width: 52, height: 52)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                }
                .disabled(vm.currentStepIndex == 0)

                // Pause / Resume
                Button(action: vm.isPaused ? vm.resume : vm.pause) {
                    Image(systemName: vm.isPaused ? "play.fill" : "pause.fill")
                        .font(.title2)
                        .frame(width: 64, height: 64)
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }

                // Next
                Button(action: vm.nextStep) {
                    Image(systemName: "forward.fill")
                        .font(.title3)
                        .frame(width: 52, height: 52)
                        .background(Color(.secondarySystemGroupedBackground))
                        .clipShape(Circle())
                }
            }

            if vm.stepExpired {
                Button("Next Step →") {
                    vm.nextStep()
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .transition(.opacity.combined(with: .move(edge: .bottom)))
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .animation(.spring(), value: vm.stepExpired)
    }
}
