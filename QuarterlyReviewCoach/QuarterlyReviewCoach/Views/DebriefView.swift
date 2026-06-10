import SwiftUI

struct DebriefView: View {
    @ObservedObject var vm: ReviewViewModel

    var body: some View {
        NavigationView {
            Form {
                achievementSection
                causeAnalysisSection
                oneThingSection
                completeSection
            }
            .navigationTitle("Debrief")
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Achievement rates

    private var achievementSection: some View {
        Section {
            ForEach(vm.currentRecord.areaNames.indices, id: \.self) { i in
                achievementRow(index: i)
            }
        } header: {
            Label("Achievement Rate by Area", systemImage: "chart.bar")
        } footer: {
            Text("Score each area 0–100% for this quarter. Be honest — this becomes your baseline.")
        }
    }

    private func achievementRow(index: Int) -> some View {
        let areaName = index < vm.currentRecord.areaNames.count
            ? vm.currentRecord.areaNames[index] : "Area \(index + 1)"

        let rate = Binding<Double>(
            get: {
                Double(index < vm.currentRecord.achievementRates.count
                    ? vm.currentRecord.achievementRates[index] : 50)
            },
            set: {
                if index < vm.currentRecord.achievementRates.count {
                    vm.currentRecord.achievementRates[index] = Int($0)
                }
            }
        )

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(areaName)
                    .font(.subheadline.bold())
                Spacer()
                Text("\(Int(rate.wrappedValue))%")
                    .font(.subheadline.monospacedDigit().bold())
                    .foregroundColor(rateColor(Int(rate.wrappedValue)))
            }
            Slider(value: rate, in: 0...100, step: 5)
                .tint(rateColor(Int(rate.wrappedValue)))
        }
        .padding(.vertical, 4)
    }

    private func rateColor(_ rate: Int) -> Color {
        switch rate {
        case 0..<40:   return .red
        case 40..<70:  return .orange
        default:       return .accentColor
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
