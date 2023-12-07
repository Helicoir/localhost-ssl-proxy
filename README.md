# localhost-ssl-proxy

## Overview

localhost を任意のドメイン名 & SSL 化状態でアクセスできるようにする（ローカルマシンの`/private/etc/hosts` の変更有）
また、MacOS のプライベート認証局を使って証明書の信頼を行うので、あくまで開発用途のみの使用を前提とする

## How to use

### 任意のドメインで入れるようにする

前提: 使いたいドメインを hoge.local-dev.com とする

1. ローカルマシンの/private/etc/hosts に設定を追加して、localhost と同じ host を別ドメインからも見れるようにする

   - 127.0.0.1 hoge.local-dev.com

2. docker で nginx 入りコンテナ立てて、80, 443 ポートをローカルマシンにフォワードしておく

   - ↑ により、このコンテナの nginx リバースプロキシを 127.0.0.1 に適用できる

3. nginx conf で ↓ みたいな設定書く

   - これによりローカルの 3000 ポートに立っているものを、hoge.local-dev.com の名前を使って 127.0.0.1 を見に行ったときだけ見に行くようになる

```
server {
    listen 443 ssl;
    server_name hoge.local-dev.com;

    location / {
      proxy_pass http://host.docker.internal:3000;
    }
}
```

### 証明書を適用 & ローカルマシン認証局から信頼して SSL 化する

1. 証明書つくる

   - https://qiita.com/nis_nagaid_1984/items/b8f87d41ea108d47af61
   - デフォルトでは、作った証明書は`certs/local-dev.com/xxxxx.key` のような形で配置するとコンテナ上に同期され適用される。
     - 変更したい場合は docker-compose.yml の volume を編集

2. nginx conf の設定に付け加える ↓↓

```
server {
    listen 443 ssl;
    server_name ac-local.com;

    ssl on;
    ssl_certificate /etc/nginx/ssl/xxxxx.crt;
    ssl_certificate_key /etc/nginx/ssl/xxxxx.key;

    location / {
      proxy_pass http://host.docker.internal:3000;
    }
}
```

3. アクセスすると「証明書が信頼されてない」みたいなので怒られるので、ローカルマシンで信頼を宣言する

   - https://iboysoft.com/jp/news/how-to-trust-a-certificate-on-mac.html

4. 完了
