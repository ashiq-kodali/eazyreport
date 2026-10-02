import 'package:barcode/barcode.dart' hide BarcodeElement;
import '../expressions/format.dart';
import '../model/types.dart';

int parseHexColor(String hex) {
  var clean = hex.replaceAll('#', '').trim();
  if (clean.length == 3) {
    clean = clean.split('').map((c) => '$c$c').join();
  }
  if (clean.length == 6) {
    clean = 'ff$clean';
  }
  return int.tryParse(clean, radix: 16) ?? 0xff000000;
}

Barcode resolveBarcodeSymbology(String id) {
  switch (id.toLowerCase()) {
    case 'qrcode':
    case 'microqrcode':
    case 'swissqrcode':
      return Barcode.qrCode();
    case 'datamatrix':
    case 'gs1datamatrix':
      return Barcode.dataMatrix();
    case 'pdf417':
      return Barcode.pdf417();
    case 'azteccode':
    case 'aztec':
      return Barcode.aztec();
    case 'ean13':
      return Barcode.ean13();
    case 'ean8':
      return Barcode.ean8();
    case 'upca':
      return Barcode.upcA();
    case 'upce':
      return Barcode.upcE();
    case 'code39':
    case 'code39ext':
      return Barcode.code39();
    case 'code93':
      return Barcode.code93();
    case 'isbn':
      return Barcode.isbn();
    case 'itf14':
      return Barcode.itf14();
    case 'interleaved2of5':
      return Barcode.itf();
    case 'rationalizedcodabar':
    case 'codabar':
      return Barcode.codabar();
    case 'postnet':
      return Barcode.postnet();
    case 'telepen':
      return Barcode.telepen();
    case 'code128':
    case 'gs1-128':
    default:
      return Barcode.code128();
  }
}

bool isTwoDimensional(String symbology) {
  final s = symbology.toLowerCase();
  return s == 'qrcode' ||
      s == 'microqrcode' ||
      s == 'swissqrcode' ||
      s == 'datamatrix' ||
      s == 'gs1datamatrix' ||
      s == 'pdf417' ||
      s == 'azteccode' ||
      s == 'aztec';
}

final Map<String, String> _svgCache = {};

String barcodeHtml(BarcodeElement el, String value) {
  final twoD = isTwoDimensional(el.symbology);
  final cacheKey =
      '${el.symbology}|$value|${el.barColor}|${el.background}|${el.stretch}';
  var svg = _svgCache[cacheKey];

  if (svg == null) {
    try {
      final bc = resolveBarcodeSymbology(el.symbology);
      final colorVal = parseHexColor(el.barColor);

      svg = bc.toSvg(
        value,
        width: el.w * 3.78, // mm to approximate px for viewport
        height: el.h * 3.78,
        drawText: false,
        color: colorVal,
      );

      // Make SVG scale dynamically to fill the element container
      svg = svg
          .replaceAll(RegExp(r'<svg([^>]*?)\swidth="[^"]*"'), '<svg\$1')
          .replaceAll(RegExp(r'<svg([^>]*?)\sheight="[^"]*"'), '<svg\$1');

      final preserveAspect = (twoD || !el.stretch) ? 'xMidYMid meet' : 'none';
      svg = svg.replaceFirst(
        '<svg',
        '<svg preserveAspectRatio="$preserveAspect" style="display:block;width:100%;height:100%"',
      );
    } catch (e) {
      final msg = escapeHtml(e.toString().replaceAll('BarcodeException: ', ''));
      svg =
          '<div style="width:100%;height:100%;display:flex;align-items:center;justify-content:center;background:#fef2f2;color:#b91c1c;font:7pt sans-serif;text-align:center;overflow:hidden">$msg</div>';
    }

    if (_svgCache.length > 500) _svgCache.clear();
    _svgCache[cacheKey] = svg;
  }

  final s = el.style;
  final text = el.showText && !twoD
      ? '<div style="flex:none;text-align:center;font-family:\'${s.fontFamily}\',sans-serif;font-size:${s.fontSize}pt;color:${s.color};line-height:1.1;white-space:nowrap;overflow:hidden;padding-top:0.3mm">${escapeHtml(value)}</div>'
      : '';

  final bgStyle =
      el.background.isNotEmpty ? 'background:${el.background};' : '';
  return '<div style="width:100%;height:100%;display:flex;flex-direction:column;box-sizing:border-box;$bgStyle"><div style="flex:1;min-height:0">$svg</div>$text</div>';
}
