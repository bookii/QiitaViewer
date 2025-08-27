//
//  MainView.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/26.
//

import SwiftUI

public struct MainView: View {
    @State private var path = NavigationPath()
    @StateObject private var searchViewModel: SearchViewModel

    public init(searchViewModel: SearchViewModel = .init()) {
        _searchViewModel = .init(wrappedValue: searchViewModel)
    }

    public var body: some View {
        NavigationStack(path: $path) {
            SearchView(path: $path, viewModel: searchViewModel)
        }
    }
}

#if DEBUG
    #Preview {
        MainView(searchViewModel: .init(userDefaultsRepository: MockUserDefaultsRepository(), qiitaRepository: MockQiitaRepository()))
    }
#endif
