import SwiftUI

struct HomeView: View {
    @ObservedObject var vm: ReviewViewModel
    @State private var showingAreasConfig = false

    var body: some View {
        NavigationView {
            List {
                areasSection
                reviewsSection
            }
            .navigationTitle("Quarterly Review")
        }
        .navigationViewStyle(.stack)
        .safeAreaInset(edge: .bottom) {
            startBanner
        }
        .sheet(isPresented: $showingAreasConfig) {
            AreasConfigView(vm: vm)
        }
    }

    // MARK: - Areas of focus section

    private var areasSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 10) {
                let columns = vm.areaNames.filter { !$0.isEmpty }
                Text(columns.joined(separator: "  ·  "))
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                Button {
                    showingAreasConfig = true
                } label: {
                    HStack {
                        Image(systemName: "pencil")
                        Text("Edit Areas")
                    }
                    .font(.subheadline.bold())
                    .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
            .padding(.vertical, 4)
        } header: {
            Label("Areas of Focus", systemImage: "square.grid.3x3")
        } footer: {
            Text("Set up your 8 areas before starting your first review.")
        }
    }

    // MARK: - Past reviews section

    private var reviewsSection: some View {
        Section {
            if vm.pastRecords.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 6) {
                        Image(systemName: "clock.arrow.circlepath")
                            .font(.system(size: 32))
                            .foregroundColor(.secondary)
                        Text("No reviews yet")
                            .font(.subheadline.bold())
                        Text("Completed reviews will appear here.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 16)
                    Spacer()
                }
            } else {
                ForEach(vm.pastRecords.reversed()) { record in
                    NavigationLink(destination: ReviewDetailView(record: record)) {
                        recordRow(record)
                    }
                }
            }
        } header: {
            Label("Past Reviews", systemImage: "calendar.badge.clock")
        }
    }

    private func recordRow(_ record: QuarterRecord) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 3) {
                Text(record.quarterLabel)
                    .font(.headline)
                Text((record.completedDate ?? record.startDate)
                    .formatted(date: .abbreviated, time: .omitted))
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            if record.completedDate != nil {
                Text("\(record.averageAchievement)% avg")
                    .font(.subheadline.monospacedDigit())
                    .foregroundColor(.accentColor)
            }
        }
        .padding(.vertical, 2)
    }

    // MARK: - Start banner

    private var startBanner: some View {
        VStack(spacing: 0) {
            Divider()
            Button(action: vm.startSetup) {
                HStack {
                    Spacer()
                    Label("Start Quarterly Review", systemImage: "play.circle.fill")
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
