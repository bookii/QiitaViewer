//
//  ProfileViewModel.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/29.
//

import Foundation

public class ProfileViewModel: ObservableObject {
    @Published public private(set) var items: [Item] = []

    private let userId: String
    private let qiitaRepository: QiitaRepositoryProtocol

    public init(userId: String, qiitaRepository: QiitaRepositoryProtocol = QiitaRepository()) {
        self.userId = userId
        self.qiitaRepository = qiitaRepository
    }

    public func loadItems() async throws {
        items = try await qiitaRepository.fetchItems(userId: userId)
    }
}
