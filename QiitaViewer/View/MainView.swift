//
//  MainView.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/26.
//

import SwiftUI

public struct MainView: View {
    @State private var path = NavigationPath()
    private let userDefaultsRepository: UserDefaultsRepositoryProtocol
    private let qiitaRepository: QiitaRepositoryProtocol

    public init(userDefaultsRepository: UserDefaultsRepositoryProtocol = UserDefaultsRepository(),
                qiitaRepository: QiitaRepositoryProtocol = QiitaRepository())
    {
        self.userDefaultsRepository = userDefaultsRepository
        self.qiitaRepository = qiitaRepository
    }

    public var body: some View {
        NavigationStack(path: $path) {
            SearchView(path: $path)
        }
        .environment(\.userDefaultsRepository, userDefaultsRepository)
        .environment(\.qiitaRepository, qiitaRepository)
    }
}

#if DEBUG
    #Preview {
        MainView(userDefaultsRepository: MockUserDefaultsRepository(), qiitaRepository: MockQiitaRepository())
    }
#endif
