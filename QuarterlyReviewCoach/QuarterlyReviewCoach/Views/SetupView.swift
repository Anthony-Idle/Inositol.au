import SwiftUI
import UserNotifications

struct SetupView: View {
    @ObservedObject var vm: ReviewViewModel

    @AppStorage("qrReminderEnabled") private var reminderEnabled = false
    @AppStorage("qrReminderMonth")   private var reminderMonth   = 1
    @AppStorage("qrReminderHour")    private var reminderHour    = 10
    @AppStorage("qrReminderMinute")  private var reminderMinute  = 0

    @State private var authStatus: UNAuthorizationStatus = .notDetermined
    @State private var showDeniedAlert = false
    @State private var showingAreasConfig = false

    private var reminderTime: Binding<Date> {
        Binding(
            get: {
                var c = Calendar.current.dateComponents([.year, .month, .day], from: Date())
                c.hour   = reminderHour
                c.minute = reminderMinute
                return Calendar.current.date(from: c) ?? Date()
            },
            set: { date in
                let c = Calendar.current.dateComponents([.hour, .minute], from: date)
                reminderHour   = c.hour   ?? 10
                reminderMinute = c.minute ?? 0
                if reminderEnabled { reschedule() }
            }
        )
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    totalTimePicker
                } header: {
                    Text("Total Review Duration")
                } footer: {
                    Text("Time is distributed across steps proportionally. Adjust individual steps below.")
                }

                Section {
                    ForEach(vm.steps.indices, id: \.self) { i in
                        StepAllocationRow(
                            step: vm.steps[i],
                            minutes: vm.stepMinutes(i),
                            onDecrement: {
                                let current = vm.stepMinutes(i)
                                if current > 1 { vm.setStepMinutes(i, minutes: current - 1) }
                            },
                            onIncrement: {
                                vm.setStepMinutes(i, minutes: vm.stepMinutes(i) + 1)
                            }
                        )
                    }
                } header: {
                    HStack {
                        Text("Step Allocations")
                        Spacer()
                        Text("Total: \(vm.totalAllocatedMinutes) min")
                            .foregroundColor(
                                abs(vm.totalAllocatedMinutes - vm.totalMinutes) <= 1
                                    ? .secondary : .orange
                            )
                    }
                } footer: {
                    Button("Edit area names") { showingAreasConfig = true }
                        .font(.footnote)
                }

                reminderSection

                Section {
                    Button(action: vm.startReview) {
                        HStack {
                            Spacer()
                            Label("Begin Review", systemImage: "play.circle.fill")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.accentColor)
                }
            }
            .navigationTitle("Quarterly Review Pro")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { vm.cancelToHome() }
                }
            }
            .onAppear { refreshAuthStatus() }
            .alert("Notifications Disabled", isPresented: $showDeniedAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { reminderEnabled = false }
            } message: {
                Text("Enable notifications in Settings to receive your quarterly review reminder.")
            }
            .sheet(isPresented: $showingAreasConfig) {
                AreasConfigView(vm: vm)
            }
        }
        .navigationViewStyle(.stack)
    }

    // MARK: - Reminder section

    private var reminderSection: some View {
        Section {
            Toggle(isOn: Binding(
                get: { reminderEnabled },
                set: { newValue in
                    if newValue { enableReminder() }
                    else {
                        reminderEnabled = false
                        QuarterlyNotificationManager.shared.cancel()
                    }
                }
            )) {
                Label("Quarterly Reminder", systemImage: "bell.badge")
            }

            if reminderEnabled && authStatus == .authorized {
                Picker("Month", selection: Binding(
                    get: { reminderMonth },
                    set: { reminderMonth = $0; reschedule() }
                )) {
                    ForEach(1...12, id: \.self) { month in
                        Text(monthName(month)).tag(month)
                    }
                }
                DatePicker("Time", selection: reminderTime, displayedComponents: .hourAndMinute)
            }
        } header: {
            Text("Reminder")
        } footer: {
            if reminderEnabled && authStatus == .authorized {
                Text("You'll be reminded each \(monthName(reminderMonth)) to do your quarterly review.")
            }
        }
    }

    // MARK: - Total time picker

    private var totalTimePicker: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "clock")
                    .foregroundColor(.accentColor)
                Text("\(vm.totalMinutes) minutes")
                    .font(.title2.bold())
                Spacer()
            }
            Slider(
                value: Binding(
                    get: { Double(vm.totalMinutes) },
                    set: { vm.totalMinutes = Int($0) }
                ),
                in: 60...240,
                step: 5
            )
            HStack {
                Text("1 hr").font(.caption).foregroundColor(.secondary)
                Spacer()
                Text("4 hr").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }

    // MARK: - Helpers

    private func enableReminder() {
        QuarterlyNotificationManager.shared.authorizationStatus { status in
            authStatus = status
            switch status {
            case .notDetermined:
                QuarterlyNotificationManager.shared.requestPermission { granted in
                    if granted {
                        reminderEnabled = true
                        authStatus = .authorized
                        reschedule()
                    } else {
                        reminderEnabled = false
                        authStatus = .denied
                    }
                }
            case .authorized, .provisional, .ephemeral:
                reminderEnabled = true
                reschedule()
            case .denied:
                showDeniedAlert = true
            @unknown default:
                break
            }
        }
    }

    private func reschedule() {
        QuarterlyNotificationManager.shared.scheduleYearlyReminder(
            month: reminderMonth,
            hour: reminderHour,
            minute: reminderMinute
        )
    }

    private func refreshAuthStatus() {
        QuarterlyNotificationManager.shared.authorizationStatus { authStatus = $0 }
    }

    private func monthName(_ month: Int) -> String {
        var c = DateComponents()
        c.month = month; c.year = 2026; c.day = 1
        let df = DateFormatter()
        df.dateFormat = "MMMM"
        return Calendar.current.date(from: c).map { df.string(from: $0) } ?? "\(month)"
    }
}

// MARK: - Step allocation row

struct StepAllocationRow: View {
    let step: ReviewStep
    let minutes: Int
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
                Text(step.phase.altitude)
                    .font(.caption.bold())
                    .foregroundColor(.accentColor)
                    .tracking(0.3)
                Text(step.name)
                    .font(.subheadline)
                Text("\(minutes) min")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Spacer()
            HStack(spacing: 0) {
                Button(action: onDecrement) {
                    Image(systemName: "minus.circle")
                        .foregroundColor(minutes <= 1 ? .secondary : .accentColor)
                }
                .buttonStyle(.plain)
                .disabled(minutes <= 1)

                Text("\(minutes)")
                    .font(.body.monospacedDigit())
                    .frame(width: 36)
                    .multilineTextAlignment(.center)

                Button(action: onIncrement) {
                    Image(systemName: "plus.circle")
                        .foregroundColor(.accentColor)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 2)
    }
}
