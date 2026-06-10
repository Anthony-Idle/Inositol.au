import SwiftUI

struct DebriefView: View {
    @ObservedObject var vm: ReviewViewModel

    var body: some View {
        NavigationView {
            Form {
                radarSection
                causeAnalysisSection
                oneThingSection
                completeSection
            }
            .navigationTitle("Debrief")
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Radar chart

    private var radarSection: some View {
        Section {
            let values = vm.currentRecord.achievementRates.map { Double($0) }
            let labels = vm.currentRecord.areaNames

            RadarChart(values: values, labels: labels)
                .frame(height: 320)
                .padding(.vertical, 8)
        } header: {
            Label("Quarter Achievement", systemImage: "chart.xyaxis.line")
        } footer: {
            let avg = vm.currentRecord.averageAchievement
            Text("Average achievement: \(avg)%")
        }
    }

    // MARK: - Cause analysis

    private var causeAnalysisSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text("For your lowest-scoring areas, what were the root causes?")
                    .font(.subheadline.bold())
                TextField(
                    "Environment, routines, wrong goal, competing priorities...",
                    text: Binding(
                        get: { vm.currentRecord.causeAnalysis },
                        set: { vm.currentRecord.causeAnalysis = $0 }
                    ),
                    axis: .vertical
                )
                .font(.body)
                .lineLimit(4, reservesSpace: true)
            }
            .padding(.vertical, 4)
        } header: {
            Label("Cause Analysis", systemImage: "magnifyingglass")
        } footer: {
            Text("Root causes, not symptoms. \"Didn't have time\" is a symptom.")
        }
    }

    // MARK: - One thing

    private var oneThingSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text("The one thing that would make next quarter a success:")
                    .font(.subheadline.bold())
                TextField(
                    "One specific, concrete outcome...",
                    text: Binding(
                        get: { vm.currentRecord.oneThingForSuccess },
                        set: { vm.currentRecord.oneThingForSuccess = $0 }
                    ),
                    axis: .vertical
                )
                .font(.body)
                .lineLimit(3, reservesSpace: true)
            }
            .padding(.vertical, 4)
        } header: {
            Label("Next Quarter", systemImage: "target")
        }
    }

    // MARK: - Complete

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
}
