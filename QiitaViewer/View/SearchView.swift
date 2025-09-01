//
//  SearchView.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/27.
//

import SwiftUI

public struct SearchView: View {
    fileprivate enum Destination: Hashable {
        case result(User)
    }

    @Environment(\.userDefaultsRepository) private var userDefaultsRepository
    @Environment(\.qiitaRepository) private var qiitaRepository
    @Binding private var path: NavigationPath

    public init(path: Binding<NavigationPath>) {
        _path = path
    }

    public var body: some View {
        SearchContentView(path: $path, viewModel: .init(userDefaultsRepository: userDefaultsRepository, qiitaRepository: qiitaRepository))
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case let .result(user):
                    ProfileView(path: $path, user: user)
                }
            }
    }
}

private struct SearchContentView: View {
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
                        let history = viewModel.searchHistories[index]
                        if index > 0 {
                            Divider()
                        }
                        HStack(spacing: 0) {
                            Button {
                                search(userId: history.userId)
                            } label: {
                                Text(history.userId)
                                    .foregroundStyle(Color(uiColor: .label))
                                    .padding(16)
                                Spacer()
                            }
                            .accessibilityHint("ダブルタップしてユーザーを検索します")
                            deleteHistoryButton(userId: history.userId)
                                .accessibilityHidden(true)
                        }
                        .background(Color(uiColor: .secondarySystemGroupedBackground))
                        .accessibilityElement(children: .combine)
                        .accessibilityActions {
                            deleteHistoryButton(userId: history.userId)
                        }
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
            do {
                try viewModel.loadSearchHistories()
            } catch {
                alertMessage = error.localizedDescription
                isAlertPresented = true
            }
        }
    }

    private func searchFromHistoryButton(userId: String) -> some View {
        Button {
            search(userId: userId)
        } label: {
            Text(userId)
                .foregroundStyle(Color(uiColor: .label))
                .padding(16)
            Spacer()
        }
    }

    private func deleteHistoryButton(userId: String) -> some View {
        Button {
            do {
                try viewModel.deleteSearchHistory(userId: userId)
            } catch {
                alertMessage = error.localizedDescription
                isAlertPresented = true
            }
        } label: {
            Image(systemName: "xmark")
                .resizable()
                .scaledToFit()
                .foregroundStyle(Color(uiColor: .secondaryLabel))
                .frame(width: 12, height: 12)
                .padding(16)
                .accessibilityLabel("検索履歴の削除")
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
                path.append(SearchView.Destination.result(user))
                // 画面遷移が完了してから保存と searchBar のクリアを行う
                try? await Task.sleep(for: .seconds(1))
                try viewModel.saveSearchHistory(.init(userId: user.id))
                searchText = ""
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
        NavigationView { path in
            SearchView(path: path)
        }
        .environment(\.userDefaultsRepository, MockUserDefaultsRepository())
        .environment(\.qiitaRepository, MockQiitaRepository())
    }
#endif
