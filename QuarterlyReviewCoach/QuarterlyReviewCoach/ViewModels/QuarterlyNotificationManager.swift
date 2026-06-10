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

    func scheduleYearlyReminder(month: Int, hour: Int, minute: Int) {
        cancel()
        var components = DateComponents()
        components.month = month
        components.day = 1
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
}
