import Foundation
import UserNotifications

class QuarterlyNotificationManager {
    static let shared = QuarterlyNotificationManager()
    private let notificationID = "com.anthonyidle.QuarterlyReviewCoach.reminder"

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, _ in
                DispatchQueue.main.async { completion(granted) }
            }
    }

    func scheduleYearlyReminder(month: Int, ordinal: Int, weekday: Int, hour: Int, minute: Int) {
        cancel()
        let year = Calendar.current.component(.year, from: Date())
        guard let day = dayOfMonth(ordinal: ordinal, weekday: weekday, month: month, year: year) else { return }

        var components = DateComponents()
        components.month = month
        components.day = day
        components.hour = hour
        components.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "Quarterly Review Pro"
        content.body = "Time for your quarterly review — block 2.5 hours and get clear, current, and creative."
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: notificationID, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    func cancel() {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [notificationID])
    }

    func authorizationStatus(completion: @escaping (UNAuthorizationStatus) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async { completion(settings.authorizationStatus) }
        }
    }

    // MARK: - Date calculation

    private func dayOfMonth(ordinal: Int, weekday: Int, month: Int, year: Int) -> Int? {
        let calendar = Calendar.current
        guard let firstOfMonth = calendar.date(from: DateComponents(year: year, month: month, day: 1)),
              let range = calendar.range(of: .day, in: .month, for: firstOfMonth)
        else { return nil }

        let days = range.count

        if ordinal == 5 {
            // Last occurrence — scan backwards
            for day in stride(from: days, through: 1, by: -1) {
                if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)),
                   calendar.component(.weekday, from: date) == weekday {
                    return day
                }
            }
        } else {
            var count = 0
            for day in 1...days {
                if let date = calendar.date(from: DateComponents(year: year, month: month, day: day)),
                   calendar.component(.weekday, from: date) == weekday {
                    count += 1
                    if count == ordinal { return day }
                }
            }
        }
        return nil
    }
}
