//
//  Item.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/29.
//

import Foundation

/// - seealso: https://qiita.com/api/v2/docs#%E6%8A%95%E7%A8%BF
public struct Item: Decodable {
    public let id: String
    public let title: String
    public let tags: [Tag]
    public let likesCount: Int
    public let createdAt: Date?

    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case tags
        case likesCount = "likes_count"
        case createdAt = "created_at"
    }

    public init(id: String, title: String, tags: [Tag], likesCount: Int, createdAt: Date) {
        self.id = id
        self.title = title
        self.tags = tags
        self.likesCount = likesCount
        self.createdAt = createdAt
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        tags = try container.decode([Tag].self, forKey: .tags)
        likesCount = try container.decode(Int.self, forKey: .likesCount)
        let createdAtString = try container.decode(String.self, forKey: .createdAt)
        createdAt = ISO8601DateFormatter().date(from: createdAtString)
    }
}

#if DEBUG
    public extension Item {
        static var mockItems: [Self] {
            [
                .init(id: "abc123", title: "Markdown入門",
                      tags: [.init(name: "Markdown")],
                      likesCount: 0, createdAt: Date(timeIntervalSince1970: 1_711_940_400)),
                .init(id: "def456", title: "Swift6対応は難しいですが、皆さんいかがお過ごしですか？",
                      tags: [.init(name: "Swift"), .init(name: "ポエム"), .init(name: "ながーーーーーーーーーーーーーーーーーーーーーーーーーーーーいタグ")],
                      likesCount: 999, createdAt: Date(timeIntervalSince1970: 1_735_657_200)),
            ]
        }
    }
#endif
