//
//  ProfileView.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/29.
//

import SwiftUI

public struct ProfileView: View {
    @Binding private var path: NavigationPath
    private let user: User

    public init(path: Binding<NavigationPath>, user: User) {
        _path = path
        self.user = user
    }

    public var body: some View {
        VStack(spacing: 0) {
            header
            Spacer()
                .frame(maxHeight: .infinity)
        }
        .background(Color(uiColor: .secondarySystemBackground))
    }
    
    private var header: some View {
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
                HStack(spacing: 4) {
                    Text(String(user.followeesCount))
                        .font(.headline)
                    Text("フォロー")
                        .font(.subheadline)
                }
                HStack(spacing: 4) {
                    Text(String(user.followersCount))
                        .font(.headline)
                    Text("フォロワー")
                        .font(.subheadline)
                }
            }
        }
        .padding(16)
        .background(Color(uiColor: .systemBackground))
    }
}

#if DEBUG
    #Preview {
        @Previewable @State var path = NavigationPath()

        NavigationStack(path: $path) {
            ProfileView(path: $path, user: User.mockUsers[0])
        }
    }
#endif
