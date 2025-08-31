//
//  UserDefaultsRepository.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/27.
//

import Foundation
import SwiftUICore

extension EnvironmentValues {
    @Entry var userDefaultsRepository: UserDefaultsRepositoryProtocol = UserDefaultsRepository()
}

public protocol UserDefaultsRepositoryProtocol {
    func loadSearchHistories() throws -> [SearchHistory]
    func saveSearchHistory(_ history: SearchHistory) throws
    func deleteSearchHistory(_ history: SearchHistory) throws
}

public final class UserDefaultsRepository: UserDefaultsRepositoryProtocol {
    private let searchHistoriesKey = "searchHistories"

    public init() {}

    private var cachedSearchHistories: [SearchHistory]?

    public func loadSearchHistories() throws -> [SearchHistory] {
        if cachedSearchHistories == nil {
            try cacheSearchHistories()
        }
        return cachedSearchHistories ?? []
    }

    public func saveSearchHistory(_ history: SearchHistory) throws {
        if cachedSearchHistories == nil {
            try cacheSearchHistories()
        }
        cachedSearchHistories!.removeAll(where: { $0.userId == history.userId })
        cachedSearchHistories!.insert(history, at: 0)
        try saveCachedSearchHistories()
    }

    public func deleteSearchHistory(_ history: SearchHistory) throws {
        if cachedSearchHistories == nil {
            try cacheSearchHistories()
        }
        cachedSearchHistories!.removeAll(where: { $0.userId == history.userId })
        try saveCachedSearchHistories()
    }

    private func cacheSearchHistories() throws {
        guard let data = UserDefaults.standard.data(forKey: searchHistoriesKey) else {
            cachedSearchHistories = []
            return
        }
        cachedSearchHistories = try JSONDecoder().decode([SearchHistory].self, from: data)
    }

    private func saveCachedSearchHistories() throws {
        let data = try JSONEncoder().encode(cachedSearchHistories)
        UserDefaults.standard.set(data, forKey: searchHistoriesKey)
    }
}

#if DEBUG
    public final class MockUserDefaultsRepository: UserDefaultsRepositoryProtocol {
        private var searchHistories: [SearchHistory] = [
            .init(userId: "Qiita"),
            .init(userId: "rana_kualu"),
        ]

        public init() {}

        public func loadSearchHistories() -> [SearchHistory] {
            searchHistories
        }

        public func saveSearchHistory(_ history: SearchHistory) {
            searchHistories.insert(history, at: 0)
        }

        public func deleteSearchHistory(_ history: SearchHistory) {
            searchHistories.removeAll(where: { $0.userId == history.userId })
        }
    }
#endif
