//
//  FollowViewModel.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/30.
//

import Foundation

public class FollowViewModel: ObservableObject {
    @Published public private(set) var followees: [User] = []
    @Published public private(set) var followers: [User] = []
    private var followeesPage: Int?
    private var followersPage: Int?

    private let userId: String
    private let qiitaRepository: QiitaRepositoryProtocol

    public init(userId: String, qiitaRepository: QiitaRepositoryProtocol) {
        self.userId = userId
        self.qiitaRepository = qiitaRepository
    }

    @MainActor
    public func reloadFollowees() async throws {
        (followees, followeesPage) = try await qiitaRepository.fetchFollowees(userId: userId, page: nil)
    }

    @MainActor
    public func loadMoreFollowees() async throws {
        let (newFollowees, newFolloweesPage) = try await qiitaRepository.fetchFollowees(userId: userId, page: followeesPage)
        followees.append(contentsOf: newFollowees)
        followeesPage = newFolloweesPage
    }

    @MainActor
    public func reloadFollowers() async throws {
        (followers, followersPage) = try await qiitaRepository.fetchFollowers(userId: userId, page: nil)
    }

    @MainActor
    public func loadMoreFollowers() async throws {
        let (newFollowers, newFollowersPage) = try await qiitaRepository.fetchFollowers(userId: userId, page: followeesPage)
        followers.append(contentsOf: newFollowers)
        followersPage = newFollowersPage
    }
}
