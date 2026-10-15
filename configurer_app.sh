#!/bin/bash

# ============================================
# Configuration du nom de l'application
# Modifie le nom dans TOUS les environnements
# ============================================

# --- MODIFIEZ CES DEUX LIGNES ---
APP_NAME="Kado Boutique"
SHORT_NAME="Kado"
# ---------------------------------

echo "Configuration de l'application : $APP_NAME"
echo ""

# 1. ANDROID
if [ -f android/app/src/main/AndroidManifest.xml ]; then
  sed -i "s/android:label=\"[^\"]*\"/android:label=\"$APP_NAME\"/" android/app/src/main/AndroidManifest.xml
  echo "  [OK] Android"
fi

# 2. WEB - index.html
if [ -f web/index.html ]; then
  sed -i "s|<title>.*</title>|<title>$APP_NAME</title>|" web/index.html
  sed -i "s|<meta name=\"description\" content=\"[^\"]*\">|<meta name=\"description\" content=\"$APP_NAME - Votre boutique en ligne\">|" web/index.html
  sed -i "s|<meta name=\"apple-mobile-web-app-title\" content=\"[^\"]*\">|<meta name=\"apple-mobile-web-app-title\" content=\"$APP_NAME\">|" web/index.html
  echo "  [OK] Web (index.html)"
fi

# 3. WEB - manifest.json
if [ -f web/manifest.json ]; then
  sed -i "s|\"name\": \"[^\"]*\"|\"name\": \"$APP_NAME\"|" web/manifest.json
  sed -i "s|\"short_name\": \"[^\"]*\"|\"short_name\": \"$SHORT_NAME\"|" web/manifest.json
  echo "  [OK] Web (manifest.json)"
fi

# 4. LINUX
if [ -f linux/runner/my_application.cc ]; then
  sed -i "s|gtk_window_set_title(window, \"[^\"]*\");|gtk_window_set_title(window, \"$APP_NAME\");|" linux/runner/my_application.cc
  echo "  [OK] Linux"
fi

# 5. macOS
if [ -f macos/Runner/Configs/AppInfo.xcconfig ]; then
  sed -i "s|PRODUCT_NAME = .*|PRODUCT_NAME = $APP_NAME|" macos/Runner/Configs/AppInfo.xcconfig
  echo "  [OK] macOS"
fi

# 6. iOS
if [ -f ios/Runner/Info.plist ]; then
  sed -i "/<key>CFBundleDisplayName<\/key>/{n;s|<string>.*</string>|<string>$APP_NAME</string>|}" ios/Runner/Info.plist
  sed -i "/<key>CFBundleName<\/key>/{n;s|<string>.*</string>|<string>$APP_NAME</string>|}" ios/Runner/Info.plist
  echo "  [OK] iOS"
fi

# 7. WINDOWS
if [ -f windows/runner/main.cpp ]; then
  sed -i "s|window.Create(L\"[^\"]*\"|window.Create(L\"$APP_NAME\"|" windows/runner/main.cpp
  echo "  [OK] Windows"
fi

# 8. Générer les icônes (si l'image existe)
if [ -f assets/icon/icon.png ]; then
  echo ""
  echo "Génération des icônes..."
  flutter pub run flutter_launcher_icons
else
  echo ""
  echo "  [ATTENTION] Fichier assets/icon/icon.png introuvable."
  echo "  Les icônes n'ont pas été générées."
fi

echo ""
echo "Configuration terminée pour : $APP_NAME"
