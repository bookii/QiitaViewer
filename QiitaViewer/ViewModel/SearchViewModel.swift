//
//  SearchViewModel.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/27.
//

import Foundation

public class SearchViewModel: ObservableObject {
    @Published public private(set) var searchHistories: [SearchHistory] = []

    private let userDefaultsRepository: UserDefaultsRepositoryProtocol
    private let qiitaRepository: QiitaRepositoryProtocol

    public init(userDefaultsRepository: UserDefaultsRepositoryProtocol = UserDefaultsRepository(), qiitaRepository: QiitaRepositoryProtocol = QiitaRepository()) {
        self.userDefaultsRepository = userDefaultsRepository
        self.qiitaRepository = qiitaRepository
    }

    public func loadSearchHistories() {
        searchHistories = userDefaultsRepository.loadSearchHistories()
    }

    public func search(userId: String) async throws -> User {
        try await qiitaRepository.fetchUser(userId: userId)
    }
}
