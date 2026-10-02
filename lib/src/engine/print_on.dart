class PrintOnContext {
  final int pageNumber;
  final int? totalPages;
  final bool isFirst;
  final bool? isLast;
  final bool isRepeated;

  const PrintOnContext({
    required this.pageNumber,
    this.totalPages,
    required this.isFirst,
    this.isLast,
    this.isRepeated = false,
  });
}

const allPrintOnFlags = [
  'FirstPage',
  'LastPage',
  'OddPages',
  'EvenPages',
  'RepeatedBand',
];

/// Evaluates whether a band or object with FastReport `PrintOn` flags should print on the current page.
bool shouldPrintWithFlags(
  List<String>? printOn,
  PrintOnContext ctx, [
  bool defaultWhenUndefined = true,
]) {
  if (printOn == null || printOn.isEmpty) {
    return defaultWhenUndefined;
  }

  final pageNumber = ctx.pageNumber;
  final isOdd = pageNumber % 2 != 0;
  final isEven = !isOdd;
  final isLast = ctx.isLast ??
      (ctx.totalPages != null ? pageNumber == ctx.totalPages : false);
  final isRepeated = ctx.isRepeated;

  final hasFirst = printOn.contains('FirstPage');
  final hasLast = printOn.contains('LastPage');
  final hasOdd = printOn.contains('OddPages');
  final hasEven = printOn.contains('EvenPages');
  final hasRepeated = printOn.contains('RepeatedBand');

  // Rule 1: If repeated band and RepeatedBand flag is missing, suppress (unless explicitly requested via LastPage)
  if (isRepeated && !hasRepeated && !(isLast && hasLast)) {
    return false;
  }

  // Rule 2: If NOT repeated, but ONLY RepeatedBand is checked, suppress
  final hasNonRepeated = hasFirst || hasLast || hasOdd || hasEven;
  if (!isRepeated && !hasNonRepeated && hasRepeated) {
    return false;
  }

  // Rule 3: First page excluded if FirstPage is unchecked
  if (ctx.isFirst && !hasFirst) {
    return false;
  }

  // Rule 4: Last page excluded if LastPage is unchecked among page selection flags
  if (isLast && !hasLast && hasNonRepeated) {
    return false;
  }

  // Rule 5: Parity filter (only active when OddPages or EvenPages is specified)
  if (hasOdd || hasEven) {
    if (isOdd &&
        !hasOdd &&
        !(ctx.isFirst && hasFirst) &&
        !(isLast && hasLast)) {
      return false;
    }
    if (isEven &&
        !hasEven &&
        !(ctx.isFirst && hasFirst) &&
        !(isLast && hasLast)) {
      return false;
    }
  }

  // Rule 6: If ONLY FirstPage is selected, suppress on subsequent pages
  if (hasFirst &&
      !hasLast &&
      !hasOdd &&
      !hasEven &&
      !hasRepeated &&
      !ctx.isFirst) {
    return false;
  }

  // Rule 7: If ONLY LastPage is selected, suppress on non-last pages
  if (hasLast && !hasFirst && !hasOdd && !hasEven && !hasRepeated && !isLast) {
    return false;
  }

  return true;
}
