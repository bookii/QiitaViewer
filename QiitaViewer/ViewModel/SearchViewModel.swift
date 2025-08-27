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

    public init(userDefaultsRepository: UserDefaultsRepositoryProtocol) {
        self.userDefaultsRepository = userDefaultsRepository
    }

    public func loadSearchHistories() {
        searchHistories = userDefaultsRepository.loadSearchHistories()
    }
}
