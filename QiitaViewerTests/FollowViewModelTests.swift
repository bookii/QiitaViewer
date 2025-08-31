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

    @Test func followeesAndFollowersAreInitiallyNil() {
        #expect(followViewModel.followees == nil)
        #expect(followViewModel.followers == nil)
    }

    @Test func followeesCanBeLoaded() async throws {
        try await followViewModel.loadFollowees()
        #expect(followViewModel.followees != nil)
    }

    @Test func followersCanBeLoaded() async throws {
        try await followViewModel.loadFollowers()
        #expect(followViewModel.followers != nil)
    }
}
