//
//  ProfileView.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/29.
//

import SwiftUI

public struct ProfileView: View {
    @Binding private var path: NavigationPath
    private let user: User
    @StateObject private var viewModel: ProfileViewModel
    @State private var isAlertPresented: Bool = false
    @State private var alertMessage: String?
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP")
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()

    public init(path: Binding<NavigationPath>, user: User, viewModel: ProfileViewModel) {
        _path = path
        self.user = user
        _viewModel = .init(wrappedValue: viewModel)
    }

    public var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerView
                itemsView
            }
        }
        .frame(maxHeight: .infinity)
        .background(Color(uiColor: .systemGroupedBackground))
        .alert("Error", isPresented: $isAlertPresented) {} message: {
            Text(alertMessage ?? "")
        }
        .onAppear {
            Task {
                await loadItems()
            }
        }
        .refreshable {
            await loadItems()
        }
    }

    private var headerView: some View {
        VStack(alignment: .leading, spacing: 16) {
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
    }

    private var itemsView: some View {
        LazyVStack(spacing: 0) {
            Section {
                ForEach(viewModel.items, id: \.id) { item in
                    VStack(spacing: 0) {
                        Divider()
                        itemView(item: item)
                    }
                }
            }
        }
        .frame(maxHeight: .infinity)
        .listRowInsets(.none)
    }

    private func itemView(item: Item) -> some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 0) {
                Text(item.title)
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
                Text(dateFormatter.string(from: item.createdAt))
                    .font(.subheadline)
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
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
            ProfileView(path: $path, user: User.mockUsers[0], viewModel: .init(userId: "Qiita", qiitaRepository: MockQiitaRepository()))
        }
    }
#endif
