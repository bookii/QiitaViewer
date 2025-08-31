//
//  NavigationView.swift
//  QiitaViewer
//
//  Created by bookii on 2025/08/31.
//

import SwiftUI

public struct NavigationView<Content: View>: View {
    @State private var path = NavigationPath()
    private let content: (Binding<NavigationPath>) -> Content

    public init(@ViewBuilder content: @escaping (Binding<NavigationPath>) -> Content) {
        self.content = content
    }

    public var body: some View {
        NavigationStack(path: $path) {
            content($path)
        }
    }
}

#if DEBUG
    #Preview {
        NavigationView { path in
            ProfileView(path: path, user: User.mockUsers[0])
        }
        .environment(\.qiitaRepository, MockQiitaRepository())
    }
#endif
