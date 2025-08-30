//
//  User.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/28.
//

import Foundation

/// - seealso: https://qiita.com/api/v2/docs#%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC
public struct User: Decodable, Hashable {
    public let id: String
    public let profileImageUrl: URL
    public let followeesCount: Int
    public let followersCount: Int
    public let description: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case profileImageUrl = "profile_image_url"
        case followeesCount = "followees_count"
        case followersCount = "followers_count"
        case description
    }
}

#if DEBUG
    public extension User {
        static var mockUsers: [Self] {
            [
                .init(id: "Qiita",
                      profileImageUrl: URL(string: "https://s3-ap-northeast-1.amazonaws.com/qiita-image-store/0/88/ccf90b557a406157dbb9d2d7e543dae384dbb561/large.png?1575443439")!,
                      followeesCount: 2,
                      followersCount: 582_883,
                      description: "Qiita公式アカウントです。Qiitaに関するお問い合わせに反応したり、お知らせなどを発信しています。"),
                .init(id: "QiitaBootleg",
                      profileImageUrl: URL(string: "https://s3-ap-northeast-1.amazonaws.com/qiita-image-store/0/88/ccf90b557a406157dbb9d2d7e543dae384dbb561/large.png?1575443439")!,
                      followeesCount: 1000,
                      followersCount: 0,
                      description: "Qiita非公式アカウントです。Qiitaに関するお問い合わせに反応したり、お知らせなどを発信していません。"),
            ]
        }
    }
#endif
