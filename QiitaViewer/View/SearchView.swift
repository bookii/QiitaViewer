//
//  SearchView.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/27.
//

import SwiftUI

public struct SearchView: View {
    @Environment(\.userDefaultsRepository) private var userDefaultsRepository
    @Environment(\.qiitaRepository) private var qiitaRepository
    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        SearchContentView(path: $path, viewModel: .init(userDefaultsRepository: userDefaultsRepository, qiitaRepository: qiitaRepository))
    }
}

private struct SearchContentView: View {
    private enum Destination: Hashable {
        case result(User)
    }

    @StateObject private var viewModel: SearchViewModel
    @Binding private var path: NavigationPath
    @State private var searchText = ""
    @State private var isAlertPresented: Bool = false
    @State private var alertMessage: String?
    @State private var isLoading: Bool = false

    fileprivate init(path: Binding<NavigationPath>, viewModel: SearchViewModel) {
        _path = path
        _viewModel = .init(wrappedValue: viewModel)
    }

    fileprivate var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                if !searchText.isEmpty {
                    Button {
                        search(userId: searchText)
                    } label: {
                        HStack(spacing: 0) {
                            Text("\(searchText) で検索")
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                        }
                    }
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .padding(.vertical, 8)
                }
                Text("検索履歴")
                    .font(.headline)
                    .padding(8)
                LazyVStack(alignment: .leading, spacing: 0) {
                    ForEach(viewModel.searchHistories.indices, id: \.self) { index in
                        let searchHistory = viewModel.searchHistories[index]
                        if index > 0 {
                            Divider()
                        }
                        Button {
                            search(userId: searchHistory.userId)
                        } label: {
                            Text(searchHistory.userId)
                                .foregroundStyle(Color(uiColor: .label))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(16)
                        }
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                    }
                }
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 16)
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("ユーザー検索")
        .navigationBarTitleDisplayMode(.inline)
        .searchable(text: $searchText, prompt: "ユーザーIDを入力")
        .overlay {
            if isLoading {
                ProgressView()
            }
        }
        .onSubmit(of: .search) {
            search(userId: searchText)
        }
        .alert("Error", isPresented: $isAlertPresented) {
            Button("OK") {
                alertMessage = nil
            }
        } message: {
            Text(alertMessage ?? "")
        }
        .onAppear {
            viewModel.loadSearchHistories()
        }
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case let .result(user):
                ProfileView(path: $path, user: user)
            }
        }
    }

    private func search(userId: String) {
        guard !isLoading else {
            return
        }
        isLoading = true
        Task {
            do {
                let user = try await viewModel.search(userId: userId)
                path.append(Destination.result(user))
            } catch {
                alertMessage = error.localizedDescription
                isAlertPresented = true
            }
            isLoading = false
        }
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var path = NavigationPath()

        NavigationStack(path: $path) {
            SearchView(path: $path)
        }
        .environment(\.userDefaultsRepository, MockUserDefaultsRepository())
        .environment(\.qiitaRepository, MockQiitaRepository())
    }
#endif
