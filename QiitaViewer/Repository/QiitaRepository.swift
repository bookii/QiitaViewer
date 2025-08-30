//
//  QiitaRepository.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/28.
//

import Alamofire
import Foundation
import SwiftUICore

extension EnvironmentValues {
    @Entry var qiitaRepository: QiitaRepositoryProtocol = QiitaRepository()
}

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
    func fetchUser(userId: String) async throws -> User
    func fetchItems(userId: String) async throws -> [Item]
}

public final class QiitaRepository: QiitaRepositoryProtocol {
    private let domain = "https://qiita.com"
    private let headers: HTTPHeaders

    public init() {
            fatalError("ACCESS_TOKEN not found in Info.plist")
        }
        headers = ["Authorization": "Bearer \(accessToken)"]
    }

    public func fetchUser(userId: String) async throws -> User {
        let response = await AF.request("\(domain)/api/v2/users/\(userId)", headers: headers)
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

    public func fetchItems(userId: String) async throws -> [Item] {
        let response = await AF.request("\(domain)/api/v2/users/\(userId)/items", headers: headers)
            .validate()
            .serializingDecodable([Item].self)
            .response

        switch response.result {
        case let .success(items):
            return items
        case let .failure(error):
            throw error
        }
    }
}

#if DEBUG
    public final class MockQiitaRepository: QiitaRepositoryProtocol {
        public init() {}

        public func fetchUser(userId: String) async throws -> User {
            guard let user = User.mockUsers.first(where: { $0.id == userId }) else {
                throw QiitaRepositoryError.userNotFound
            }
            try? await Task.sleep(for: .seconds(1))
            return user
        }

        public func fetchItems(userId _: String) async throws -> [Item] {
            try? await Task.sleep(for: .seconds(1))
            return Item.mockItems
        }
    }
#endif
