//
//  QiitaRepository.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/28.
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
    func fetchItems(userId: String, page: Int?) async throws -> (items: [Item], page: Int)
    func fetchFollowees(userId: String) async throws -> [User]
    func fetchFollowers(userId: String) async throws -> [User]
}

public final class QiitaRepository: QiitaRepositoryProtocol {
    public enum Error: LocalizedError {
        case userIdEscapeFailed

        public var errorDescription: String? {
            switch self {
            case .userIdEscapeFailed:
                "Failed to escape userId"
            }
        }
    }

    private let domain = "https://qiita.com"

    public init() {}

    /// - seealso: https://qiita.com/api/v2/docs#get-apiv2usersuser_id
    public func fetchUser(userId: String) async throws -> User {
        guard let escapedUserId = userId.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) else {
            throw Error.userIdEscapeFailed
        }
        let response = await AF.request("\(domain)/api/v2/users/\(escapedUserId)")
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

    /// - seealso: https://qiita.com/api/v2/docs#get-apiv2usersuser_iditems
    public func fetchItems(userId: String, page: Int?) async throws -> (items: [Item], page: Int) {
        guard let escapedUserId = userId.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) else {
            throw Error.userIdEscapeFailed
        }
        let page = page ?? 1
        let response = await AF.request("\(domain)/api/v2/users/\(escapedUserId)/items?page=\(page)")
            .validate()
            .serializingDecodable([Item].self)
            .response

        switch response.result {
        case let .success(items):
            return (items, page + 1)
        case let .failure(error):
            throw error
        }
    }

    /// - seealso: https://qiita.com/api/v2/docs#get-apiv2usersuser_idfollowees
    public func fetchFollowees(userId: String) async throws -> [User] {
        guard let escapedUserId = userId.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) else {
            throw Error.userIdEscapeFailed
        }
        let response = await AF.request("\(domain)/api/v2/users/\(escapedUserId)/followees")
            .validate()
            .serializingDecodable([User].self)
            .response

        switch response.result {
        case let .success(users):
            return users
        case let .failure(error):
            throw error
        }
    }

    /// - seealso: https://qiita.com/api/v2/docs#get-apiv2usersuser_idfollowers
    public func fetchFollowers(userId: String) async throws -> [User] {
        guard let escapedUserId = userId.addingPercentEncoding(withAllowedCharacters: .afURLQueryAllowed) else {
            throw Error.userIdEscapeFailed
        }
        let response = await AF.request("\(domain)/api/v2/users/\(escapedUserId)/followers")
            .validate()
            .serializingDecodable([User].self)
            .response

        switch response.result {
        case let .success(users):
            return users
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

        public func fetchItems(userId _: String, page: Int?) async throws -> (items: [Item], page: Int) {
            try? await Task.sleep(for: .seconds(1))
            return (Item.mockItems, page ?? 0 + 1)
        }

        public func fetchFollowees(userId _: String) async throws -> [User] {
            try? await Task.sleep(for: .seconds(1))
            return User.mockUsers
        }

        public func fetchFollowers(userId _: String) async throws -> [User] {
            try? await Task.sleep(for: .seconds(1))
            return User.mockUsers
        }
    }
#endif
