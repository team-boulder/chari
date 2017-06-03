# iOS ビルド・設定


## Overview
iOSをビルドするときの設定や手順について記載


## 手順


### 1.Macの開発環境を整える
1. 開発担当に連絡し、メイン機のMacのキーチェーンアクセスから秘密鍵をエクスポートしてもらい、p12ファイルとパスワードを受け取る
2. 受け取ったp12ファイルをダブルクリックし、出てきた画面にパスワードを打ち込む
3. キーチェーンアクセスが起動して正しく登録されれば完了


### 2. CoronaSDK Enterpriseのインストール

1. CoronaEnterprise-??????.tar.gzをDLし解凍 名前を変更し、/Applications/CoronaEnterpriseに移動する。
2. CoronaEnterprisePlugins.??????.tar.gzをDLし解凍 中身を/Applications/CoronaEnterprise/Pluginsに移動する。

### 3. Trackingツールの実装

#### CocoaPodsをインストール

<公式ガイド>  
<http://guides.cocoapods.org/using/getting-started.html>

> インストール済みの場合は次へ

1. CocoaPodsをインストール
`$ sudo gem install cocoapods`
2. リポジトリ情報のセットアップ
`$ pod setup`

> CocoaPodsは 1.0.0 以上でなければダメ！

1. CocoaPodsのアップデート
`$ sudo gem update cocoapods`


<公式ガイド>  
<http://guides.cocoapods.org/using/using-cocoapods.html>

1. .xcodeproj のプロジェクトファイルのディレクトリに cd で移動後
`$ pod init App.xcodeproj`
2. Podfile に以下を追記。 
```
￼platform :ios, '7.0'  
pod 'Nex8Tracking'
```
3. ライブラリをインストール 
`$ pod install`
4. 更新、削除の場合。Podfile を編集した場合は、以下のコマンドを実行します。
`$ pod update`
5. .xcworkspace を開いてアプリを開発する
・自動生成されたファイル プロジェクト名.xcworkspace を開き、アプリの開発を行います。

#### frameworkの追加

0. Nex8やFyberSDKはCocoaPodにてFrameworkが内部的に追加されるので、手動でのframework追加は必要ない。そのため以下の手順は不要
1. Nex8やFyberSDK以外のトラッキング SDK の framework をプロジェクトに追加
2. 不要：AWS Mobile SDK for iOS をプロジェクトに追加
<https://aws.amazon.com/jp/mobile/sdk/>よりDLした以下のframeworkを追加

* AWSCore.framework
* AWSKinesis.framework

3. ライブラリに以下を追加

* libsqlit3.0.dylib
* libz.dylib
* adSupport.framework

* libstdc++.6.tbd

#### nex8trackingの設定

#### iOS Deployment Targetを8に設定

1. App.xcworkspaceを開き、Appプロジェクトを選択＞Project＞App＞Deployment Targetを8.0に

**※ 注意：シンボリックリンクの関係でZIPでなく、tar.gzをダウンロードする。**

### 4. provisioning profileの準備

1. 対象のアプリのprovisioinig profileをiOS Dev CenterよりDLする
2. DLしたprofileをダブルクリックしprofileをインストールする

### 5. ビルド

1. 作成したCoronaのコードをプロジェクトの Coronaディレクトリと入れ替える(ディレクトリ名はCoronaにすること)
2. xcode > target > General より Bundle Identifierとversion, Buildを設定
3. trackingツールの IDを設定

**※アプリ名、アイコン、スクショはCoronaのコード側で設定**
