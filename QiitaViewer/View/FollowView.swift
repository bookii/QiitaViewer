//
//  FollowView.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/30.
//

import SwiftUI

public struct FollowView: View {
    public enum FollowType: Int, CaseIterable, Identifiable {
        case followee
        case follower

        public var id: Int {
            rawValue
        }
    }

    fileprivate enum Destination: Hashable {
        case user(User)
    }

    @Environment(\.qiitaRepository) private var qiitaRepository
    @Binding private var path: NavigationPath
    private let userId: String
    private let followType: FollowType

    public init(path: Binding<NavigationPath>, userId: String, followType: FollowType) {
        _path = path
        self.userId = userId
        self.followType = followType
    }

    public var body: some View {
        FollowContentView(path: $path, userId: userId, followType: followType,
                          followeeViewModel: FolloweeViewModel(userId: userId, qiitaRepository: qiitaRepository),
                          followerViewModel: FollowerViewModel(userId: userId, qiitaRepository: qiitaRepository))
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case let .user(user):
                    ProfileView(path: $path, user: user)
                }
            }
    }
}

private struct FollowContentView<FolloweeViewModel: FollowViewModel, FollowerViewModel: FollowViewModel>: View {
    fileprivate typealias FollowType = FollowView.FollowType

    @StateObject private var followeeViewModel: FolloweeViewModel
    @StateObject private var followerViewModel: FollowerViewModel
    @Binding private var path: NavigationPath
    private let userId: String
    private let followTypes = FollowType.allCases
    @State private var selectedFollowTypeIndex: Int
    private var selectedFollowType: FollowType {
        followTypes[selectedFollowTypeIndex]
    }

    @State private var isAlertPresented: Bool = false
    @State private var alertMessage: String = ""

    fileprivate init(path: Binding<NavigationPath>, userId: String, followType: FollowType, followeeViewModel: FolloweeViewModel, followerViewModel: FollowerViewModel) {
        _path = path
        self.userId = userId
        selectedFollowTypeIndex = followTypes.firstIndex(of: followType) ?? 0
        _followeeViewModel = .init(wrappedValue: followeeViewModel)
        _followerViewModel = .init(wrappedValue: followerViewModel)
    }

    fileprivate var body: some View {
        VStack(spacing: 0) {
            tabView
            pageView
        }
        .background {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea(edges: .bottom)
        }
        .navigationTitle("@\(userId) のフォロー / フォロワー")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $isAlertPresented) {
            Button("OK") {
                alertMessage = ""
            }
        } message: {
            Text(alertMessage)
        }
        .animation(.default, value: selectedFollowType)
    }

    private var tabView: some View {
        HStack(spacing: 0) {
            ForEach(followTypes.indices, id: \.self) { index in
                Button {
                    selectedFollowTypeIndex = index
                } label: {
                    VStack(spacing: 0) {
                        Text(followTypes[index].title)
                            .font(.headline)
                            .foregroundStyle(Color(uiColor: index == selectedFollowTypeIndex ? .qiitaPrimary : .secondaryLabel))
                            .padding(.vertical, 8)
                        Capsule()
                            .frame(height: 2)
                            .foregroundStyle(Color(uiColor: index == selectedFollowTypeIndex ? .qiitaPrimary : .clear))
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.horizontal, 16)
        .background {
            Color(uiColor: .systemBackground)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("フォロー, フォロワーの切り替え")
        .accessibilityValue(selectedFollowType.title)
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                selectedFollowTypeIndex = min(selectedFollowTypeIndex + 1, followTypes.count - 1)
            case .decrement:
                selectedFollowTypeIndex = max(selectedFollowTypeIndex - 1, 0)
            @unknown default:
                // NOP
                break
            }
        }
    }

    private var pageView: some View {
        TabView(selection: $selectedFollowTypeIndex) {
            PageContentView(path: $path, isAlertPresented: $isAlertPresented, alertMessage: $alertMessage, viewModel: followeeViewModel)
                .tag(followTypes.firstIndex(of: .followee)!)
            PageContentView(path: $path, isAlertPresented: $isAlertPresented, alertMessage: $alertMessage, viewModel: followerViewModel)
                .tag(followTypes.firstIndex(of: .follower)!)
        }
        .ignoresSafeArea(edges: .bottom)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }
}

private struct PageContentView<ViewModel: FollowViewModel>: View {
    @Binding private var path: NavigationPath
    @Binding private var isAlertPresented: Bool
    @Binding private var alertMessage: String
    @ObservedObject private var viewModel: ViewModel
    @State private var loadingTask: Task<Void, Never>?
    @State private var isInitiallyLoaded: Bool = false

    fileprivate init(path: Binding<NavigationPath>, isAlertPresented: Binding<Bool>, alertMessage: Binding<String>, viewModel: ViewModel) {
        _path = path
        _isAlertPresented = isAlertPresented
        _alertMessage = alertMessage
        self.viewModel = viewModel
    }

    fileprivate var body: some View {
        Group {
            if isInitiallyLoaded {
                usersView
            } else {
                ProgressView()
                    .padding(.vertical, 24)
            }
        }
        .onAppear {
            loadingTask = Task {
                do {
                    try await viewModel.reloadUsers()
                } catch {
                    presentErrorAlert(error: error)
                }
                isInitiallyLoaded = true
                loadingTask = nil
            }
        }
    }

    private var usersView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                let users = viewModel.users
                ForEach(users.indices, id: \.self) { index in
                    if index > 0 {
                        Divider()
                    }
                    userView(users[index])
                        .onAppear {
                            guard index == users.count - 1, loadingTask == nil else {
                                return
                            }
                            loadingTask = Task {
                                do {
                                    try await viewModel.loadMoreUsers()
                                } catch {
                                    presentErrorAlert(error: error)
                                }
                                loadingTask = nil
                            }
                        }
                }
            }
            .background {
                Color(uiColor: .secondarySystemGroupedBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(16)
        }
        .refreshable {
            loadingTask?.cancel()
            let task = Task {
                do {
                    try await viewModel.reloadUsers()
                } catch {
                    presentErrorAlert(error: error)
                }
                loadingTask = nil
            }
            loadingTask = task
            await task.value
        }
    }

    private func userView(_ user: User) -> some View {
        Button {
            path.append(FollowView.Destination.user(user))
        } label: {
            HStack(spacing: 0) {
                AsyncImage(url: user.profileImageUrl) { imagePhase in
                    imagePhase.image?.resizable()
                }
                .scaledToFit()
                .frame(width: 56, height: 56)
                .clipShape(Circle())
                Spacer().frame(width: 12)
                VStack(alignment: .leading, spacing: 8) {
                    Text("@\(user.id)")
                        .font(.headline)
                    HStack(spacing: 16) {
                        HStack(spacing: 6) {
                            Text(String(user.followeesCount))
                                .font(.headline)
                            Text("フォロー")
                                .font(.subheadline)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                        }
                        HStack(spacing: 6) {
                            Text(String(user.followersCount))
                                .font(.headline)
                            Text("フォロワー")
                                .font(.subheadline)
                                .foregroundStyle(Color(uiColor: .secondaryLabel))
                        }
                    }
                }
                .foregroundStyle(Color(uiColor: .label))
                Spacer(minLength: 0)
            }
            // ProfileView に合わせておく
            .offset(x: -1)
            .padding(16)
        }
        .accessibilityHint("ダブルタップでプロフィールを表示します")
    }

    private func presentErrorAlert(error: Error) {
        alertMessage = error.localizedDescription
        isAlertPresented = true
    }
}

private extension FollowView.FollowType {
    var title: String {
        switch self {
        case .followee:
            "フォロー"
        case .follower:
            "フォロワー"
        }
    }
}

#if DEBUG
    #Preview {
        NavigationView { path in
            FollowView(path: path, userId: User.mockUsers[0].id, followType: .followee)
        }
        .environment(\.qiitaRepository, MockQiitaRepository())
    }
#endif
