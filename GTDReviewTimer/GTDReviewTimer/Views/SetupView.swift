import SwiftUI
import UserNotifications

struct SetupView: View {
    @ObservedObject var vm: ReviewViewModel

    // Reminder persistence
    @AppStorage("reminderEnabled")  private var reminderEnabled  = false
    @AppStorage("reminderWeekday") private var reminderWeekday  = 1  // 1 = Sunday
    @AppStorage("reminderHour")    private var reminderHour     = 10
    @AppStorage("reminderMinute")  private var reminderMinute   = 0

    @State private var authStatus: UNAuthorizationStatus = .notDetermined
    @State private var showDeniedAlert = false

    // Synthetic Date binding so DatePicker can own hour + minute
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
                }

                reminderSection

                Section {
                    Button(action: vm.startReview) {
                        HStack {
                            Spacer()
                            Label("Start Weekly Review", systemImage: "play.circle.fill")
                                .font(.headline)
                            Spacer()
                        }
                    }
                    .foregroundColor(.white)
                    .listRowBackground(Color.accentColor)
                }
            }
            .navigationTitle("GTD Weekly Review")
            .onAppear { refreshAuthStatus() }
            .alert("Notifications Disabled", isPresented: $showDeniedAlert) {
                Button("Open Settings") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Cancel", role: .cancel) { reminderEnabled = false }
            } message: {
                Text("Enable notifications in Settings to receive your weekly review reminder.")
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
                    if newValue {
                        enableReminder()
                    } else {
                        reminderEnabled = false
                        NotificationManager.shared.cancel()
                    }
                }
            )) {
                Label("Weekly Reminder", systemImage: "bell.badge")
            }

            if reminderEnabled && authStatus == .authorized {
                Picker("Day", selection: Binding(
                    get: { reminderWeekday },
                    set: { reminderWeekday = $0; reschedule() }
                )) {
                    ForEach(1...7, id: \.self) { weekday in
                        Text(weekdayName(weekday)).tag(weekday)
                    }
                }

                DatePicker("Time", selection: reminderTime, displayedComponents: .hourAndMinute)
            }
        } header: {
            Text("Reminder")
        } footer: {
            if reminderEnabled && authStatus == .authorized {
                Text("You'll be reminded every \(weekdayName(reminderWeekday)) at \(formattedTime).")
            }
        }
    }

    // MARK: - Helpers

    private func enableReminder() {
        NotificationManager.shared.authorizationStatus { status in
            authStatus = status
            switch status {
            case .notDetermined:
                NotificationManager.shared.requestPermission { granted in
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
        NotificationManager.shared.scheduleWeeklyReminder(
            weekday: reminderWeekday,
            hour:    reminderHour,
            minute:  reminderMinute
        )
    }

    private func refreshAuthStatus() {
        NotificationManager.shared.authorizationStatus { authStatus = $0 }
    }

    private func weekdayName(_ weekday: Int) -> String {
        // weekday 1 = Sunday in Calendar convention
        let names = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
        return names[(weekday - 1) % 7]
    }

    private var formattedTime: String {
        let c = DateComponents(hour: reminderHour, minute: reminderMinute)
        if let date = Calendar.current.date(from: c) {
            let f = DateFormatter()
            f.timeStyle = .short
            return f.string(from: date)
        }
        return "\(reminderHour):\(String(format: "%02d", reminderMinute))"
    }

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
                in: 30...180,
                step: 5
            )
            HStack {
                Text("30 min").font(.caption).foregroundColor(.secondary)
                Spacer()
                Text("3 hr").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

struct StepAllocationRow: View {
    let step: ReviewStep
    let minutes: Int
    let onDecrement: () -> Void
    let onIncrement: () -> Void

    var body: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 2) {
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
