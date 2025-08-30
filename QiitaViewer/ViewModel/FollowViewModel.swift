//
//  FollowViewModel.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/30.
//

import Foundation

public class FollowViewModel: ObservableObject {
    @Published public private(set) var followees: [User]?
    @Published public private(set) var followers: [User]?

    private let userId: String
    private let qiitaRepository: QiitaRepositoryProtocol

    public init(userId: String, qiitaRepository: QiitaRepositoryProtocol) {
        self.userId = userId
        self.qiitaRepository = qiitaRepository
    }

    @MainActor
    public func loadFollowees() async throws {
        followees = try await qiitaRepository.fetchFollowees(userId: userId)
    }

    @MainActor
    public func loadFollowers() async throws {
        followers = try await qiitaRepository.fetchFollowers(userId: userId)
    }
}
