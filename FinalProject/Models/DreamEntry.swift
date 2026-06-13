import Foundation

struct DreamEntry: Identifiable, Codable {
    let id: UUID
    var text: String
    var imageData: Data?
    var createdAt: Date
    var style: String
    var emotion: String
    var isFavorite: Bool

    init(id: UUID = UUID(), text: String, imageData: Data? = nil,
         createdAt: Date = Date(), style: String = "수채화",
         emotion: String = "신비로움", isFavorite: Bool = false) {
        self.id = id
        self.text = text
        self.imageData = imageData
        self.createdAt = createdAt
        self.style = style
        self.emotion = emotion
        self.isFavorite = isFavorite
    }

    enum CodingKeys: String, CodingKey {
        case id, text, imageData, createdAt, style, emotion, isFavorite
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        text = try container.decode(String.self, forKey: .text)
        imageData = try container.decodeIfPresent(Data.self, forKey: .imageData)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        style = try container.decodeIfPresent(String.self, forKey: .style) ?? "수채화"
        emotion = try container.decodeIfPresent(String.self, forKey: .emotion) ?? "신비로움"
        isFavorite = try container.decodeIfPresent(Bool.self, forKey: .isFavorite) ?? false
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: createdAt)
    }

    var shortText: String {
        text.count > 50 ? String(text.prefix(47)) + "..." : text
    }
}
