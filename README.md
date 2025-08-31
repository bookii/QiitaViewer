# QiitaViewer

Qiita ユーザーのプロフィールや記事を閲覧できるアプリです。

## ビルド方法

1. リポジトリをクローンします。

```zsh
$ git clone https://github.com/bookii/QiitaViewer.git
```

2. Xcode で `QiitaViewer.xcodeproj` を開きます。
3. ビルドの実行に設定の変更などは不要なはずですが、もし失敗する場合は `Targets > Signing & Capabilities` などを見直してみてください。

## 機能説明

### 検索画面 (トップ)

- ユーザーIDで検索して、ヒットしたらプロフィール画面にプッシュ遷移します。
- ヒットしない場合は返ってきたエラーがアラートで表示されます。
- ヒットした検索履歴は端末に保存されます。

![search-view-demo](https://github.com/user-attachments/assets/467c267c-0450-4580-ac37-3a43a833ff02)

### プロフィール画面

- ユーザーのプロフィールと投稿一覧が表示されます。
- フォロー数またはフォロワー数をタップすると、フォロー/フォロワー画面がモーダル表示されます。
- 投稿をタップすると投稿閲覧画面にプッシュ遷移します。

![profile-view-demo](https://github.com/user-attachments/assets/8047dbc9-07d2-45f3-8d45-132b968a7445)

### フォロー/フォロワー画面

- 指定したユーザーがフォローしている人 (フォロー) と、指定したユーザーをフォローしている人 (フォロワー) が表示されます。
- タブをタップまたは左右スワイプでフォロー/フォロワーの切り替えが可能です。
- ユーザーをタップでプロフィール画面にプッシュ遷移します。

![follow-view-demo](https://github.com/user-attachments/assets/bb63e3cb-5d0e-4a8b-8f11-490dc9a528a2)

### 投稿閲覧画面

- アプリにビルトインされた Safari で投稿を閲覧できます。
- 実装の都合で、ナビゲーションバーの見た目に不自然な部分があります。

https://github.com/user-attachments/assets/71d53daf-f3b2-48d0-a2be-131291343009

## 開発マニュアル

### フレームワーク

SwiftUI です。

### アーキテクチャ

MVVM アーキテクチャを採用しています。<br />
各画面の View と ViewModel は一対一て対応しています (例: `SearchView` に対して `SearchViewModel` が存在する) 。

Model, View, ViewModel の他に Repository 層が存在していて、各 ViewModel に対して必要な Repository (例: QiitaRepository) を注入する形をとっています。

### Xcode Previews について

画面単体だけでなく、他の画面への遷移も含めて Xcode Previews で確認できるようになっています。

![xcode-preview-demo](https://github.com/user-attachments/assets/8613b6a1-ba4c-49fc-b0e8-506eacb39c4e)

### ドキュメントのフォーマット

Swift Package Manager 経由で [nicklockwood/SwiftFormat](nicklockwood/SwiftFormat) を import しているため、プロジェクトを右クリック > `SwiftFormatPlugin` の選択でコードのフォーマットが可能です。

![swiftformat-demo](https://github.com/user-attachments/assets/a7010a56-77a7-4a79-855f-438364d9360f)
