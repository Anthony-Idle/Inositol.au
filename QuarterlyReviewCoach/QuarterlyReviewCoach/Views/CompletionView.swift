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
                icon: "chart.bar.fill",
                label: "Average achievement",
                value: "\(vm.currentRecord.averageAchievement)%"
            )

            if !vm.currentRecord.areaNames.isEmpty {
                Divider()
                achievementBars
            }

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

    private var achievementBars: some View {
        VStack(spacing: 6) {
            ForEach(vm.currentRecord.areaNames.indices, id: \.self) { i in
                let name = vm.currentRecord.areaNames[i]
                let rate = i < vm.currentRecord.achievementRates.count
                    ? vm.currentRecord.achievementRates[i] : 0
                HStack(spacing: 8) {
                    Text(name)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 90, alignment: .leading)
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(Color(.systemGray5))
                            RoundedRectangle(cornerRadius: 3)
                                .fill(barColor(rate))
                                .frame(width: geo.size.width * CGFloat(rate) / 100)
                        }
                    }
                    .frame(height: 6)
                    Text("\(rate)%")
                        .font(.caption.monospacedDigit())
                        .foregroundColor(.secondary)
                        .frame(width: 36, alignment: .trailing)
                }
            }
        }
    }

    private func barColor(_ rate: Int) -> Color {
        switch rate {
        case 0..<40:  return .red
        case 40..<70: return .orange
        default:      return .accentColor
        }
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
