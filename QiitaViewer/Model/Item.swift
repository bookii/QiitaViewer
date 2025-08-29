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
    public let likesCount: Int
    public let createdAt: Date

    public enum CodingKeys: String, CodingKey {
        case id
        case title
        case likesCount = "likes_count"
        case createdAt = "created_at"
    }
}

#if DEBUG
    public extension Item {
        static var mockItems: [Self] {
            [
                .init(id: "abc123", title: "Markdown入門", likesCount: 0, createdAt: Date(timeIntervalSince1970: 1_711_940_400)),
                .init(id: "def456", title: "Swift6対応は難しいですが、皆さんいかがお過ごしですか？", likesCount: 999, createdAt: Date(timeIntervalSince1970: 1_735_657_200)),
            ]
        }
    }
#endif
