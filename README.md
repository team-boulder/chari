# SampleCorona2
- CoronaSDKとgitの使い方に慣れよう  

## gitの操作
### クローン
git clone URL  

cd gitレポジトリ名  
### ブランチを切る
git branch 
- ブランチの確認
git branch branch名 
git checkout branch名 
- 作業したいブランチへの切り替え 
### コミット
git add *(ファイル名) 
- ※は変更した全てのファイル  

git commit -m "コメント"  
### プッシュ
git push origin branch名(master)  
- originはgitのURLのエイリアス。masterには通常pushしない　　
### プル
git pull origin branch名(master)  
- 誰かのブランチをpullするときは自分の作業ブランチとは別にブランチを作るといい
