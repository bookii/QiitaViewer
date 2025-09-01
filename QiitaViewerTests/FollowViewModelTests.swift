//
//  FollowViewModelTests.swift
//  QiitaViewerTests
//
//  Created by bookii on 2025/08/31.
//

@testable import QiitaViewer
import Testing

struct FollowViewModelTests {
    let followeeViewModel = FolloweeViewModel(userId: "Qiita", qiitaRepository: MockQiitaRepository())
    let followerViewModel = FollowerViewModel(userId: "Qiita", qiitaRepository: MockQiitaRepository())

    @Test func followeesAreInitiallyEmpty() {
        #expect(followeeViewModel.users.isEmpty)
    }

    @Test func followeesCanBeReloadedAndLoadedMore() async throws {
        try await followeeViewModel.reloadUsers()
        #expect(followeeViewModel.users.count == User.mockUsers.count)

        try await followeeViewModel.loadMoreUsers()
        try await followeeViewModel.loadMoreUsers()
        #expect(followeeViewModel.users.count == User.mockUsers.count * 3)

        try await followeeViewModel.reloadUsers()
        #expect(followeeViewModel.users.count == User.mockUsers.count)
    }

    @Test func followersAreInitiallyEmpty() {
        #expect(followerViewModel.users.isEmpty)
    }

    @Test func followersCanBeReloadedAndLoadedMore() async throws {
        try await followerViewModel.reloadUsers()
        #expect(followerViewModel.users.count == User.mockUsers.count)

        try await followerViewModel.loadMoreUsers()
        try await followerViewModel.loadMoreUsers()
        #expect(followerViewModel.users.count == User.mockUsers.count * 3)

        try await followerViewModel.reloadUsers()
        #expect(followerViewModel.users.count == User.mockUsers.count)
    }
}
