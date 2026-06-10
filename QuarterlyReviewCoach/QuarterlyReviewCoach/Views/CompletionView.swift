import SwiftUI

struct CompletionView: View {
    @ObservedObject var vm: ReviewViewModel
    @State private var nextReviewDate = Calendar.current.date(
        byAdding: .month, value: 3, to: Date()
    ) ?? Date()

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
                Text("You finished your \(vm.currentRecord.quarterLabel) Review")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            statsCard

            nextReviewPicker

            Spacer()

            Button {
                vm.currentRecord.nextReviewDate = nextReviewDate
                vm.saveAndGoHome()
            } label: {
                Label("Save & Finish", systemImage: "arrow.down.circle.fill")
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

    // MARK: - Stats card

    private var statsCard: some View {
        VStack(spacing: 12) {
            statRow(
                icon: "clock.fill",
                label: "Time elapsed",
                value: vm.currentRecord.formattedElapsed
            )
            statRow(
                icon: "list.bullet.clipboard.fill",
                label: "Steps completed",
                value: "\(vm.currentRecord.stepsCompleted)"
            )
            if !vm.currentRecord.oneThingForSuccess.isEmpty {
                Divider()
                statRow(
                    icon: "target",
                    label: "Next quarter priority",
                    value: vm.currentRecord.oneThingForSuccess
                )
            }
        }
        .padding()
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }

    // MARK: - Next review picker

    private var nextReviewPicker: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "calendar")
                    .foregroundColor(.accentColor)
                Text("Schedule Next Review")
                    .font(.subheadline.bold())
                Spacer()
            }
            .padding(.horizontal)

            DatePicker(
                "Next review date",
                selection: $nextReviewDate,
                in: Date()...,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .padding(.horizontal)
        }
    }

    // MARK: - Stat row

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
                .multilineTextAlignment(.trailing)
        }
    }
}
