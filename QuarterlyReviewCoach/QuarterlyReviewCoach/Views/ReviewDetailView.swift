import SwiftUI

struct ReviewDetailView: View {
    let record: QuarterRecord

    var body: some View {
        Form {
            radarSection
            if !record.causeAnalysis.isEmpty || !record.oneThingForSuccess.isEmpty {
                debriefSection
            }
            metaSection
        }
        .navigationTitle(record.quarterLabel)
        .navigationBarTitleDisplayMode(.large)
    }

    // MARK: - Radar

    private var radarSection: some View {
        Section {
            let values = record.achievementRates.map { Double($0) }
            RadarChart(values: values, labels: record.areaNames)
                .frame(height: 320)
                .padding(.vertical, 8)
        } header: {
            Label("Achievement by Area", systemImage: "chart.xyaxis.line")
        } footer: {
            Text("Average: \(record.averageAchievement)%")
        }
    }

    // MARK: - Debrief answers

    private var debriefSection: some View {
        Section {
            if !record.causeAnalysis.isEmpty {
                answerRow(label: "Root Causes", value: record.causeAnalysis)
            }
            if !record.oneThingForSuccess.isEmpty {
                answerRow(label: "One Thing for Success", value: record.oneThingForSuccess)
            }
        } header: {
            Label("Debrief", systemImage: "text.quote")
        }
    }

    private func answerRow(label: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption.bold())
                .foregroundColor(.accentColor)
            Text(value)
                .font(.body)
        }
        .padding(.vertical, 4)
    }

    // MARK: - Meta

    private var metaSection: some View {
        Section {
            statRow(icon: "clock.fill",
                    label: "Time elapsed",
                    value: record.formattedElapsed)
            statRow(icon: "list.bullet.clipboard.fill",
                    label: "Steps completed",
                    value: "\(record.stepsCompleted)")
            if let next = record.nextReviewDate {
                statRow(icon: "calendar",
                        label: "Next review",
                        value: next.formatted(date: .abbreviated, time: .omitted))
            }
        } header: {
            Label("Session", systemImage: "clock")
        }
    }

    private func statRow(icon: String, label: String, value: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 24)
            Text(label)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.body.monospacedDigit())
        }
    }
}
