//
//  FollowViewModel.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/09/01.
//

import Foundation

public protocol FollowViewModel: ObservableObject {
    var users: [User] { get }
    func reloadUsers() async throws
    func loadMoreUsers() async throws
}

public class FolloweeViewModel: FollowViewModel {
    @Published public private(set) var users: [User] = []
    private var page: Int?

    private let userId: String
    private let qiitaRepository: QiitaRepositoryProtocol

    public init(userId: String, qiitaRepository: QiitaRepositoryProtocol) {
        self.userId = userId
        self.qiitaRepository = qiitaRepository
    }

    @MainActor
    public func reloadUsers() async throws {
        (users, page) = try await qiitaRepository.fetchFollowees(userId: userId, page: nil)
    }

    @MainActor
    public func loadMoreUsers() async throws {
        let (newUsers, nextPage) = try await qiitaRepository.fetchFollowees(userId: userId, page: page)
        users.append(contentsOf: newUsers)
        page = nextPage
    }
}

public class FollowerViewModel: FollowViewModel {
    @Published public private(set) var users: [User] = []
    private var page: Int?

    private let userId: String
    private let qiitaRepository: QiitaRepositoryProtocol

    public init(userId: String, qiitaRepository: QiitaRepositoryProtocol) {
        self.userId = userId
        self.qiitaRepository = qiitaRepository
    }

    @MainActor
    public func reloadUsers() async throws {
        (users, page) = try await qiitaRepository.fetchFollowers(userId: userId, page: nil)
    }

    @MainActor
    public func loadMoreUsers() async throws {
        let (newUsers, nextPage) = try await qiitaRepository.fetchFollowers(userId: userId, page: page)
        users.append(contentsOf: newUsers)
        page = nextPage
    }
}
