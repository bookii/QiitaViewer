//
//  ProfileViewModelTests.swift
//  QiitaViewerTests
//
//  Created by bookii on 2025/08/31.
//

@testable import QiitaViewer
import Testing

struct ProfileViewModelTests {
    let profileViewModel = ProfileViewModel(userId: "Qiita", qiitaRepository: MockQiitaRepository())

    @Test func itemsIsInitiallyEmpty() {
        #expect(profileViewModel.items.isEmpty)
    }

    @Test func itemsCanBeLoaded() async throws {
        try await profileViewModel.loadItems()
        #expect(profileViewModel.items.map(\.id) == Item.mockItems.map(\.id))
    }
}
