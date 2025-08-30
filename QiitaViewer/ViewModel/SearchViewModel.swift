//
//  SearchViewModel.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/27.
//

import Foundation

public class SearchViewModel: ObservableObject {
    @Published public private(set) var searchHistories: [SearchHistory] = []

    private let userDefaultsRepository: UserDefaultsRepositoryProtocol
    private let qiitaRepository: QiitaRepositoryProtocol

    public init(userDefaultsRepository: UserDefaultsRepositoryProtocol, qiitaRepository: QiitaRepositoryProtocol) {
        self.userDefaultsRepository = userDefaultsRepository
        self.qiitaRepository = qiitaRepository
    }

    @MainActor
    public func loadSearchHistories() {
        searchHistories = userDefaultsRepository.loadSearchHistories()
    }

    public func search(userId: String) async throws -> User {
        return try await qiitaRepository.fetchUser(userId: userId)
    }
}
