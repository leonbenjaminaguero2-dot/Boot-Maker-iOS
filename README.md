# BootMaker — iOS (Swift + UIKit)

Prototipo funcional nativo de BootMaker: interfaz Android oscura/violeta inspirada en el video de Vendroid, **sin SwiftUI, HTML ni Ventoy**. Flujo: **USB → ISO → Crear**.

## Qué funciona realmente

- El usuario elige una carpeta en Archivos (intención: raíz de una memoria USB).
- El usuario elige una **ISO real** con el selector de Archivos.
- El lector Swift `ISO9660Reader.swift` inspecciona las estructuras ISO 9660/Joliet y busca `EFI/BOOT/BOOTX64.EFI` o `EFI/BOOT/BOOTAA64.EFI` con cabecera PE.
- `UEFICreationService.swift` extrae **los archivos reales de la ISO**, no solo copia el archivo `.iso`. Exige que el destino esté vacío y se presente como FAT/FAT32, verifica espacio cuando está disponible, copia en bloques y muestra progreso/velocidad/tiempo restante calculados desde los bytes copiados. Comprueba tamaños y la presencia del cargador al finalizar.
- Los fallos se muestran como fallos y la tarea intenta eliminar únicamente los archivos que creó. Incluye cancelación y confirmación.

## Límites fundamentales (leer antes de usar)

**NO es una alternativa completa a Rufus/Etcher/Vendroid**. iOS normal no permite a una IPA de terceros reformatear, particionar ni escribir sectores crudos a un pendrive por una API pública. Este proyecto **NO formatea el USB automáticamente**. Apple permite el formateo desde Archivos en modelos de iPhone USB-C, pero **el iPhone 13 Pro con Lightning no dispone de esa función**.

La creación UEFI por extracción es válida **solo para determinadas ISO que ofrecen una estructura UEFI de archivos independiente** y para unidades que ya están en **FAT32 con partición adecuada**. La presencia de `BOOTX64.EFI` no garantiza que el sistema arranque, porque algunos cargadores dependen de una estructura propia de ISO/El Torito, rutas adicionales, una tabla de particiones específica o parámetros propios. **El arranque final debe comprobarse en una PC**.

No se soportan ISO UDF sin árbol ISO9660 completo, archivos mayores de 4 GiB en FAT32 (`install.wim` de Windows incluido), imágenes `.img`, multiextent, BIOS/Legacy, ISOs híbridas que requieran escritura cruda, ni extracción de Rock Ridge específico. Tampoco se detecta con fiabilidad si el usuario eligió *la raíz de un USB físico* en lugar de una carpeta local: esa elección es responsabilidad del usuario. **No se debe anunciar un éxito de booteo confirmado.**

**Advertencia de datos:** esta app se niega a sobrescribir una carpeta de destino que no esté vacía y no ejecuta formateos. Si el usuario formatea el USB previamente mediante otro sistema, se borrarán sus datos.

## Compilar la IPA

1. Creá un repositorio de GitHub con todo el contenido de esta carpeta (incluida `.github`).
2. En GitHub → **Actions** → **BootMaker - IPA sin firma** → **Run workflow**.
3. Al terminar, descargá el artifact `BootMaker-unsigned-IPA` con `BootMaker-unsigned.ipa`.
4. La IPA **no está firmada**: para instalarla necesitarás firmarla por el método compatible con tu dispositivo (ej. SideStore). Una IPA compilada no altera los permisos USB de iOS.

En un Mac, también podés instalar `xcodegen` y ejecutar:

```sh
brew install xcodegen
xcodegen generate --spec project.yml
xcodebuild -project BootMaker.xcodeproj -scheme BootMaker -configuration Release -sdk iphoneos -destination 'generic/platform=iOS' CODE_SIGNING_ALLOWED=NO build
```

## Pruebas locales (lector ISO, Linux/macOS)

```sh
python3 Tests/make_test_iso.py /tmp/bootmaker_test.iso
swiftc BootMaker/ISO9660Reader.swift Tests/ISOReaderTest.swift -o /tmp/iso_test
/tmp/iso_test /tmp/bootmaker_test.iso
```

La prueba usa un cargador PE **sintético**, no una ISO booteable real. Valida exclusivamente el parser ISO9660, no prueba ni certifica el arranque de un USB.

## Estado de validación

Se probó el parser ISO9660 con una ISO de prueba sintética en Swift Linux. Se verificó sintaxis Swift básica de los archivos UIKit, pero **no se ejecutó Xcode ni una compilación real de IPA aquí**; el workflow está previsto para macOS GitHub Actions.
