import SwiftUI

struct CompletionView: View {
    @ObservedObject var vm: ReviewViewModel

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 96))
                .foregroundColor(.green)
                .symbolEffect(.bounce, value: true)

            VStack(spacing: 8) {
                Text("Review Complete!")
                    .font(.largeTitle.bold())

                Text("You finished your Weekly Review")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 12) {
                statRow(
                    icon: "clock.fill",
                    label: "Time elapsed",
                    value: vm.formattedElapsed
                )
                statRow(
                    icon: "list.bullet.clipboard.fill",
                    label: "Steps completed",
                    value: "\(vm.steps.count)"
                )
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(16)
            .padding(.horizontal)

            Spacer()

            Button(action: vm.reset) {
                Label("Set Up New Review", systemImage: "arrow.counterclockwise")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 28)
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body.monospacedDigit().bold())
        }
    }
}
