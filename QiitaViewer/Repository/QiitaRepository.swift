//
//  QiitaRepository.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/28.
//

import Alamofire
import Foundation

public enum QiitaRepositoryError: LocalizedError {
    case userNotFound

    public var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "User not found"
        }
    }
}

public protocol QiitaRepositoryProtocol {
    func search(userId: String) async throws -> User
}

public final class QiitaRepository: QiitaRepositoryProtocol {
    private let accessToken: String

    public init() {
        guard let accessToken = Bundle.main.object(forInfoDictionaryKey: "ACCESS_TOKEN") as? String else {
            fatalError()
        }
        self.accessToken = accessToken
    }

    public func search(userId: String) async throws -> User {
        let response = await AF.request("https://qiita.com/api/v2/users/\(userId)", headers: ["Authorization": "Bearer \(accessToken)"])
            .validate()
            .serializingDecodable(User.self)
            .response

        switch response.result {
        case let .success(user):
            return user
        case let .failure(error):
            throw error
        }
    }
}

#if DEBUG
    public final class MockQiitaRepository: QiitaRepositoryProtocol {
        public init() {}

        public func search(userId: String) async throws -> User {
            guard let user = User.mockUsers.first(where: { $0.id == userId }) else {
                throw QiitaRepositoryError.userNotFound
            }
            return user
        }
    }
#endif
