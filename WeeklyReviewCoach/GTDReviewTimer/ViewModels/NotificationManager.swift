import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private let notificationID = "gtd.weekly.review.reminder"

    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .sound]) { granted, _ in
                DispatchQueue.main.async { completion(granted) }
            }
    }

    func scheduleWeeklyReminder(weekday: Int, hour: Int, minute: Int) {
        cancel()
        var components = DateComponents()
        components.weekday = weekday  // 1 = Sunday … 7 = Saturday
        components.hour = hour
        components.minute = minute

        let content = UNMutableNotificationContent()
        content.title = "Weekly Review Pro"
        content.body = "Time to get clear, current, and creative. Your weekly review is ready."
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
