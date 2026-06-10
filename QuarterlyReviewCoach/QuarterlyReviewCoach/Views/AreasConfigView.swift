import SwiftUI

struct AreasConfigView: View {
    @ObservedObject var vm: ReviewViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section {
                    ForEach(vm.areaNames.indices, id: \.self) { i in
                        HStack {
                            Text("\(i + 1).")
                                .font(.subheadline.monospacedDigit())
                                .foregroundColor(.secondary)
                                .frame(width: 20)
                            TextField("Area \(i + 1)", text: Binding(
                                get: { vm.areaNames[i] },
                                set: { vm.areaNames[i] = $0 }
                            ))
                            Image(systemName: "pencil")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Label("Your 8 Areas of Focus", systemImage: "square.grid.3x3")
                } footer: {
                    Text("These are the 8 cells surrounding your life goal in your 9x9. Rename them to match your system.")
                }

                Section {
                    Button("Restore Defaults") {
                        vm.areaNames = AreaSettings.defaultNames
                    }
                    .foregroundColor(.orange)
                }
            }
            .navigationTitle("Areas of Focus")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        vm.saveAreaNames()
                        dismiss()
                    }
                    .bold()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }
}
