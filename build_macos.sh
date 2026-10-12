#!/bin/bash
set -e

echo "=== TMaxPcService macOS 一键构建脚本 ==="

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 1. 查找或编译 Go 后端
BACKEND_DIR="../tmaxBack/Backend"
if [ ! -d "$BACKEND_DIR" ]; then
    BACKEND_DIR="../../tmaxBack/Backend"
fi

if [ -d "$BACKEND_DIR" ]; then
    echo "--- [1/3] 编译 Go 后端服务 (tmaxsrv_mac) ---"
    cd "$BACKEND_DIR"
    export CGO_ENABLED=1
    go build -v -ldflags="-s -w -X 'main.Version=v1.82'" -o tmaxsrv_mac .
    chmod +x tmaxsrv_mac
    cd "$SCRIPT_DIR"
else
    echo "提示: 未在同级目录找到 tmaxBack/Backend，将检查是否有预编译好的 tmaxsrv_mac"
fi

# 2. 编译 Flutter UI
echo "--- [2/3] 编译 Flutter macOS 应用 ---"
flutter build macos --release

APP_PATH="build/macos/Build/Products/Release/TMaxPcServiceUI.app"
RESOURCES_DIR="${APP_PATH}/Contents/Resources"

if [ ! -d "$APP_PATH" ]; then
    echo "错误: 未找到生成的 .app 文件: $APP_PATH"
    exit 1
fi

# 3. 注入 Go 后端服务及静态资源到 .app 内
echo "--- [3/3] 注入 Go 后端服务到 App Bundle ---"
mkdir -p "$RESOURCES_DIR"

# 拷贝 tmaxsrv_mac
if [ -f "$BACKEND_DIR/tmaxsrv_mac" ]; then
    cp "$BACKEND_DIR/tmaxsrv_mac" "$RESOURCES_DIR/"
elif [ -f "./tmaxsrv_mac" ]; then
    cp "./tmaxsrv_mac" "$RESOURCES_DIR/"
else
    echo "错误: 找不到 tmaxsrv_mac 可执行文件！"
    exit 1
fi

chmod +x "${RESOURCES_DIR}/tmaxsrv_mac"

# 拷贝配置文件和数据
if [ -f "$BACKEND_DIR/config.yaml" ]; then
    cp "$BACKEND_DIR/config.yaml" "$RESOURCES_DIR/"
elif [ -f "./config.yaml" ]; then
    cp "./config.yaml" "$RESOURCES_DIR/"
fi

if [ -f "$BACKEND_DIR/tmaxlic.txt" ]; then
    cp "$BACKEND_DIR/tmaxlic.txt" "$RESOURCES_DIR/"
fi

if [ -d "$BACKEND_DIR/srvdata" ]; then
    cp -r "$BACKEND_DIR/srvdata" "$RESOURCES_DIR/"
fi

# 清除隔离属性
xattr -cr "$APP_PATH" 2>/dev/null || true

# 对 app 进行 ad-hoc 重签名（包含内部新注入的二进制文件）
codesign --force --deep --sign - "$APP_PATH" 2>/dev/null || true

echo "=== 构建完成！==="
echo "应用程序位置: $SCRIPT_DIR/$APP_PATH"
echo "你可以直接双击运行，或在终端执行: open \"$SCRIPT_DIR/$APP_PATH\""
