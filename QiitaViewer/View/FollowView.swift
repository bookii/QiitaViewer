//
//  FollowView.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/30.
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
        FollowContentView(path: $path, userId: userId, followType: followType, viewModel: .init(userId: userId, qiitaRepository: qiitaRepository))
    }
}

private struct FollowContentView: View {
    fileprivate typealias FollowType = FollowView.FollowType

    private enum Destination: Hashable {
        case user(User)
    }

    @StateObject private var viewModel: FollowViewModel
    @Binding private var path: NavigationPath
    private let userId: String
    private let followTypes = FollowType.allCases
    @State private var selectedFollowTypeIndex: Int
    private var selectedFollowType: FollowType {
        followTypes[selectedFollowTypeIndex]
    }

    @State private var isAlertPresented: Bool = false
    @State private var alertMessage: String?

    fileprivate init(path: Binding<NavigationPath>, userId: String, followType: FollowType, viewModel: FollowViewModel) {
        _path = path
        self.userId = userId
        selectedFollowTypeIndex = followTypes.firstIndex(of: followType) ?? 0
        _viewModel = .init(wrappedValue: viewModel)
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
                alertMessage = nil
            }
        } message: {
            Text(alertMessage ?? "")
        }
        .animation(.default, value: selectedFollowType)
        .onChange(of: selectedFollowType, initial: true) { _, newValue in
            Task {
                do {
                    switch newValue {
                    case .followee:
                        if viewModel.followees == nil {
                            try await viewModel.loadFollowees()
                        }
                    case .follower:
                        if viewModel.followers == nil {
                            try await viewModel.loadFollowers()
                        }
                    }
                } catch {
                    alertMessage = error.localizedDescription
                    isAlertPresented = true
                }
            }
        }
        .navigationDestination(for: Destination.self) { destination in
            switch destination {
            case let .user(user):
                ProfileView(path: $path, user: user)
            }
        }
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
                selectedFollowTypeIndex = min(selectedFollowTypeIndex + 1, followTypes.count)
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
            Group {
                if let followees = viewModel.followees {
                    usersView(followees)
                } else {
                    ProgressView()
                        .padding(.vertical, 24)
                }
            }
            .tag(followTypes.firstIndex(of: .followee)!)
            Group {
                if let followers = viewModel.followers {
                    usersView(followers)
                } else {
                    ProgressView()
                        .padding(.vertical, 24)
                }
            }
            .tag(followTypes.firstIndex(of: .follower)!)
        }
        .ignoresSafeArea(edges: .bottom)
        .tabViewStyle(.page(indexDisplayMode: .never))
    }

    private func usersView(_ users: [User]) -> some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(users.indices, id: \.self) { index in
                    let user = users[index]
                    if index > 0 {
                        Divider()
                    }
                    userView(user)
                }
            }
            .background {
                Color(uiColor: .secondarySystemGroupedBackground)
            }
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .padding(16)
        }
    }

    private func userView(_ user: User) -> some View {
        Button {
            path.append(Destination.user(user))
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
                .environment(\.qiitaRepository, MockQiitaRepository())
        }
    }
#endif
