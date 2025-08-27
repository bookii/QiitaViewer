//
//  MainView.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/26.
//

import SwiftUI

public struct MainView: View {
    @State private var path = NavigationPath()

    public var body: some View {
        NavigationStack(path: $path) {
            SearchView(viewModel: .init(userDefaultsRepository: UserDefaultsRepository()))
        }
    }
}

#if DEBUG
    #Preview {
        MainView()
    }
#endif
