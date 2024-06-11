import Foundation

struct Post: Codable, Identifiable {
    var id: Int 
    var name: String
    var title: String
    var content: String
    var createdAt: Date
    var updatedAt: Date
    var author: String
    var postImage: URL? // Опционально, так как может отсутствовать
    var userId: Int

    enum CodingKeys: String, CodingKey {
        case id, name, title, content, author, userId
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case postImage = "post_image"
    }
}
