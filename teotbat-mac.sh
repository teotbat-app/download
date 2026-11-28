#!/bin/bash
# 텃밭투자집사 — 맥 설치 (터미널에 한 줄 붙여넣기용)
#   curl -fsSL https://raw.githubusercontent.com/teotbat-app/download/main/teotbat-mac.sh | bash
main() {
    ZIP_URL="https://github.com/teotbat-app/download/raw/main/teotbat_mac_v4.66.zip"
    if [ "$(uname -s)" != "Darwin" ] && [ -z "${ASSET_INSTALL_BASE:-}" ]; then
        echo "  이 설치 방법은 맥(macOS)에서만 쓸 수 있어요."
        exit 1
    fi
    TMP="$(mktemp -d "${TMPDIR:-/tmp}/asset-install.XXXXXX")" || { echo "  임시 폴더를 만들지 못했어요."; exit 1; }
    trap 'rm -rf "$TMP"' EXIT
    trap 'exit 130' INT TERM
    echo ""
    echo "  텃밭투자집사 설치 파일을 내려받는 중…"
    if ! curl -fL --retry 3 --retry-delay 3 --connect-timeout 20 -m 600 -sS -o "$TMP/app.zip" "$ZIP_URL"; then
        echo "  내려받지 못했어요. 인터넷 연결을 확인하고 다시 해 주세요."
        rm -rf "$TMP"
        exit 1
    fi
    mkdir -p "$TMP/x"
    INST=""
    if command -v ditto >/dev/null 2>&1; then           # 맥의 기본 도구 — 한글 파일 이름을 가장 잘 풂
        ditto -x -k "$TMP/app.zip" "$TMP/x" >/dev/null 2>&1
        INST="$(find "$TMP/x" -type f -path '*/app/tools/mac/install.sh' 2>/dev/null | head -n 1)"
    fi
    if [ -z "$INST" ]; then
        unzip -o -q "$TMP/app.zip" -d "$TMP/x" >/dev/null 2>&1 </dev/null
        INST="$(find "$TMP/x" -type f -path '*/app/tools/mac/install.sh' 2>/dev/null | head -n 1)"
    fi
    if [ -z "$INST" ]; then
        echo "  받은 파일의 압축을 풀지 못했어요. 다시 해 주세요."
        rm -rf "$TMP"
        exit 1
    fi
    /bin/bash "$INST" </dev/null
    exit $?
}
main "$@"
