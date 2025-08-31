//
//  SearchHistory.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/27.
//

import Foundation

public struct SearchHistory: Codable, Equatable {
    public let userId: String
}

#if DEBUG
public extension SearchHistory {
    static var mockSearchHistories: [SearchHistory] {
        [
            .init(userId: "Qiita"),
            .init(userId: "rana_kualu"),
        ]
    }
}
#endif
