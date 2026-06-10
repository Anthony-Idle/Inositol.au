import SwiftUI

struct HomeView: View {
    @ObservedObject var vm: ReviewViewModel

    var body: some View {
        NavigationView {
            Group {
                if vm.pastRecords.isEmpty {
                    emptyState
                } else {
                    recordsList
                }
            }
            .navigationTitle("Quarterly Review")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("New Review") { vm.startSetup() }
                }
            }
        }
        .navigationViewStyle(.stack)
        .safeAreaInset(edge: .bottom) {
            startBanner
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()
            Image(systemName: "calendar.badge.clock")
                .font(.system(size: 72))
                .foregroundColor(.accentColor)
            VStack(spacing: 8) {
                Text("No Reviews Yet")
                    .font(.title2.bold())
                Text("Start your first quarterly review to build a habit of intentional reflection.")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            Spacer()
            Spacer()
        }
    }

    // MARK: - Records list

    private var recordsList: some View {
        List {
            ForEach(vm.pastRecords.reversed()) { record in
                recordRow(record)
            }
        }
    }

    private func recordRow(_ record: QuarterRecord) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(record.quarterLabel)
                    .font(.headline)
                Spacer()
                if record.completedDate != nil {
                    Label("Complete", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            Text((record.completedDate ?? record.startDate).formatted(date: .abbreviated, time: .omitted))
                .font(.caption)
                .foregroundColor(.secondary)
            if !record.oneThingForSuccess.isEmpty {
                Text(record.oneThingForSuccess)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Start banner

    private var startBanner: some View {
        VStack(spacing: 0) {
            Divider()
            Button(action: vm.startSetup) {
                HStack {
                    Spacer()
                    Label(
                        "Start \(QuarterRecord.currentQuarterLabel()) Review",
                        systemImage: "play.circle.fill"
                    )
                    .font(.headline)
                    Spacer()
                }
                .padding()
            }
            .buttonStyle(.borderedProminent)
            .padding(.horizontal)
            .padding(.vertical, 12)
            .background(Color(.systemBackground))
        }
    }
}
