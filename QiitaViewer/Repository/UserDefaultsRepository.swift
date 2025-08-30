//
//  UserDefaultsRepository.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/27.
//

import Foundation
import SwiftUICore

extension EnvironmentValues {
    @Entry var userDefaultsRepository: UserDefaultsRepositoryProtocol = UserDefaultsRepository()
}

public protocol UserDefaultsRepositoryProtocol {
    func loadSearchHistories() -> [SearchHistory]
}

public final class UserDefaultsRepository: UserDefaultsRepositoryProtocol {
    public init() {}

    public func loadSearchHistories() -> [SearchHistory] {
        // TODO: UserDefaults から取得する
        []
    }
}

#if DEBUG
    public final class MockUserDefaultsRepository: UserDefaultsRepositoryProtocol {
        public init() {}

        public func loadSearchHistories() -> [SearchHistory] {
            [
                .init(userId: "Qiita"),
                .init(userId: "rana_kualu"),
            ]
        }
    }
#endif
