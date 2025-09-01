//
//  FollowViewModelTests.swift
//  QiitaViewerTests
//
//  Created by bookii on 2025/08/31.
//

@testable import QiitaViewer
import Testing

struct FollowViewModelTests {
    let followViewModel = FollowViewModel(userId: "Qiita", qiitaRepository: MockQiitaRepository())

    @Test func followeesAndFollowersAreInitiallyEmpty() {
        #expect(followViewModel.followees.isEmpty)
        #expect(followViewModel.followers.isEmpty)
    }

    @Test func followeesCanBeReloadedAndLoadedMore() async throws {
        try await followViewModel.reloadFollowees()
        #expect(followViewModel.followees.count == User.mockUsers.count)

        try await followViewModel.loadMoreFollowees()
        try await followViewModel.loadMoreFollowees()
        #expect(followViewModel.followees.count == User.mockUsers.count * 3)

        try await followViewModel.reloadFollowees()
        #expect(followViewModel.followees.count == User.mockUsers.count)
    }

    @Test func followersCanBeReloadedAndLoadedMore() async throws {
        try await followViewModel.reloadFollowers()
        #expect(followViewModel.followers.count == User.mockUsers.count)

        try await followViewModel.loadMoreFollowers()
        try await followViewModel.loadMoreFollowers()
        #expect(followViewModel.followers.count == User.mockUsers.count * 3)

        try await followViewModel.reloadFollowers()
        #expect(followViewModel.followers.count == User.mockUsers.count)
    }
}
