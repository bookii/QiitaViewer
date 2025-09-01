//
//  ProfileViewModel.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/29.
//

import Foundation

public class ProfileViewModel: ObservableObject {
    @Published public private(set) var items: [Item] = []
    private var page: Int?

    private let userId: String
    private let qiitaRepository: QiitaRepositoryProtocol

    public init(userId: String, qiitaRepository: QiitaRepositoryProtocol) {
        self.userId = userId
        self.qiitaRepository = qiitaRepository
    }

    @MainActor
    public func reloadItems() async throws {
        (items, page) = try await qiitaRepository.fetchItems(userId: userId, page: nil)
    }

    @MainActor
    public func loadMoreItems() async throws {
        let (newItems, newPage) = try await qiitaRepository.fetchItems(userId: userId, page: page)
        items.append(contentsOf: newItems)
        page = newPage
    }
}
