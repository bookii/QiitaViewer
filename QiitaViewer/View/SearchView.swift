//
//  SearchView.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/27.
//

import SwiftUI

public struct SearchView: View {
    private enum Destination: Hashable {
        case result(User)
    }

    @Binding private var path: NavigationPath
    @StateObject private var viewModel: SearchViewModel
    @State private var searchText = ""
    @State private var isAlertPresented: Bool = false
    @State private var alertMessage: String?

    public init(path: Binding<NavigationPath>, viewModel: SearchViewModel) {
        _path = path
        _viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        List {
            if !searchText.isEmpty {
                Section {
                    Button("\(searchText) で検索") {
                        search(userId: searchText)
                    }
                }
            }
            Section("検索履歴") {
                ForEach(viewModel.searchHistories, id: \.userId) { searchHistory in
                    Button(searchHistory.userId) {
                        search(userId: searchHistory.userId)
                    }
                    .foregroundStyle(.primary)
                }
            }
        }
        .searchable(text: $searchText, prompt: "ユーザーIDを入力")
        .onSubmit {
            search(userId: searchText)
        }
        .alert("Error", isPresented: $isAlertPresented) {} message: {
            Text(alertMessage ?? "")
        }
        .onAppear {
            viewModel.loadSearchHistories()
        }
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case let .result(user):
                // TODO: プロフィール画面の実装
                Text(user.id)
            }
        }
    }

    private func search(userId: String) {
        Task {
            do {
                let user = try await viewModel.search(userId: userId)
                path.append(Destination.result(user))
            } catch {
                alertMessage = error.localizedDescription
                isAlertPresented = true
            }
        }
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var path = NavigationPath()
        NavigationStack(path: $path) {
            SearchView(path: $path, viewModel: .init(userDefaultsRepository: MockUserDefaultsRepository(), qiitaRepository: MockQiitaRepository()))
        }
    }
#endif
