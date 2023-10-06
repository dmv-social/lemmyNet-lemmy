#
# Docker multiarch image:
#   We build the Lemmy binary for amd64 and arm64 in individual stages using the blackdex/rust-musl image (github.com/blackdex/rust-musl). 
#   This image uses musl-cross-make (github.com/richfelker/musl-cross-make) to build a musl cross compilation toolchain for the target 
#   architecture. It also includes pre-built static libraries such as libpq. These libraries can improve the compile time and eliminate 
#   the requirement for extra dependencies in the final image.
#
#   During each build stage, we use the blackdex/rust-musl openssl 3 images and configure PQ_LIB_DIR=/usr/local/musl/pq15/lib to use 
#   libpq v15. We also ensure the installation of the Rust toolchain corresponding to the target architecture using:
#   `rustup target add $TARGET-unknown-linux-musl`.
#

ARG RUST_VERSION=1.72.1
ARG DEBIAN_VERSION=bookworm
ARG ALPINE_VERSION=3.18
ARG CARGO_BUILD_FEATURES=default
ARG RUST_RELEASE_MODE=debug
ARG UID=911
ARG GID=911

FROM rust:${RUST_VERSION}-${DEBIAN_VERSION} as base

ENV DEBIAN_FRONTEND=noninteractive
ENV CARGO_HOME=/root/.cargo
#ENV PQ_LIB_DIR=/usr/local/musl/pq15/lib

RUN apt-get update && apt-get install -y \
    --no-install-recommends \
    git=1:2.39.2-1.1

RUN mkdir -pv "${CARGO_HOME}" && \
    rustup set profile minimal

# AMD64 builder
FROM base AS build

ARG CARGO_BUILD_FEATURES
ARG RUST_RELEASE_MODE

WORKDIR /lemmy

COPY . ./

# Debug build
RUN --mount=type=cache,target=/lemmy/target set -ex; \
    if [ "${RUST_RELEASE_MODE}" = "debug" ]; then \
        echo "pub const VERSION: &str = \"$(git describe --tag)\";" > crates/utils/src/version.rs; \
        cargo build --features "${CARGO_BUILD_FEATURES}" --target-dir target; \
        ls -R target; \
        mv target/debug/lemmy_server ./lemmy; \
    fi

# Release build
RUN set -ex; \
    if [ "${RUST_RELEASE_MODE}" = "release" ]; then \
        echo "pub const VERSION: &str = \"$(git describe --tag)\";" > crates/utils/src/version.rs; \
        cargo build --features "${CARGO_BUILD_FEATURES}" --release --target-dir target; \
        ls -R target; \
        mv target/release/lemmy_server ./lemmy; \
    fi

## Final image
FROM rust:${RUST_VERSION}-slim-${DEBIAN_VERSION} as release

ARG UID
ARG GID

COPY --from=build --chmod=0755 /lemmy/lemmy /usr/local/bin/lemmy

RUN apt-get update \
    && \
    apt-get install -y libpq5 \
    && \
    rm -Rf /var/lib/apt/cache

RUN addgroup \
      --system \
      --gid ${GID} \
      lemmy \
    && \
    adduser \
      --system \
      --uid ${UID} \
      --gid ${GID} \
      --shell /sbin/nologin \
      --no-create-home \
      lemmy

USER lemmy

CMD ["/usr/local/bin/lemmy"]

EXPOSE 8536

STOPSIGNAL SIGTERM
