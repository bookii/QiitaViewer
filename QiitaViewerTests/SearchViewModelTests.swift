//
//  SearchViewModelTests.swift
//  QiitaViewerTests
//
//  Created by bookii on 2025/08/31.
//

@testable import QiitaViewer
import Testing

struct SearchViewModelTests {
    let searchViewModel = SearchViewModel(
        userDefaultsRepository: MockUserDefaultsRepository(),
        qiitaRepository: MockQiitaRepository()
    )

    @Test func searchHistoriesAreInitiallyEmpty() {
        #expect(searchViewModel.searchHistories.isEmpty)
    }

    @Test func searchHistoriesCanBeLoadedSavedAndDeleted() async throws {
        try await searchViewModel.loadSearchHistories()
        #expect(searchViewModel.searchHistories == SearchHistory.mockSearchHistories)

        let testUser = SearchHistory(userId: "TestUser")

        try await searchViewModel.saveSearchHistory(testUser)
        #expect(searchViewModel.searchHistories.contains(testUser))

        try await searchViewModel.deleteSearchHistory(userId: testUser.userId)
        #expect(!searchViewModel.searchHistories.contains(testUser))
    }

    @Test func existingUserCanBeSearched() async throws {
        let existingUserId = SearchHistory.mockSearchHistories.first!.userId
        _ = try await searchViewModel.search(userId: existingUserId)
        #expect(true)
    }

    @Test func nonExistentUserCannotBeSearched() async throws {
        async #expect(throws: Error.self) {
            try await searchViewModel.search(userId: "NonExistentUser")
        }
    }
}
