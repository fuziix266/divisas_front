# CONTEXTO DE RECUPERACIÓN - Proyecto divisas_front

> ⚠️ **TEMPORAL** - Este archivo se elimina cuando todo el proceso de upload a App Store termine correctamente.

## Estado al pausar (Jul 23, 2026)

### Hardware
- Mac: MacBook Pro 13" Mid-2012 (MacBookPro9,2)
- CPU: Intel Core i5 2.5 GHz Dual-Core
- RAM: 16 GB DDR3 1600MHz
- macOS actual: Sonoma 14.7.4 (parcheado con OCLP 2.4.1)
- iPhone conectado: "iPhone de retrobox" (iPhone 15, iOS 18.5)

### Cuenta Apple
- Apple ID: retroboxspa@gmail.com (jonathan zepeda)
- Team ID: VY9WY2C6U3
- Bundle ID: com.divisas.divisas
- App Store Connect: app "PE$OL" pendiente de crear

### Repos
- GitHub user: fuziix266
- Repo: https://github.com/fuziix266/divisas_front
- Working dir: ~/Desktop/work/divisas_front
- Rama: master

## Tareas completadas
1. ✅ gh CLI autenticado con fuziix266
2. ✅ Repo clonado en ~/Desktop/work/divisas_front
3. ✅ Flutter 3.44.7 instalado en ~/development/flutter/bin
4. ✅ flutter pub get exitoso
5. ✅ CocoaPods 1.16.2 instalado (con LANG=en_US.UTF-8 fix)
6. ✅ Fix Firebase init en lib/main.dart (try/catch)
7. ✅ Iconos sin alpha channel
8. ✅ Info.plist con 4 orientaciones iPad
9. ✅ Build debug OK, app corriendo en iPhone 15 (Firebase opcional)
10. ✅ Build release OK (25.1MB)
11. ✅ Archive creado (Runner.xcarchive)
12. ✅ License Agreement aceptado
13. ✅ Apple Distribution cert generado automáticamente
14. ✅ Provisioning profile generado
15. ✅ Commit + push con todos los cambios
16. ✅ Ethernet configurado: IP 172.25.50.132, DNS 8.8.8.8/8.8.4.4
17. ✅ Wi-Fi desactivado
18. ✅ macOS Sequoia 15.7.7 installer descargado

## Bloqueos resueltos
- ❌ "No signing certificate Apple Distribution" → ✅ PLA aceptado + cert auto-generado
- ❌ Icon alpha channel → ✅ removido con PIL
- ❌ iPad orientations → ✅ 4 orientaciones agregadas
- ⏸️ SDK iOS 26 requirement → en progreso (vía upgrade a Sequoia + Xcode 26)

## Pendiente
1. ⏸️ Usuario debe ejecutar Install macOS Sequoia manualmente (requiere password)
2. ⏸️ Auto: OCLP root patches post-reboot
3. ⏸️ Auto: Xcode 26.3 install post-segundo-reboot
4. ⏸️ Auto: Build release + Archive + Upload a App Store Connect
5. ⏸️ Crear app en App Store Connect (bundle: com.divisas.divisas, nombre: PE$OL)

## Scripts post-reboot configurados
- `/tmp/post-reboot-sequoia.sh` - OCLP patches + reboot
- `/tmp/post-patches.sh` - Instala Xcode 26.3 via xcodes CLI
- `/tmp/post-xcode.sh` - Build release + Upload

## LaunchAgents activos
- `com.user.installer` - Abre Install macOS Sequoia al login
- `com.user.postsequoia` - Aplica patches OCLP después del primer reboot
- `com.user.postpatches` - Se crea en el script post-reboot
- `com.user.postxcode` - Se crea en el script post-patches

## ExportOptions.plist para App Store
```xml
<?xml version="1.0" encoding="UTF-8"?>
<plist version="1.0">
<dict>
    <key>destination</key>
    <string>upload</string>
    <key>method</key>
    <string>app-store-connect</string>
    <key>teamID</key>
    <string>VY9WY2C6U3</string>
    <key>signingStyle</key>
    <string>automatic</string>
</dict>
</plist>
```

## Comandos clave para retomar manualmente
```bash
# Activar Flutter
export PATH="$HOME/development/flutter/bin:$PATH"

# Build release
cd ~/Desktop/work/divisas_front
flutter build ios --release

# Archive
cd ios
xcodebuild -workspace Runner.xcworkspace -scheme Runner -configuration Release -archivePath ~/Desktop/work/divisas_front/build/Runner.xcarchive archive -allowProvisioningUpdates

# Export y upload
xcodebuild -exportArchive -archivePath ~/Desktop/work/divisas_front/build/Runner.xcarchive -exportPath ~/Desktop/work/divisas_front/build/ -exportOptionsPlist /tmp/ExportOptions.plist -allowProvisioningUpdates

# Restaurar red (si se perdió)
networksetup -setmanual "Ethernet" 172.25.50.132 255.255.255.0 172.25.50.1
networksetup -setdnsservers "Ethernet" 8.8.8.8 8.8.4.4
```

## Notas Firebase
- En debug: Firebase.initializeApp() lanza error pero con try/catch la app sigue funcionando
- En release: mismo comportamiento
- Analytics no funciona pero no bloquea la app
- Para arreglarlo completamente: ejecutar `flutterfire configure` y generar `firebase_options.dart`
- NO es bloqueante para App Store

## Estructura del proyecto
```
divisas_front/
├── lib/
│   ├── main.dart (modificado con try/catch Firebase)
│   ├── providers/
│   ├── screens/
│   └── theme/
├── ios/
│   ├── Runner/
│   │   ├── Info.plist (modificado: orientaciones iPad)
│   │   ├── GoogleService-Info.plist
│   │   └── Assets.xcassets/AppIcon.appiconset/ (alpha removido)
│   ├── Runner.xcodeproj/
│   └── Runner.xcworkspace/
├── android/
├── web/
├── macos/
├── windows/
├── linux/
├── assets/images/logo_pesol.png
└── pubspec.yaml (name: divisas, version: 1.0.0+1)
```

## Resumen conversación
Usuario: fuziix266 (jonathan zepeda) - retroboxspa@gmail.com
Pidió: clonar repo, analizar iOS, correr en iPhone 15, generar versión oficial para App Store
Trabajamos en: ~/Desktop/work
Idioma: Español (Chile)
