# ベースイメージ（軽量なNode.js 24）
FROM node:24-alpine

# 作業ディレクトリを設定
WORKDIR /usr/src/app

# package.jsonとpackage-lock.jsonをコピー
COPY package*.json ./

# 依存関係をインストール
RUN npm install --production

# アプリのソースをコピー
COPY . .

# Expressサーバが使うポートを開放
EXPOSE 3000

# コンテナ起動時に実行するコマンド
CMD ["node", "app.js"]
