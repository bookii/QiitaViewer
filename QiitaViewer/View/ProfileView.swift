//
//  ProfileView.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/29.
//

import SwiftUI

public struct ProfileView: View {
    @Environment(\.qiitaRepository) private var qiitaRepository
    @Binding private var path: NavigationPath
    private let user: User
    
    public init(path: Binding<NavigationPath>, user: User) {
        _path = path
        self.user = user
    }
    
    public var body: some View {
        ProfileContentView(path: $path, user: user, viewModel: ProfileViewModel(userId: user.id, qiitaRepository: qiitaRepository))
    }
}

private struct ProfileContentView: View {
    @StateObject private var viewModel: ProfileViewModel
    @Binding private var path: NavigationPath
    private let user: User
    @State private var isAlertPresented: Bool = false
    @State private var alertMessage: String?
    @State private var isInitialLoading: Bool = true
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    fileprivate init(path: Binding<NavigationPath>, user: User, viewModel: ProfileViewModel) {
        _path = path
        self.user = user
        _viewModel = .init(wrappedValue: viewModel)
    }

    fileprivate var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                if isInitialLoading {
                    initialLoadingView
                } else {
                    itemsView
                }
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .navigationTitle("プロフィール")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $isAlertPresented) {} message: {
            Text(alertMessage ?? "")
        }
        .onAppear {
            Task {
                await loadItems()
                isInitialLoading = false
            }
        }
        .refreshable {
            await loadItems()
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AsyncImage(url: user.profileImageUrl) { imagePhase in
                    imagePhase.image?.resizable()
                }
                .scaledToFit()
                .frame(width: 64, height: 64)
                .clipShape(Circle())
                Text("@\(user.id)")
                    .font(.headline)
                Spacer()
            }
            if let description = user.description {
                Text(description)
                    .font(.body)
            }
            HStack(spacing: 16) {
                HStack(spacing: 6) {
                    Text(String(user.followeesCount))
                        .font(.headline)
                    Text("フォロー")
                        .font(.subheadline)
                }
                HStack(spacing: 6) {
                    Text(String(user.followersCount))
                        .font(.headline)
                    Text("フォロワー")
                        .font(.subheadline)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal, 16)
    }
    
    private var initialLoadingView: some View {
        ProgressView()
            .padding(.vertical, 24)
    }

    private var itemsView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("投稿一覧")
                .font(.headline)
                .padding(8)
            LazyVStack(spacing: 0) {
                Section {
                    ForEach(viewModel.items.indices, id: \.self) { index in
                        if index > 0 {
                            Divider()
                        }
                        VStack(spacing: 0) {
                            itemView(item: viewModel.items[index])
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
    }

    private func itemView(item: Item) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 0) {
                Text(item.title)
                    .font(.headline)
                Spacer(minLength: 0)
            }
            HStack(spacing: 0) {
                HStack(spacing: 6) {
                    Text(String(item.likesCount))
                        .font(.headline)
                    Text("LGTM")
                        .font(.subheadline)
                }
                Spacer(minLength: 8)
                if let createdAt = item.createdAt {
                    Text(dateFormatter.string(from: createdAt))
                        .font(.footnote)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
    }

    private func loadItems() async {
        do {
            try await viewModel.loadItems()
        } catch {
            alertMessage = error.localizedDescription
            isAlertPresented = true
        }
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var path = NavigationPath()

        NavigationStack(path: $path) {
            ProfileView(path: $path, user: User.mockUsers[0])
        }
        .environment(\.qiitaRepository, MockQiitaRepository())
    }
#endif
