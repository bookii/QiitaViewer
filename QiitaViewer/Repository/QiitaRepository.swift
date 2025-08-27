//
//  QiitaRepository.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/28.
//

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
    public init() {}

    public func search(userId _: String) async throws -> User {
        // TODO: Public API から User を取得して返す
        throw QiitaRepositoryError.userNotFound
    }
}

#if DEBUG
    public final class MockQiitaRepository: QiitaRepositoryProtocol {
        public func search(userId: String) async throws -> User {
            guard let user = User.mockUsers.first(where: { $0.id == userId }) else {
                throw QiitaRepositoryError.userNotFound
            }
            return user
        }
    }
#endif
