# QiitaViewer

Qiita ユーザーのプロフィールや投稿を閲覧できるアプリです。

## ビルド方法

1. リポジトリをクローンします。

```zsh
$ git clone https://github.com/bookii/QiitaViewer.git
```

2. Xcode で `QiitaViewer.xcodeproj` を開きます。
3. ビルドの実行に設定の変更などは不要なはずですが、もし失敗する場合は `Targets > Signing & Capabilities` などを見直してみてください。

## 開発マニュアル

### フレームワーク

SwiftUI です。

### アーキテクチャ

MVVM アーキテクチャを採用しています。<br />
各画面の View と ViewModel は一対一て対応しています (例: `SearchView` に対して `SearchViewModel` が存在する) 。

Model, View, ViewModel の他に Repository 層が存在していて、各 ViewModel に対して必要な Repository (例: QiitaRepository) を注入する形をとっています。

### Xcode Previews について

画面単体だけでなく、他の画面への遷移も含めて Xcode Previews で確認できるようになっています。

https://github.com/user-attachments/assets/64b8bdfe-231f-411a-9c3e-4b84cd79472e

### ドキュメントのフォーマット

Swift Package Manager 経由で [nicklockwood/SwiftFormat](nicklockwood/SwiftFormat) を import しているため、プロジェクトを右クリック > `SwiftFormatPlugin` の選択でコードのフォーマットが可能です。

https://github.com/user-attachments/assets/0f13f0b7-78c0-4773-87ed-17ae7df7f755

## 機能説明

### 検索画面 (トップ)

- ユーザーIDで検索して、ヒットしたらプロフィール画面にプッシュ遷移します。
- ヒットしない場合は返ってきたエラーがアラートで表示されます。
- ヒットした検索履歴は端末に保存されます。

https://github.com/user-attachments/assets/98183066-a9df-4632-89b9-7ff6f7a4df9c

### プロフィール画面

- ユーザーのプロフィールと投稿一覧が表示されます。
- フォロー数またはフォロワー数をタップすると、フォロー/フォロワー画面がモーダル表示されます。
- 投稿をタップすると投稿閲覧画面にプッシュ遷移します。
- 投稿一覧の無限スクロールに対応しています（動画収録後に対応）。
  - Qiita API は非認証だと IP アドレスごとに 1 時間あたり 60 回までしかリクエストを受け付けていないので、動作確認時は注意してください。

https://github.com/user-attachments/assets/b2cf2229-ae35-46c5-9aa9-8c52b93eecca

### フォロー/フォロワー画面

- 指定したユーザーがフォローしている人 (フォロー) と、指定したユーザーをフォローしている人 (フォロワー) が表示されます。
- タブをタップまたは左右スワイプでフォロー/フォロワーの切り替えが可能です。
- ユーザーをタップでプロフィール画面にプッシュ遷移します。
- フォロー/フォロワー一覧の無限スクロールに対応しています（動画収録後に対応）。
  - Qiita API は非認証では IP アドレスごとに 1 時間あたり 60 回までしかリクエストを受け付けていないので、動作確認時は注意してください。

https://github.com/user-attachments/assets/4365e901-b539-44bb-8f6b-5fb981d0c59e

### 投稿閲覧画面

- アプリにビルトインされた Safari で投稿を閲覧できます。
- 実装の都合で、ナビゲーションバーの見た目に不自然な部分があります。

https://github.com/user-attachments/assets/467216e1-e21e-44cb-894c-c880173c885e

### VoiceOver 機能について

本アプリでは、画面読み上げ機能である VoiceOver でユーザーが操作しやすいように、読み上げ文言の設定やコンポーネントのチャンク化などの対応を行っています。

#### 検索画面

https://github.com/user-attachments/assets/38241e23-3f32-403e-acd2-11e8ee03625d

#### プロフィール画面

https://github.com/user-attachments/assets/8c0f7e33-9d72-46c6-b4a7-2431ae685436

#### フォロー/フォロワー画面

https://github.com/user-attachments/assets/07c1c366-a3d1-4279-8100-cbe7da958fc9
