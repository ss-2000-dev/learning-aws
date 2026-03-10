ECSでファイルベースのログを出力するアプリケーションを運用する場合、コンテナのストレージ枯渇を防ぐためにサイドカーを用いたログローテーションは非常に有効な設計です。

タスク内でボリュームを共有し、サイドカー側からアプリケーション側のログファイルに対してローテーションをかけるアーキテクチャになります。

### 利用するイメージの選定について

ログローテーションのためだけにフル機能のOSイメージや、Docker Hub上の出所が不明瞭なサードパーティ製イメージ（例: `hoge/logrotate` のようなもの）を利用するのは、セキュリティリスクやリソース消費の観点から推奨されません。

今回は、極めて軽量でセキュアな公式の **`alpine` (Alpine Linux)** イメージを利用します。コンテナの起動時に `apk` で標準の `logrotate` をインストールし、シェルスクリプトのループ処理で15分間隔の実行を制御するアプローチをとります。

### CloudFormation テンプレート例

以下は、Fargate上でアプリケーションコンテナとログローテーション用サイドカーを同居させるタスク定義の例です。

```yaml
AWSTemplateFormatVersion: '2010-09-09'
Description: ECS Task Definition with App and Logrotate Sidecar

Resources:
  MyTaskDefinition:
    Type: AWS::ECS::TaskDefinition
    Properties:
      Family: app-with-logrotate
      RequiresCompatibilities:
        - FARGATE
      NetworkMode: awsvpc
      Cpu: '256'
      Memory: '512'
      ExecutionRoleArn: !Sub "arn:aws:iam::${AWS::AccountId}:role/ecsTaskExecutionRole"
      Volumes:
        # ホストパスを指定しないことで、タスク起動時に作成され、
        # タスク終了時に破棄されるエフェメラルボリュームを作成
        - Name: shared-logs
      ContainerDefinitions:
        # 1. アプリケーションコンテナ
        - Name: app-container
          Image: nginx:alpine # ※実際のアプリケーションイメージに置き換えてください
          Essential: true
          MountPoints:
            - SourceVolume: shared-logs
              ContainerPath: /var/log/nginx
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: /ecs/app-container
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: app

        # 2. ログローテーション用サイドカーコンテナ
        - Name: logrotate-sidecar
          Image: alpine:3.19
          Essential: false # ローテーションが失敗してもアプリ自体は停止させない
          MountPoints:
            - SourceVolume: shared-logs
              ContainerPath: /var/log/app-logs
          Command:
            - sh
            - -c
            - |
              # logrotateのインストール
              apk add --no-cache logrotate

              # logrotateの設定ファイルを作成
              cat << 'EOF' > /etc/logrotate.conf
              /var/log/app-logs/*.log {
                  rotate 10
                  missingok
                  notifempty
                  copytruncate
                  compress
              }
              EOF

              echo "Starting logrotate loop (every 15 minutes)..."
              
              # 15分（900秒）ごとに強制ローテーションを実行
              while true; do
                sleep 900
                logrotate -f /etc/logrotate.conf
              done
          LogConfiguration:
            LogDriver: awslogs
            Options:
              awslogs-group: /ecs/logrotate-sidecar
              awslogs-region: !Ref AWS::Region
              awslogs-stream-prefix: sidecar

```

### 設計の重要ポイント

1. **`copytruncate` の指定（最重要）**
通常のログローテーションでは、ファイルをリネームした後にアプリケーションに対してシグナル（`SIGHUP`など）を送り、ログファイルを再オープンさせる必要があります。しかし、別コンテナであるサイドカーからアプリコンテナへシグナルを送るのはプロセス空間が異なるため困難です。
`copytruncate` を指定することで、元のログファイルの内容を別ファイルにコピーした後、**元のファイルをサイズ0に切り詰め**ます。これにより、アプリ側はプロセスを再起動することなく同じファイルディスクリプタに書き込みを継続できます。
2. **`cron` ではなく `sleep` ループの採用**
15分間隔の実行であれば、`crond` デーモンをコンテナ内でバックグラウンド起動するよりも、フォアグラウンドで `sleep 900` と `logrotate -f`（強制ローテーション）を回すループのほうが、コンテナのライフサイクル管理としてシンプルで堅牢です。
3. **エフェメラルボリュームの利用**
`Volumes` セクションで物理パスを指定せずに空のボリュームを定義しています。Fargateのデフォルトのエフェメラルストレージ（20GB）の範囲内でやりくりし、タスク終了と共に安全に破棄されるようになっています。

ローテーションされた過去のログアーカイブ（`.gz` ファイルなど）を、最終的にS3などに退避させる要件はございますか？必要であれば、このサイドカーループ内にAWS CLIを用いたS3への同期コマンドを組み込むことも可能です。

----

ログローテーションは、システム運用において「放っておくと無限に増え続けるログファイル」を適切に管理するための必須技術です。

イメージとしては、**「古い新聞を整理して、新しい新聞を入れるスペースを作る作業」**に似ています。

---
# ログローテーションとは？
## 1. 一般的なログローテーションとは？

サーバーやアプリが出すログは、何もしないと1つのファイルに書き込まれ続け、最終的にディスク容量を使い果たしてシステムを停止させてしまいます。これを防ぐために以下の3つの処理を自動で行うのが「ログローテーション」です。

1. **世代交代（Rotate）**:
現在のログファイル（例: `app.log`）を別の名前に変えて保存します（例: `app.log.1`）。
2. **新規作成（Create）**:
新しく空の `app.log` を作り、アプリがそこに書き込めるようにします。
3. **削除・圧縮（Delete/Compress）**:
古くなったファイル（例: `app.log.10` 以上）を削除したり、容量節約のために ZIP 形式などで圧縮したりします。

---

## 2. 今回、具体的に何をするのか？

ECS（特にFargate）のようなコンテナ環境では、通常のサーバーと違って少し工夫が必要です。なぜなら、**「アプリが入っている箱（コンテナ）」と「ログを掃除する道具（logrotate）」が別々**だからです。

今回の仕組みを具体的にステップで解説します。

### 手順①：共有スペース（Volume）を作る

アプリコンテナと、掃除係（サイドカー）コンテナの両方から読み書きできる「共有のフォルダ」をECSタスク内に用意します。

### 手順②：アプリがログを書き出す

アプリコンテナは、その共有フォルダの中に `app.log` という名前でログを書き込み続けます。

### 手順③：掃除係（サイドカー）が15分おきに動く

ここがご質問いただいたコードの部分です。

```sh
while true; do
  sleep 900                         # ① 15分（900秒）じっと待つ
  logrotate -f /etc/logrotate.conf  # ② 15分経ったら「強制的に」掃除を実行！
done                                # ③ また①に戻って繰り返す

```

* **`sleep 900`**: 15分間、何もしない状態で待機します。
* **`logrotate -f`**: `-f` は "force"（強制）の意味です。本来 `logrotate` は「1日1回」などの周期で動くツールですが、今回は「15分ごと」という短いスパンなので、条件を無視して強制的にローテーションを実行させています。

### 手順④：`copytruncate` で中身を空にする

サイドカーが `logrotate` を実行すると、共有フォルダ内の `app.log` をコピーして別名で保存し、**元の `app.log` の中身だけを空（サイズ0）**にします。

> **なぜ「中身を空にする」のか？**
> アプリは `app.log` というファイルを開きっぱなしで書き込んでいます。もしファイル自体を削除したり名前を変えたりすると、アプリは「書き込み先が見つからない！」とパニックを起こしてしまいます。
> 中身だけをシュッと消す（copytruncate）ことで、アプリに気づかれずにログを整理できるのです。

---

## まとめると

この設定を入れることで、**「15分ごとに、それまで溜まったログを別ファイルに退避して、メインのログファイルを空っぽにする」**という作業が永遠に繰り返されます。これにより、コンテナのストレージがいっぱいになるのを防いでいます。

次は、実際にこの設定で動かしたときに、ログがどのようにファイル名が変わっていくか（世代管理の具体例）をシミュレーションしてみましょうか？