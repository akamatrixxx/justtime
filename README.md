# justtime

Flutter製の日次通知＋フィードバックアプリ。
毎日の通知タイミングにユーザーがフィードバック（ちょうどいい／早い／遅い）を返すことで、翌日の通知時刻が自動で調整されます。

## 機能概要

- 初回起動時に勤務時間・睡眠時間を設定
- 勤務時間帯の中央値で通知を予約
- 通知バナー上の3つのクイックアクションでフィードバック送信（アプリを開く必要なし）
- フィードバック種別に応じて翌日の通知時刻を ±30 分調整
- 通知履歴をCSVでダウンロード（Android: Download フォルダ、iOS: ファイルApp）
- iOSライクな Cupertino UI

## 技術スタック

- Flutter（Dart SDK ^3.11.0）
- SQLite（`sqflite`）
- ローカル通知（`flutter_local_notifications`）
- タイムゾーン（`timezone` / Asia/Tokyo）
- CSV書き出し（`file_saver`）

## セットアップ

### 共通

```sh
flutter pub get
```

### iOS

Mac + Xcode 15+ + CocoaPods が必要。

```sh
cd ios
pod install
cd ..
```

シミュレータで動かす:
```sh
open -a Simulator
flutter run -d "iPhone 15"
```

### Android

```sh
flutter run -d <device_id>
```

## TestFlight へのアップロード手順

前提: Apple Developer アカウント（有償）、Xcode 15+、App Store Connect で対応する Bundle ID のアプリが作成済み。

1. Xcode で `ios/Runner.xcworkspace` を開く
2. 左のプロジェクトナビゲータで `Runner` を選択
3. **Signing & Capabilities** タブ
   - **Team** を自分のApple Developer Team に設定
   - **Bundle Identifier** を確認（現状: `com.akamatrixxx.justtime` — 必要に応じて自社ドメインに変更）
   - 「Automatically manage signing」ON でプロビジョニングプロファイル自動生成
4. 上部デバイス選択で **Any iOS Device (arm64)** を選択
5. ターミナルで `flutter build ipa --release` を実行
   - 生成物: `build/ios/ipa/justtime.ipa`
6. Xcode の **Window → Organizer** を開く
7. 作成された Archive を選択して **Distribute App** → **App Store Connect** → **Upload**
8. App Store Connect の TestFlight タブでビルドが処理されるのを待ち、テスター追加

もしくはコマンドラインで:
```sh
flutter build ipa
xcrun altool --upload-app -f build/ios/ipa/justtime.ipa -t ios -u <apple-id> -p <app-specific-password>
```

## プロジェクト構成

```
lib/
├── main.dart                # アプリエントリ、DI、状態遷移
├── data/
│   ├── db/                  # SQLite 初期化・マイグレーション
│   ├── model/               # DailyState, UserSetting, NotificationLog, FeedbackType
│   └── repository/          # Repository層
├── logic/
│   ├── app_start/           # 起動時の日付跨ぎ処理
│   ├── feedback/            # フィードバック送信
│   ├── initial_setup/       # チュートリアル完了処理
│   ├── log_export/          # CSVエクスポート
│   ├── notification_service/ # 通知スケジュール＋バックグラウンドアクション
│   ├── notification_time/    # 次回通知時刻算出
│   ├── settings/            # 設定変更
│   └── state/               # 画面状態判定
└── ui/
    ├── feedback/            # フィードバック画面
    ├── menu/                # ハンバーガーメニュー
    ├── message/             # メッセージ表示画面
    ├── settings/            # 時間設定画面
    ├── tutorial/            # 初期設定画面
    └── widgets/             # 共通ウィジェット
```

## DB スキーマ（v5）

- `user_setting` — 勤務・睡眠時間帯
- `daily_state` — 日ごとの通知時刻とフィードバック状態
- `notification_log` — 通知イベント履歴（scheduled / fired / cancelled / feedbackSubmitted）
