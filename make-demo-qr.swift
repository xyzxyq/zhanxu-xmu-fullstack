import Foundation
import CoreImage
import ImageIO
import UniformTypeIdentifiers

let payload = "zhanxu-demo:RSV-001"
let filter = CIFilter(name: "CIQRCodeGenerator")!
filter.setValue(payload.data(using: .utf8)!, forKey: "inputMessage")
filter.setValue("M", forKey: "inputCorrectionLevel")
let code = filter.outputImage!.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
let bounds = code.extent.insetBy(dx: -32, dy: -32)
let white = CIImage(color: CIColor(red: 1, green: 1, blue: 1)).cropped(to: bounds)
let image = code.composited(over: white)
let context = CIContext()
let cg = context.createCGImage(image, from: bounds)!
let url = URL(fileURLWithPath: CommandLine.arguments[1])
let destination = CGImageDestinationCreateWithURL(url as CFURL, UTType.png.identifier as CFString, 1, nil)!
CGImageDestinationAddImage(destination, cg, nil)
precondition(CGImageDestinationFinalize(destination))
let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: [CIDetectorAccuracy: CIDetectorAccuracyHigh])!
let decoded = detector.features(in: CIImage(cgImage: cg)).compactMap { ($0 as? CIQRCodeFeature)?.messageString }
precondition(decoded.contains(payload), "QR decode failed")
print("Demo QR roundtrip PASS: \(cg.width)x\(cg.height)")
