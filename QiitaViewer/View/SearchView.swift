//
//  SearchView.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/27.
//

import SwiftUI

public struct SearchView: View {
    @StateObject private var viewModel: SearchViewModel
    @State private var searchText = ""

    public init(viewModel: SearchViewModel) {
        _viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        List {
            Section("過去の検索ワード") {
                ForEach(viewModel.searchHistories, id: \.userId) { searchHistory in
                    Text(searchHistory.userId)
                }
            }
        }
        .searchable(text: $searchText)
        .onAppear {
            viewModel.loadSearchHistories()
        }
    }
}

#if DEBUG
    #Preview {
        NavigationStack {
            SearchView(viewModel: .init(userDefaultsRepository: MockUserDefaultsRepository()))
        }
    }
#endif
