#!/bin/bash
# ============================================================
#  build_apk.sh  –  Spy Game APK builder
#  Run: bash build_apk.sh
# ============================================================
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${YELLOW}🕵️  Spy Game APK Builder${NC}"
echo "================================"

# ── 1. Flutter check ────────────────────────────────────────
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter tapılmadı.${NC}"
    echo ""
    echo "Flutter quraşdırın:"
    echo "  https://docs.flutter.dev/get-started/install"
    echo ""
    echo "Sürətli (Linux/Mac snap):"
    echo "  sudo snap install flutter --classic"
    echo "  flutter sdk-path"
    exit 1
fi

FLUTTER_VERSION=$(flutter --version 2>&1 | head -1)
echo -e "${GREEN}✅ Flutter: $FLUTTER_VERSION${NC}"

# ── 2. Java check ───────────────────────────────────────────
if ! command -v java &> /dev/null; then
    echo -e "${RED}❌ Java tapılmadı. Java 17 quraşdırın:${NC}"
    echo "  sudo apt install openjdk-17-jdk   # Ubuntu/Debian"
    echo "  brew install openjdk@17           # macOS"
    exit 1
fi
JAVA_VERSION=$(java -version 2>&1 | head -1)
echo -e "${GREEN}✅ Java: $JAVA_VERSION${NC}"

# ── 3. Android SDK check ─────────────────────────────────────
if [ -z "$ANDROID_HOME" ] && [ -z "$ANDROID_SDK_ROOT" ]; then
    echo -e "${YELLOW}⚠️  ANDROID_HOME tapılmadı.${NC}"
    echo "   Android Studio quraşdırıbsınızsa, SDK adətən buradadır:"
    echo "   ~/Android/Sdk   (Linux)"
    echo "   ~/Library/Android/sdk  (macOS)"
    echo ""
    echo "   export ANDROID_HOME=~/Android/Sdk"
    echo "   flutter doctor  # problemi görmək üçün"
fi

# ── 4. Dependencies ─────────────────────────────────────────
echo ""
echo "📦 Paketlər yüklənir..."
flutter pub get

# ── 5. Doctor ───────────────────────────────────────────────
echo ""
echo "🔍 Flutter doctor..."
flutter doctor --android-licenses --accept-all 2>/dev/null || true

# ── 6. Build APK ────────────────────────────────────────────
echo ""
echo "🔨 APK build edilir (release)..."
flutter build apk --release

APK_PATH="build/app/outputs/flutter-apk/app-release.apk"

if [ -f "$APK_PATH" ]; then
    SIZE=$(du -h "$APK_PATH" | cut -f1)
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║   ✅  APK uğurla hazırlandı!         ║${NC}"
    echo -e "${GREEN}╠══════════════════════════════════════╣${NC}"
    echo -e "${GREEN}║  📍 Yer: $APK_PATH${NC}"
    echo -e "${GREEN}║  📦 Ölçü: $SIZE${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════╝${NC}"
    echo ""
    echo "Cihaza göndərmək üçün:"
    echo "  adb install $APK_PATH"
    echo "  # və ya faylı telpone kopyalayın"
else
    echo -e "${RED}❌ APK tapılmadı. Build uğursuz oldu.${NC}"
    exit 1
fi
