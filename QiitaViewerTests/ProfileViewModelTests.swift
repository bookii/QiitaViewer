//
//  ProfileViewModelTests.swift
//  QiitaViewerTests
//
//  Created by Tsubasa YABUKI on 2025/08/31.
//

@testable import QiitaViewer
import Testing

struct ProfileViewModelTests {
    let profileViewModel = ProfileViewModel(userId: "Qiita", qiitaRepository: MockQiitaRepository())

    @Test func itemsAreInitiallyEmpty() {
        #expect(profileViewModel.items.isEmpty)
    }

    @Test func itemsCanBeReloadedAndLoadedMore() async throws {
        try await profileViewModel.reloadItems()
        #expect(profileViewModel.items.count == Item.mockItems.count)

        try await profileViewModel.loadMoreItems()
        try await profileViewModel.loadMoreItems()
        #expect(profileViewModel.items.count == Item.mockItems.count * 3)

        try await profileViewModel.reloadItems()
        #expect(profileViewModel.items.count == Item.mockItems.count)
    }
}
