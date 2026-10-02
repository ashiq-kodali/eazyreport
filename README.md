<p align="center">
  <img src="https://raw.githubusercontent.com/ashiq-kodali/eazyreport/main/assets/eazyreport_banner.png" alt="EazyReport - Pure Dart Reporting & Printing Engine for Flutter" width="100%">
</p>

<p align="center">
  <h1 align="center">⚡ EazyReport for Dart & Flutter</h1>
  <p align="center">
    <strong>Enterprise banded reporting and invoice printing engine written in 100% Pure Dart.</strong><br>
    Render <code>.rtpl</code> templates with JSON data into native vector PDFs, direct print dialogs, and pixel-perfect HTML.
  </p>
  <p align="center">
    <a href="https://pub.dev/packages/eazyreport"><img src="https://img.shields.io/pub/v/eazyreport.svg?color=2563eb" alt="pub package"></a>
    <a href="https://pub.dev/packages/eazyreport/score"><img src="https://img.shields.io/pub/points/eazyreport.svg?color=16a34a" alt="pub points"></a>
    <a href="https://opensource.org/licenses/MIT"><img src="https://img.shields.io/badge/License-MIT-blue.svg" alt="License: MIT"></a>
    <a href="https://eazyreport.in"><img src="https://img.shields.io/badge/Designer-eazyreport.in-7c3aed.svg" alt="Web Designer"></a>
    <img src="https://img.shields.io/badge/Platforms-Flutter%20%7C%20Dart%20Server%20%7C%20Web-0284c7.svg" alt="Platforms">
  </p>
</p>

---

## 🚀 Overview

**EazyReport** is a pure Dart reporting and document generation engine designed for Flutter apps and Dart backends. It loads visual report templates (`.rtpl` JSON) and binds them with your application data to produce publication-grade documents.

- **Zero JavaScript Dependencies**: No `flutter_js`, no `quickjs`, no Node.js, and no headless Chrome.
- **Zero WebViews Required**: Direct binary vector PDF rendering in memory.
- **Universal Multiplatform**: Runs on **Flutter** (iOS, Android, macOS, Windows, Linux, Web) and **Dart Server / CLI** (Docker, Cloud Functions, backend APIs).

---

## 🎨 Visual Template Designer

Design and test your `.rtpl` templates visually with drag-and-drop millimeter-accurate precision:

👉 **[https://eazyreport.in/](https://eazyreport.in/)**

Export the `.rtpl` file with one click, drop it into your Flutter `assets/` or server directory, and render it dynamically with real data.

---

## 📊 Why EazyReport?

| Feature | EazyReport | HTML-to-PDF / WebViews | Headless Chrome (Puppeteer) |
| :--- | :---: | :---: | :---: |
| **Pure Dart SDK** | ✅ **Yes (100%)** | ❌ Platform channels | ❌ Requires Node / Chromium |
| **No Headless Browser / WebView** | ✅ **Zero runtime** | ❌ Heavy WebView | ❌ 300MB+ Chromium binary |
| **Direct Flutter Printing** | ✅ **1 line code** | ⚠️ Slow canvas raster | ❌ Not available |
| **Native Binary PDF (`Uint8List`)** | ✅ **Yes** | ⚠️ Inconsistent OS print | ⚠️ High memory footprint |
| **Offline & Edge Compatible** | ✅ **Yes** | ⚠️ Fragile rendering | ❌ Server only |
| **Banded Pagination & Groups** | ✅ **Built-in** | ❌ Manual CSS breaks | ❌ Manual CSS breaks |
| **28+ Barcodes & 2D QR Codes** | ✅ **Built-in** | ❌ External JS libraries | ❌ External JS libraries |
| **Vector SVG Charts** | ✅ **Built-in** | ❌ Heavy JS chart engines | ❌ Heavy JS chart engines |

---

## 🛠️ Architecture Workflow

```
 ┌──────────────────────┐      ┌──────────────────────┐
 │  .rtpl Template File │  +   │   JSON Application   │
 │   (Visual Layout)    │      │         Data         │
 └──────────┬───────────┘      └──────────┬───────────┘
            │                             │
            └──────────────┬──────────────┘
                           │
                           ▼
            ┌─────────────────────────────┐
            │   EazyReport Pure Dart      │
            │   Pagination & Layout Engine│
            │  (Multi-pass, Groups, Math) │
            └──────────────┬──────────────┘
                           │
         ┌─────────────────┼─────────────────┐
         ▼                 ▼                 ▼
  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐
  │  Native PDF  │  │Flutter Print │  │Formatted HTML│
  │ (Uint8List)  │  │(Native Dialog│  │ (@page CSS   │
  │ for file/API │  │  iOS/Android/│  │  for browser │
  │              │  │ macOS/Win)   │  │   preview)   │
  └──────────────┘  └──────────────┘  └──────────────┘
```

---

## ✨ Key Features

- **📑 Banded Report Layout**:
  - `ReportTitle` & `PageHeader` (with `repeatOnEveryPage`, `printOnFirstPage`, `titleBeforeHeader`).
  - `DataBand` with grouping, sorting, filtering, and multi-column layouts (labels/cards).
  - `ChildBand` with `keepWithParent` and `fillUnusedSpace` (fills blank invoice lines down to footer).
  - FastReport condition flags (`PrintOn`: `FirstPage`, `LastPage`, `OddPages`, `EvenPages`, `RepeatedBand`).
  - Automatic two-pass page numbering (`Page {{Page}} of {{TotalPages}}`).
- **🔤 10 Layout Elements**:
  - `TextElement` & `FieldElement`: Formatted text, currency, dates, numbers, alignment, padding, borders.
  - `BarcodeElement`: 28+ 1D/2D symbologies (QR Code, Code 128, DataMatrix, PDF417, EAN-13, Aztec, Code 39, etc.).
  - `ChartElement`: Pure vector charts (Column, Bar, Line, Area, Pie, Doughnut).
  - `TableElement`: Grid tables with headers, column widths, striping, and auto footers.
  - `ShapeElement` & `LineElement`: Rectangles, rounded boxes, circles, ellipses, triangles, arrows.
  - `CheckboxElement`: Evaluated boolean checkboxes (checkmarks, crosses, fills).
  - `ImageElement`: Base64 data URIs, file paths, and remote URLs with `contain`, `cover`, `fill` modes.
  - `Watermark`: Under- or over-document watermarks with custom text, angle, and opacity.
- **🧮 35+ Built-in Handlebars Helpers**:
  - Math: `add`, `sub`, `mul`, `div`, `round`, `abs`, `min`, `max`.
  - Logic: `eq`, `neq`, `gt`, `gte`, `lt`, `lte`, `and`, `or`, `not`, `if`.
  - Formatting: `formatCurrency`, `formatNumber`, `formatDate`, `inWords` (cheque number-to-words).
  - Aggregations: `sum`, `avg`, `count`, `min`, `max`.

---

## 📦 Installation

Add `eazyreport` to your project's `pubspec.yaml`:

```yaml
dependencies:
  eazyreport: ^1.0.0
```

Install via terminal:

```bash
dart pub get
# or for Flutter:
flutter pub get
```

---

## ⚡ Quick Start

### 1. Direct Printing in Flutter

The fastest way to print invoices and reports directly using native OS print dialogs:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:printing/printing.dart';
import 'package:eazyreport/eazyreport.dart' hide TextStyle;

Future<void> printInvoice(BuildContext context) async {
  // 1. Load the .rtpl template from assets
  final rtplString = await rootBundle.loadString('assets/invoice.rtpl');

  // 2. Prepare your data
  final invoiceData = {
    'invoice': {'number': 'INV-2026-88219', 'date': '2026-10-01'},
    'customer': {'name': 'Eleanor Vance', 'company': 'Starlight Innovations'},
    'items': [
      {'description': 'Cloud Architecture Consulting', 'qty': 40, 'price': 80.0},
      {'description': 'Enterprise License', 'qty': 1, 'price': 1200.0},
    ],
  };

  // 3. Build report
  final builder = ReportBuilder.fromTemplate(rtplString)
    ..data(invoiceData);

  // 4. Print directly with 1 line of code!
  await Printing.layoutPdf(
    onLayout: (format) async => await builder.toPdf(),
    name: 'Invoice-88219.pdf',
  );
}
```

---

### 2. Generate Binary PDF (`Uint8List`) for File Storage or Email

Generate PDF bytes on Flutter, Dart Server, or CLI without any UI:

```dart
import 'dart:io';
import 'dart:typed_data';
import 'package:eazyreport/eazyreport.dart';

Future<void> createInvoiceFile() async {
  final rtplString = await File('templates/invoice.rtpl').readAsString();

  final builder = ReportBuilder.fromTemplate(rtplString)
    ..data({
      'invoice': {'number': 'INV-1001', 'total': 2500.0},
      'customer': {'name': 'Acme Corp'},
    })
    ..param('currency', 'USD');

  // Raw binary PDF bytes
  final Uint8List pdfBytes = await builder.toPdf();

  // Save to disk
  await File('invoice.pdf').writeAsBytes(pdfBytes);
  print('Saved invoice.pdf (${pdfBytes.length} bytes)');
}
```

---

### 3. Generate Formatted HTML

If you want HTML for browser display or `window.print()`:

```dart
import 'package:eazyreport/eazyreport.dart';

final html = getReportHtml(rtplString, invoiceData);
// Standalone HTML ready for webviews or browser window.print()
```

---

### 4. Template Validation & Page Counting

Ensure reports are valid before rendering:

```dart
final builder = ReportBuilder.fromTemplate(rtplString)
  ..data(invoiceData);

// Validate parameters & sources
final issues = builder.validate();
for (final issue in issues) {
  print(issue); // e.g. [warning] Required parameter "taxRate" is missing.
}

// Exact page calculation
final int totalPages = builder.pageCount();
print('Total pages: $totalPages');
```

---

## 🧮 Handlebars Helpers Reference

| Helper | Syntax Example | Description |
| :--- | :--- | :--- |
| `formatCurrency` | `{{formatCurrency item.price "USD"}}` | Formats number to localized currency string |
| `formatNumber` | `{{formatNumber item.qty 2}}` | Formats number with decimal places and commas |
| `formatDate` | `{{formatDate order.date "dd/MM/yyyy"}}` | Formats ISO date to custom pattern |
| `inWords` | `{{inWords invoice.total}}` | Converts number to cheque currency words |
| `sum` | `{{sum items "price"}}` | Calculates total sum of an array column |
| `avg` | `{{avg items "rating"}}` | Calculates average value of an array column |
| `count` | `{{count items}}` | Counts number of items in array |
| `mul` | `{{mul item.qty item.price}}` | Multiplies numbers |
| `add` / `sub` / `div` | `{{add a b}}`, `{{sub a b}}`, `{{div a b}}` | Basic arithmetic calculations |
| `eq` / `gt` / `lt` | `{{#if (gt item.qty 10)}}...{{/if}}` | Conditional logic evaluations |

---

## 📱 Interactive Flutter Example App

Check out the [`testproject/`](https://github.com/ashiq-kodali/eazyreport/tree/main/testproject) folder in the repository for a complete Flutter application featuring:
- Live PDF Preview with interactive zoom and page navigation.
- Native Print and PDF Sharing dialogs.
- Formatted HTML viewer with 1-click clipboard export.
- Real-time JSON dataset inspector.

Run it with:

```bash
cd testproject
flutter run
```

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

© Ashiq Kodali & EazyReport Contributors.

