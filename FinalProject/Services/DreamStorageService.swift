import Foundation

class DreamStorageService {

    private let storageKey = "dream_canvas_entries_v1"

    func save(entries: [DreamEntry]) {
        guard let encoded = try? JSONEncoder().encode(entries) else { return }
        UserDefaults.standard.set(encoded, forKey: storageKey)
    }

    func load() -> [DreamEntry] {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let entries = try? JSONDecoder().decode([DreamEntry].self, from: data) else {
            return []
        }
        return entries
    }

    func deleteAll() {
        UserDefaults.standard.removeObject(forKey: storageKey)
    }
}
