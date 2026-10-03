## 1.0.2

- Updated documentation and README with real-world enterprise use cases matching [eazyreport.in](https://eazyreport.in/).
- Added Contributors section recognizing Ashiq Kodali and Thameem PK.
- Refined package descriptions and metadata.

## 1.0.1

- Updated official repository and issue tracker links to `https://github.com/ashiq-kodali/eazyreport`.
- Added GitHub Actions CI/CD workflows for automated testing, static analysis, and pub publishing.
- Updated author and copyright notices to Ashiq Kodali.
- Added native vector PDF generation (`Uint8List`) and direct Flutter printing integration.

## 1.0.0

- Initial pure Dart release of the `eazyreport` reporting engine.
- Zero JavaScript, zero JS runtime, zero webview or browser dependencies.
- Full support for `.rtpl` (v2) template parsing, serialization, and inheritance.
- Banded report layout hierarchy (Report Title, Page Header, Data Header, Group Header, Data Band, Group Footer, Data Footer, Report Summary, Page Footer, Overlay, Child Band).
- FastReport-style page condition flags (`PrintOn`: FirstPage, LastPage, OddPages, EvenPages, RepeatedBand).
- Automatic two-pass pagination for `TotalPages` and `LastPage`.
- FastReport-style Child bands with `keepWithParent` and `fillUnusedSpace`.
- Multi-column flow layouts for barcodes and badge printing.
- All 10 report elements: Text, Field, Image, Line, Shape, Table, Barcode, Checkbox, Chart, SubReport.
- Handlebars-compatible expression evaluation with math, logical, formatting, string, and aggregation helpers.
- Number-to-words currency generator for cheque and invoice amounts.
- Barcode and 2D code rendering using pure Dart `barcode` package (QR Code, Code 128, DataMatrix, PDF417, EAN-13, etc.).
- Pure Dart vector SVG chart generation (column, bar, line, area, pie, doughnut).
- Output to formatted standalone HTML documents with `@page` CSS print rules.
