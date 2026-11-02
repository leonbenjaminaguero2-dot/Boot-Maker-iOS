import Foundation
@main
struct ISOReaderTest {
    static func main() throws {
        let path = CommandLine.arguments[1]
        let image = try ISO9660Reader(url: URL(fileURLWithPath: path)).inspect()
        precondition(image.bootloader.lowercased() == "efi/boot/bootx64.efi")
        precondition(image.fileCount == 2)
        precondition(image.bytesToCopy == 2058)
        precondition(image.entries.contains { $0.relativePath == "EFI/BOOT/BOOTX64.EFI" })
        print("✅ ISO9660 reader: \(image.fileCount) files; UEFI loader \(image.bootloader)")
    }
}
