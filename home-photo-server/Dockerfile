# ================================
# Build image
# ================================
FROM swift:6.1-noble AS build

# ビルド時に必要なライブラリ
RUN apt-get -q update \
    && apt-get -q dist-upgrade -y \
    && apt-get install -y libjemalloc-dev libvips-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build

# 依存関係キャッシュ
COPY ./Package.* ./
RUN swift package resolve

# ソースコードをコピーしてビルド
COPY . .
RUN swift build -c release \
    --product HomePhotoServer \
    --static-swift-stdlib \
    -Xlinker -ljemalloc

# ビルド成果物をステージング
RUN mkdir /staging && \
    cp "$(swift build -c release --show-bin-path)/HomePhotoServer" /staging

# ================================
# Run image
# ================================
FROM ubuntu:noble

# 実行時に必要なライブラリ
# - libvips: サムネイル生成
# - exiftool: EXIF 抽出
RUN apt-get -q update \
    && apt-get -q install -y \
      libjemalloc2 \
      ca-certificates \
      tzdata \
      libvips42t64 \
      libvips-tools \
      libimage-exiftool-perl \
    && rm -rf /var/lib/apt/lists/*

# vapor ユーザー作成（非 root 実行）
RUN useradd --user-group --create-home --system --home-dir /app vapor

# データ保存用ディレクトリ
RUN mkdir -p /app/data && chown -R vapor:vapor /app/data

WORKDIR /app

COPY --from=build --chown=vapor:vapor /staging /app

USER vapor:vapor

EXPOSE 8080

ENTRYPOINT ["./HomePhotoServer"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0", "--port", "8080"]
