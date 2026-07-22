# PE$OL — Compilación para iOS

## Requisitos en la Mac

- macOS 13 o superior
- Xcode 15+ (desde App Store)
- CocoaPods: `sudo gem install cocoapods` o `brew install cocoapods`
- Flutter SDK estable (canal estable): https://docs.flutter.dev/get-started/install/macos
- Una cuenta de Apple Developer (para distribuir en App Store)

## Configuración inicial

1. **Clonar / copiar el proyecto** a la Mac.

2. **Verificar Flutter**:
   ```bash
   flutter doctor
   ```
   Resuelve cualquier advertencia de Xcode o CocoaPods antes de continuar.

3. **Restaurar dependencias**:
   ```bash
   cd front
   flutter pub get
   ```

4. **Generar iconos de la app** (opcional pero recomendado si los assets cambiaron):
   ```bash
   dart run flutter_launcher_icons
   ```

5. **Restaurar Pods de iOS**:
   ```bash
   cd ios
   pod install
   cd ..
   ```

## Archivos sensibles

`ios/Runner/GoogleService-Info.plist` está en `.gitignore`. Si clonas el repo y este archivo falta, cópialo desde un respaldo seguro o descárgalo de la consola de Firebase (Project Settings → Your apps → iOS app).

## Compilar y probar

### En simulador
```bash
flutter run -d "iPhone 15"
```

### En dispositivo físico
1. Conecta el iPhone por USB
2. Confía en la Mac desde el iPhone
3. Abre `ios/Runner.xcworkspace` en Xcode
4. Selecciona tu equipo de desarrollo en *Signing & Capabilities*
5. `flutter run -d <device-id>`

### Build de release (para subir a App Store)
```bash
flutter build ios --release
```
Luego abre `ios/Runner.xcworkspace` en Xcode → Product → Archive → Distribute App.

## Publicar en App Store Connect

1. En https://appstoreconnect.apple.com crea una app con bundle id `com.divisas.divisas`
2. Sube el archivo `.ipa` desde Xcode Organizer
3. Completa la metadata, screenshots y descripción
4. Envía para revisión

## Configuración ya realizada en el proyecto

- `CFBundleDisplayName` y `CFBundleName` = `PE$OL`
- Orientación solo Portrait (consistente con Android)
- `LSApplicationQueriesSchemes` reducido a `tel` y `mailto`
- iOS 15.0+ como deployment target
- Firebase Analytics configurado
- Dependencias nativas vía CocoaPods

## Problemas comunes

**"No pod file found"** → ejecutar `pod install` dentro de `ios/`.

**"CocoaPods could not find compatible versions"** → `pod repo update && pod install`.

**Errores de firma** → revisa *Signing & Capabilities* en Xcode y selecciona tu equipo.

**Pantalla blanca al iniciar** → asegúrate de que `GoogleService-Info.plist` existe en `ios/Runner/`.
