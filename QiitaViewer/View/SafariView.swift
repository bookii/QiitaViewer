//
//  SafariView.swift
//  QiitaViewer
//
//  Created by Tsubasa YABUKI on 2025/08/30.
//

import Foundation
import SafariServices
import SwiftUI

/// - seealso: https://qiita.com/Ryu0118/items/e786fce09ac105f44f63
public struct SafariView: View {
    private let url: URL

    public init(url: URL) {
        self.url = url
    }

    public var body: some View {
        // NOTE: SafariContentView に .ignoresSafeArea() を適用すると完了ボタンの一部領域が反応しなくなる
        SafariContentView(url: url)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .background {
                Color(uiColor: .systemBackground)
                    .ignoresSafeArea()
            }
    }
}

private struct SafariContentView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    private let url: URL

    fileprivate init(url: URL) {
        self.url = url
    }

    fileprivate func makeUIViewController(context: Context) -> UINavigationController {
        let safariViewController = SFSafariViewController(url: url)
        safariViewController.delegate = context.coordinator
        safariViewController.preferredBarTintColor = .systemBackground

        // NOTE: 完了ボタンの一部領域が反応しなくなる問題を解消するために navigationController に埋め込む
        // ref: https://stackoverflow.com/questions/75998283/sfsafariviewcontroller-done-button-tappable-area-too-small/79150764
        let navigationController = UINavigationController(rootViewController: safariViewController)
        navigationController.setNavigationBarHidden(true, animated: false)
        return navigationController
    }

    fileprivate func updateUIViewController(_: UINavigationController, context _: Context) {}

    fileprivate func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    final class Coordinator: NSObject, SFSafariViewControllerDelegate {
        private let parent: SafariContentView

        fileprivate init(parent: SafariContentView) {
            self.parent = parent
        }

        func safariViewControllerDidFinish(_: SFSafariViewController) {
            parent.dismiss()
        }
    }
}

#if DEBUG

    #Preview {
        NavigationStack {
            SafariView(url: Item.mockItems[0].url)
        }
    }
#endif
