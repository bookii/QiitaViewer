//
//  ProfileView.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/29.
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
    private enum Destination: Hashable {
        case item(URL)
    }

    @StateObject private var viewModel: ProfileViewModel
    @Binding private var path: NavigationPath
    private let user: User
    @State private var isAlertPresented: Bool = false
    @State private var alertMessage: String?
    @State private var isSheetPresented: Bool = false
    @State private var selectedFollowType: FollowView.FollowType?
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
        .alert("Error", isPresented: $isAlertPresented) {
            Button("OK") {
                alertMessage = nil
            }
        } message: {
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
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case let .item(url):
                SafariView(url: url)
            }
        }
        .sheet(item: $selectedFollowType) { selectedFollowType in
            FollowView(userId: user.id, followType: selectedFollowType)
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                AsyncImage(url: user.profileImageUrl) { imagePhase in
                    imagePhase.image?.resizable()
                }
                .scaledToFit()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                Text("@\(user.id)")
                    .font(.headline)
                Spacer()
            }
            // 見た目が左揃えになるように調整する
            .offset(x: -1)
            if let description = user.description {
                Text(description)
                    .font(.body)
                    .multilineTextAlignment(.leading)
            }
            HStack(spacing: 16) {
                Button {
                    selectedFollowType = .followee
                    isSheetPresented = true
                } label: {
                    HStack(spacing: 6) {
                        Text(String(user.followeesCount))
                            .font(.headline)
                            .foregroundStyle(Color(uiColor: .label))
                        Text("フォロー")
                            .font(.subheadline)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
                }
                Button {
                    selectedFollowType = .follower
                    isSheetPresented = true
                } label: {
                    HStack(spacing: 6) {
                        Text(String(user.followersCount))
                            .font(.headline)
                            .foregroundStyle(Color(uiColor: .label))
                        Text("フォロワー")
                            .font(.subheadline)
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                    }
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
                            itemButton(item: viewModel.items[index])
                        }
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .padding(16)
    }

    private func itemButton(item: Item) -> some View {
        Button {
            path.append(Destination.item(item.url))
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                if let createdAt = item.createdAt {
                    Text(dateFormatter.string(from: createdAt))
                        .font(.caption)
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }
                HStack(spacing: 0) {
                    Text(item.title)
                        .font(.headline)
                        .foregroundStyle(Color(uiColor: .label))
                        .multilineTextAlignment(.leading)
                    Spacer(minLength: 0)
                }
                HStack(spacing: 0) {
                    HStack(spacing: 4) {
                        Image(systemName: "heart")
                            .resizable()
                            .scaledToFit()
                            .foregroundStyle(Color(uiColor: .secondaryLabel))
                            .frame(width: 12, height: 12)
                        Text(String(item.likesCount))
                            .font(.subheadline)
                            .foregroundStyle(Color(uiColor: .label))
                    }
                    Spacer(minLength: 8)
                }
                ScrollView(.horizontal) {
                    HStack(spacing: 8) {
                        ForEach(item.tags, id: \.name) { tag in
                            Text(tag.name)
                                .font(.caption)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 4)
                                .background(in: RoundedRectangle(cornerRadius: 4))
                                .backgroundStyle(Color(uiColor: .tertiarySystemGroupedBackground))
                        }
                    }
                    // hitTest を少し広げておく
                    .padding(.vertical, 4)
                }
                // hitTest を広げた分を戻しておく
                .padding(.vertical, -4)
                // 見た目の間隔が均等に近づくように調整する
                .padding(.top, 2)
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
                .scrollIndicators(.hidden)
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
        }
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
