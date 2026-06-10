import Foundation

struct AreaSettings {
    static let defaultNames = [
        "Work",
        "Health",
        "Finance",
        "Home",
        "Relationships",
        "Creative",
        "Learning",
        "Personal Growth"
    ]

    private static let storageKey = "qrAreaNames"

    static func load() -> [String] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let names = try? JSONDecoder().decode([String].self, from: data),
              names.count == 8
        else { return defaultNames }
        return names
    }

    static func save(_ names: [String]) {
        guard let encoded = try? JSONEncoder().encode(names) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }
}
