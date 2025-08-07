#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Auto Localizing Strings script by MajorE
///
/// This script automates the localization of user-facing strings in a Flutter project.
/// It scans all .dart files, classifies strings, and updates the ARB file accordingly.
/// The script is idempotent and safe to re-run multiple times.

// =============================================================================
// CONFIGURATION
// =============================================================================

/// Files and directories to exclude from scanning
final excludedFiles = [
  'lib/l10n/',
  'constants/',
  'environment_config.dart',
  '.dart_tool/',
  '.git/',
  '.idea/',
  'build/',
  'test/',
  '.g.dart',
  '.freezed.dart',
  './',
];

/// ARB file path
const arbFilePath = 'lib/l10n/arbs/app_en.arb';

// =============================================================================
// REGULAR EXPRESSIONS AND CLASSIFICATION PATTERNS
// =============================================================================

/// Pattern to match single-line string literals (double quotes)
final doubleQuotePattern = RegExp(r'"([^"]*)"');

/// Pattern to match single-line string literals (single quotes)
final singleQuotePattern = RegExp(r"'([^']*)'");

/// Pattern to match snake_case
final snakeCasePattern = RegExp(r'^[a-z]+(_[a-z]+)*$');

/// Pattern to match camelCase
final camelCasePattern = RegExp(r'^[a-z]+[A-Z][a-zA-Z]*$');

/// Pattern to match TODO comments for translation
final todoTranslatePattern = RegExp(r'//\s*TODO\(translate\):');

// =============================================================================
// COLOR CODES FOR TERMINAL OUTPUT
// =============================================================================

class Colors {
  static const String reset = '\x1B[0m';
  static const String red = '\x1B[31m';
  static const String green = '\x1B[32m';
  static const String yellow = '\x1B[33m';
  static const String blue = '\x1B[34m';
  static const String magenta = '\x1B[35m';
  static const String cyan = '\x1B[36m';
  static const String white = '\x1B[37m';
  static const String bold = '\x1B[1m';
}

// =============================================================================
// DATA STRUCTURES
// =============================================================================

typedef StringInstance = ({String filePath, int lineNumber});

class StringClassification {
  final String value;
  final List<StringInstance> instances;
  final String category;
  String? translationKey;

  StringClassification({
    required this.value,
    required this.instances,
    required this.category,
    this.translationKey,
  });

  @override
  String toString() {
    return '$category: "$value" in ${instances.length} instances - ${instances.map((e) => '${e.filePath}:${e.lineNumber}').join(', ')}';
  }
}

class ArbEntry {
  final String key;
  final String value;
  final String description;

  ArbEntry({required this.key, required this.value, required this.description});

  Map<String, dynamic> toJson() {
    return {
      key: value,
      '@$key': {'description': description},
    };
  }
}

// =============================================================================
// UTILITY FUNCTIONS
// =============================================================================

/// Print colored output to terminal
void printColored(String message, String color) {
  stdout.write('$color$message${Colors.reset}');
}

/// Print colored output with newline
void printColoredLn(String message, String color) {
  print('$color$message${Colors.reset}');
}

/// Generate a hash for string uniqueness
String generateHash(String input) {
  int hash = 0;
  for (int i = 0; i < input.length; i++) {
    hash = ((hash << 5) - hash + input.codeUnitAt(i)) & 0xFFFFFFFF;
  }
  return hash.abs().toString().padLeft(6, '0');
}

/// Clean and normalize string for key generation
String normalizeString(String input) {
  return input
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ') // Replace multiple spaces with single space
      .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special characters except spaces
      .toLowerCase();
}

/// Generate translation key from string
String generateTranslationKey(String input) {
  final normalized = normalizeString(input);
  final words = normalized.split(' ').where((word) => word.isNotEmpty).toList();

  if (words.isEmpty) return 'empty_string';

  if (words.length <= 4) {
    return words.join('_');
  } else if (words.length <= 8) {
    // Take first 2 words + next meaningful words
    final meaningfulWords = words.skip(2).take(2).toList();
    return [...words.take(2), ...meaningfulWords].join('_');
  } else {
    // Take first 2 words + next meaningful words + hash
    final meaningfulWords = words.skip(2).take(2).toList();
    final baseKey = [...words.take(2), ...meaningfulWords].join('_');
    final hash = generateHash(input);
    return '${baseKey}_$hash';
  }
}

/// Check if file should be excluded
bool shouldExcludeFile(String filePath) {
  return excludedFiles.any((excluded) => filePath.contains(excluded));
}

/// Detects multiline concatenated string blocks and returns their metadata
///
/// This method identifies patterns like:
///   String get withEnv =>
///     '${EnvironmentConfig.isProd ? 'prod' : 'staging'}'
///     '_'
///     '${Platform.isIOS ? 'ios' : 'android'}'
///     '_'
///     '$this';
///
/// Detection logic:
/// 1. Look backwards to find the start of the block (skip empty lines)
/// 2. Check if the previous line ends with '=>' or '=' (getter/setter syntax)
/// 3. Scan forward to find consecutive string literal lines
/// 4. Count how many string lines we have and check for variables
///
/// Returns a map with:
/// - 'start': Line index where the string block begins
/// - 'end': Line index where the string block ends (exclusive)
/// - 'hasVariable': Whether any line contains variable interpolation
///
/// Returns null if this is not a multiline concatenated string block
Map<String, dynamic>? getMultilineConcatenatedStringBlock(List<String> lines, int index) {
  // Step 1: Find the start of the block by going backwards, skipping empty lines
  int i = index;
  while (i > 0 && lines[i].trim().isEmpty) i--;
  if (i == 0) return null;

  // Step 2: Check if the previous line indicates a getter/setter (ends with => or =)
  String prev = lines[i - 1].trim();
  if (!(prev.endsWith('=>') || prev.endsWith('='))) return null;

  // Step 3: Scan forward to find consecutive string literal lines
  int j = i;
  int stringLines = 0;
  bool hasVariable = false;
  while (j < lines.length) {
    String l = lines[j].trim();
    if (l.isEmpty) {
      j++;
      continue;
    } // Skip empty lines

    // Check if this line is a string literal (single or double quoted)
    if ((l.startsWith("'") && l.endsWith("'")) || (l.startsWith('"') && l.endsWith('"'))) {
      stringLines++;
      // Check if this string contains variable interpolation
      if (containsDartVariable(l)) hasVariable = true;
      j++;
      continue;
    }
    // If we hit a non-string line, we've reached the end of the block
    break;
  }

  // Step 4: Only return a block if we found multiple string lines
  if (stringLines > 1) {
    return {'start': i, 'end': j, 'hasVariable': hasVariable};
  }
  return null;
}

/// Extract all string literals from a file
List<StringClassification> extractStringsFromFile(String filePath) {
  final file = File(filePath);
  if (!file.existsSync()) return [];

  final content = file.readAsStringSync();
  final lines = content.split('\n');
  final classifications = <StringClassification>[];

  for (int i = 0; i < lines.length; i++) {
    final line = lines[i];
    final lineNumber = i + 1;

    // Skip lines that already have TO DO(translate) comments
    if (todoTranslatePattern.hasMatch(line)) {
      classifications.add(
        StringClassification(
          value: lines[i + 1],
          instances: [(filePath: filePath, lineNumber: lineNumber + 1)],
          category: 'old_manual',
        ),
      );
      if (i + 1 < lines.length) {
        i++; // Skip the next line
        continue;
      }
    }

    // Skip the next line if this line contains ignore directive
    if (line.trim().contains('// ignore: auto_localize.')) {
      if (i + 1 < lines.length) {
        i++; // Skip the next line
        continue;
      }
    }

    // Detect multiline concatenated strings
    // This handles cases where strings are split across multiple lines without + operator
    // Example:
    //   String get withEnv =>
    //     '${EnvironmentConfig.isProd ? 'prod' : 'staging'}'
    //     '_'
    //     '${Platform.isIOS ? 'ios' : 'android'}'
    //     '_'
    //     '$this';
    final block = getMultilineConcatenatedStringBlock(lines, i);
    if (block != null) {
      int start = block['start'];
      int end = block['end'];
      // bool hasVariable = block['hasVariable'];

      classifications.add(
        StringClassification(
          value: lines[start],
          instances: [(filePath: filePath, lineNumber: start)],
          category: 'manual',
        ),
      );

      // Skip to the end of the block to avoid processing the same lines again
      i = end - 1;
      continue;
    }

    // Extract double-quoted strings
    final doubleQuoteMatches = doubleQuotePattern.allMatches(line);
    for (final match in doubleQuoteMatches) {
      final value = match.group(1) ?? '';
      if (value.isNotEmpty) {
        final isStringLine = verifyStringLine(value, line, lines, i);
        if (!isStringLine) 
        
          continue;
        
        classifications.add(
          StringClassification(
            value: value,
            instances: [(filePath: filePath, lineNumber: lineNumber)],
            category: 'raw', // Will be classified later
          ),
        );
      }
    }

    // Extract single-quoted strings
    final singleQuoteMatches = singleQuotePattern.allMatches(line);
    for (final match in singleQuoteMatches) {
      final value = match.group(1) ?? '';
      if (value.isNotEmpty) {
        // Debug: Check if this is from comprehensive test cases
        if (filePath.contains('comprehensive_test_cases')) {
          printColoredLn('DEBUG: Found single-quoted string: "$value"', Colors.green);
        }
        final isStringLine = verifyStringLine(value, line, lines, i);
        if (!isStringLine) {
          if (filePath.contains('comprehensive_test_cases')) {
            printColoredLn('DEBUG: Rejected single-quoted string: "$value"', Colors.red);
          }
          continue;
        }
        classifications.add(
          StringClassification(
            value: value,
            instances: [(filePath: filePath, lineNumber: lineNumber)],
            category: 'raw', // Will be classified later
          ),
        );
      }
    }
  }

  return classifications;
}

bool verifyStringLine(String stringValue, String line, List<String> lines, int i) {
  // Check for RegExp patterns first
  if (isRegExpPattern(line)) {
    return false;
  }
  // Check for comment lines
  if (isCommentLine(line)) {
    return false;
  }
  // Check for technical patterns
  if (isTechnicalLine(stringValue)) return false;

  // Check for logger patterns in current line and previous lines
  bool isLoggerLine = isLoggerOrAnalyticsString(line);
  if (!isLoggerLine && i > 0) {
    // Check previous line for logger patterns
    isLoggerLine = isLoggerOrAnalyticsString(lines[i - 1]);
  }
  if (!isLoggerLine && i > 1) {
    // Check line before previous for logger patterns
    isLoggerLine = isLoggerOrAnalyticsString(lines[i - 2]);
  }
  if (isLoggerLine) return false;
  return true;
}

bool isLoggerOrAnalyticsString(String line) {
  // Check for Logger patterns (.severe, .config, .finest, .log, etc.)
  if (RegExp(
    r'\.(severe|shout|warning|info|config|fine|finer|finest|log)',
    caseSensitive: false,
  ).hasMatch(line)) {
    return true;
  }

  // Check for Logger class usage
  if (RegExp(r'Logger\.', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  // Check for AnalyticsService.log
  if (RegExp(r'AnalyticsService\.log', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  // Check for common logging patterns
  if (RegExp(r'\.log\(', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  // Check for print statements (often used for debugging)
  if (RegExp(r'print\s*\(', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  // Check for debug/error logging patterns
  if (RegExp(r'(debug|error|warn|info|trace)\s*\(', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  // Check for analytics tracking patterns
  if (RegExp(r'\.track\(|\.event\(|\.logEvent\(', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  // Check for console logging patterns
  if (RegExp(r'console\.(log|warn|error|info)', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  // Check for Firebase Analytics patterns
  if (RegExp(r'FirebaseAnalytics\.|Analytics\.', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  // Check for crashlytics patterns
  if (RegExp(r'Crashlytics\.|crashlytics\.', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  // Check for custom logger patterns
  if (RegExp(r'logger\.|_logger\.', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  // Check for logging method calls
  if (RegExp(
    r'\.(logError|logWarning|logInfo|logDebug|logTrace)',
    caseSensitive: false,
  ).hasMatch(line)) {
    return true;
  }

  return false;
}

/// Check if a line contains technical patterns that should be excluded
bool isTechnicalLine(String line) {
  // Technical patterns to exclude (based on translate.py)
  final technicalPatterns = [
    // API/Network patterns
    'http://', 'https://', 'api/', 'endpoint', 'token', 'bearer', 'authorization', 'multipart',

    // JSON/Serialization patterns
    'toMap', 'fromMap', 'json', 'serialization', 'deserialization',

    // Flutter/Dart technical patterns
    'dart:', 'package:', 'import', 'export', 'class', 'enum', 'typedef',
    'const', 'final', 'var', 'String', 'int', 'bool', 'double', 'List', 'Map',
    'Widget', 'BuildContext', 'MaterialApp', 'Scaffold', 'Container', 'Column',
    'Row', 'Text', 'Button', 'AppBar', 'ListView',

    // Debug/Development patterns
    'debug', 'mock', 'stub', 'fixture', 'example', 'TODO', 'FIXME', 'HACK', 'NOTE', 'XXX',

    // File/Path patterns
    'assets/', 'lib/', 'test/', 'android/', 'ios/', '.dart', '.arb', '.json', '.yaml', '.yml',

    // Variable/Property patterns
    'controller', 'key', 'value', 'data', 'response', 'request', 'status', 'code', 'id',
    'type', 'name', 'url', 'uri', 'path', 'file',
    'folder', 'directory',

    // Error/Exception patterns
    'exception', 'error', 'failure', 'timeout', 'network', 'server', 'client',
    'unauthorized', 'forbidden', 'not_found', 'bad_request', 'internal_server_error',

    // Date/Time patterns
    'yyyy-MM-dd', 'HH:mm:ss', 'ISO', 'UTC', 'timestamp', 'date', 'time', 'datetime',

    // Currency/Number patterns
    'currency', 'amount', 'price', 'cost', 'total', 'sum', 'count', 'number',
    'decimal', 'integer', 'float', 'double',

    // UI/UX patterns
    'color', 'style', 'theme', 'font', 'size', 'width', 'height', 'padding',
    'margin', 'border', 'radius', 'shadow', 'gradient', 'opacity', 'alpha', 'rgb', 'hex',
  ];

  final lineLower = line.toLowerCase();

  // Check for technical patterns
  for (final pattern in technicalPatterns) {
    if (lineLower.contains(pattern.toLowerCase())) {
      return true;
    }
  }

  // Check for code patterns (parentheses, brackets, etc.)
  if (((line.contains('(') && line.contains(')')) || 
       (line.contains('[') && line.contains(']')) || 
       (line.contains('{') && line.contains('}')) || 
       (line.contains('<') && line.contains('>'))) && 
      !line.contains('\${')) {
    return true;
  }

  return false;
}

/// Check if a line contains RegExp patterns that should be excluded
bool isRegExpPattern(String line) {
  // Check for RegExp constructor patterns
  if (RegExp(r'RegExp\s*\(', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  // Check for raw string RegExp patterns (r"...")
  if (RegExp(
    r'r\s*["'
    ']',
    caseSensitive: false,
  ).hasMatch(line)) {
    return true;
  }

  // Check for RegExp literal patterns
  if (RegExp(r'/\s*[^/]+\s*/', caseSensitive: false).hasMatch(line)) {
    return true;
  }

  return false;
}

/// Check if a line is a comment
bool isCommentLine(String line) {
  final trimmedLine = line.trim();
  return trimmedLine.startsWith('//') ||
      trimmedLine.startsWith('/*') ||
      trimmedLine.startsWith('*') ||
      trimmedLine.startsWith('///') ||
      trimmedLine.startsWith('/**');
}

/// Check if string contains only numbers and special characters
bool isOnlyNumbersAndSpecial(String value) {
  // Simple check for strings that contain only numbers and common special characters
  final specialChars = '0123456789 -.,!@#\$%^&*()[]{}|;:"\'<>?/\\`~_+';
  return value.split('').every((char) => specialChars.contains(char));
}

/// Check if string is a hex code
bool isHexCode(String value) {
  return RegExp(r'^#[0-9A-Fa-f]{3,6}$').hasMatch(value);
}

/// Check if string matches technical patterns
bool isTechnicalPattern(String value) {
  // Constants like API_KEY, USER_ID
  if (RegExp(r'^[A-Z_]+$').hasMatch(value)) return true;

  // // Technical identifiers
  // if (RegExp(r'^[a-z]+_[a-z]+_[a-z]+$').hasMatch(value)) return true;

  // Pure numbers
  if (RegExp(r'^[0-9]+$').hasMatch(value)) return true;

  // File extensions
  if (RegExp(r'^[a-zA-Z0-9_]+\.(dart|json|yaml|yml|xml|html|css|js|ts)$').hasMatch(value))
    return true;

  // URLs
  if (RegExp(r'^[a-zA-Z0-9_]+://').hasMatch(value)) return true;

  // Email addresses
  if (RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(value)) return true;

  // IP addresses
  if (RegExp(r'^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$').hasMatch(value)) return true;

  // Date formats
  if (RegExp(r'^[0-9]{4}-[0-9]{2}-[0-9]{2}$').hasMatch(value)) return true;

  // Time formats
  if (RegExp(r'^[0-9]{2}:[0-9]{2}:[0-9]{2}$').hasMatch(value)) return true;

  return false;
}

/// Check if string is concatenated or contains Dart variable interpolation
bool isConcatenatedString(String value) {
  return value.contains(' + ') || value.contains('+') || containsDartVariable(value);
}

/// Check if a string contains Dart variable interpolation (e.g. ${var} or $var)
bool containsDartVariable(String value) {
  // Matches ${...} or $identifier
  return RegExp(r'\$\{[^}]+\}|\$[a-zA-Z_][a-zA-Z0-9_]*').hasMatch(value);
}

/// Check if string already exists in ARB file
bool isStringInArb(String value) {
  try {
    final arbFile = File(arbFilePath);
    if (!arbFile.existsSync()) return false;

    final content = arbFile.readAsStringSync();
    final arbData = json.decode(content) as Map<String, dynamic>;

    return arbData.values.any((v) => v == value);
  } catch (e) {
    return false;
  }
}

/// Load existing ARB file
Map<String, dynamic> loadArbFile() {
  try {
    final arbFile = File(arbFilePath);
    if (!arbFile.existsSync()) {
      return {'@@locale': 'en'};
    }

    final content = arbFile.readAsStringSync();
    return json.decode(content) as Map<String, dynamic>;
  } catch (e) {
    return {'@@locale': 'en'};
  }
}

/// Save ARB file
void saveArbFile(Map<String, dynamic> arbData) {
  final arbFile = File(arbFilePath);
  final content = json.encode(arbData);
  arbFile.writeAsStringSync(content);
}

/// Create backup of ARB file
String createArbBackup() {
  final arbFile = File(arbFilePath);
  final backupPath = '$arbFilePath.backup';
  final backupFile = File(backupPath);

  if (arbFile.existsSync()) {
    backupFile.writeAsStringSync(arbFile.readAsStringSync());
  }

  return backupPath;
}

/// Restore ARB file from backup
void restoreArbBackup(String backupPath) {
  final backupFile = File(backupPath);
  final arbFile = File(arbFilePath);

  if (backupFile.existsSync()) {
    arbFile.writeAsStringSync(backupFile.readAsStringSync());
  }
}

/// Delete backup file
void deleteBackup(String backupPath) {
  final backupFile = File(backupPath);
  if (backupFile.existsSync()) {
    backupFile.deleteSync();
  }
}

/// Run flutter gen-l10n command
bool runFlutterGenL10n() {
  try {
    final result = Process.runSync('flutter', ['gen-l10n']);
    printColoredLn(result.exitCode.toString(), Colors.red);
    printColoredLn(result.stdout.toString(), Colors.red);
    printColoredLn(result.stderr.toString(), Colors.red);
    return result.exitCode == 0;
  } catch (e) {
    return false;
  }
}

/// Replace strings in source files with translation calls
void replaceStringsInFiles(List<StringClassification> stringsToReplace) {
  final filesToUpdate = <String, List<StringClassification>>{};

  // Group strings by file
  for (final str in stringsToReplace) {
    for (final instance in str.instances) {
      filesToUpdate.putIfAbsent(instance.filePath, () => []).add(str);
    }
  }

  for (final entry in filesToUpdate.entries) {
    final filePath = entry.key;
    final strings = entry.value;

    final file = File(filePath);
    if (!file.existsSync()) continue;

    String content = file.readAsStringSync();
    final lines = content.split('\n');

    // Sort strings by line number in descending order to avoid line number shifts
    strings.sort(
      (a, b) => b.instances
          .firstWhere((instance) => instance.filePath == filePath)
          .lineNumber
          .compareTo(
            a.instances.firstWhere((instance) => instance.filePath == filePath).lineNumber,
          ),
    );

    for (final str in strings) {
      final instance = str.instances.firstWhere((instance) => instance.filePath == filePath);
      final lineIndex = instance.lineNumber - 1;
      if (lineIndex >= 0 && lineIndex < lines.length) {
        final line = lines[lineIndex];

        // Replace the string with translation call (handle both single and double quotes)
        String replacement = line;
        
        // Try to replace double-quoted string
        final doubleQuotedPattern = '"${str.value}"';
        if (replacement.contains(doubleQuotedPattern)) {
          replacement = replacement.replaceAll(
            doubleQuotedPattern,
            'context.translations.${str.translationKey ?? generateTranslationKey(str.value)}',
          );
        }
        
        // Try to replace single-quoted string
        final singleQuotedPattern = "'${str.value}'";
        if (replacement.contains(singleQuotedPattern)) {
          replacement = replacement.replaceAll(
            singleQuotedPattern,
            'context.translations.${str.translationKey ?? generateTranslationKey(str.value)}',
          );
        }

        lines[lineIndex] = replacement;
      }
    }

    // Write updated content back to file
    file.writeAsStringSync(lines.join('\n'));
  }
}

/// Mark manual strings with TODO comments
void markManualStrings(List<StringClassification> manualStrings) {
  final filesToUpdate = <String, List<StringClassification>>{};

  // Group strings by file
  for (final str in manualStrings) {
    for (final instance in str.instances) {
      filesToUpdate.putIfAbsent(instance.filePath, () => []).add(str);
    }
  }

  for (final entry in filesToUpdate.entries) {
    final filePath = entry.key;
    final strings = entry.value;

    final file = File(filePath);
    if (!file.existsSync()) continue;

    String content = file.readAsStringSync();
    final lines = content.split('\n');

    // Sort strings by line number in descending order to avoid line number shifts
    strings.sort(
      (a, b) => b.instances
          .firstWhere((instance) => instance.filePath == filePath)
          .lineNumber
          .compareTo(
            a.instances.firstWhere((instance) => instance.filePath == filePath).lineNumber,
          ),
    );

    for (final str in strings) {
      final instance = str.instances.firstWhere((instance) => instance.filePath == filePath);
      final lineIndex = instance.lineNumber - 1;
      if (lineIndex >= 0 && lineIndex < lines.length) {
        final line = lines[lineIndex];

        // Check if TO DO comment already exists
        if (!todoTranslatePattern.hasMatch(line)) {
          final firstThreeWords = str.value.split(' ').take(3).join(' ');
          final todoComment =
              '// TODO(translate): add translation variable for: "$firstThreeWords..."';

          // Insert TO DO comment above the line
          lines.insert(lineIndex, todoComment);
        }
      }
    }

    // Write updated content back to file
    file.writeAsStringSync(lines.join('\n'));
  }
}

/// Classify strings based on the specified rules
List<StringClassification> classifyStrings(List<StringClassification> rawStrings) {
  final classified = <StringClassification>[];

  for (final str in rawStrings) {
    String category = 'unknown';

    // Check if already in ARB file
    if (isStringInArb(str.value)) {
      category = 'replace';
    }
    // Check if length <= 1
    else if (str.value.length <= 1) {
      category = 'exempt';
    }
    // Check if only numbers and special characters
    else if (isOnlyNumbersAndSpecial(str.value)) {
      category = 'exempt';
    }
    // Check if snake_case or camelCase
    else if (snakeCasePattern.hasMatch(str.value) || camelCasePattern.hasMatch(str.value)) {
      category = 'exempt';
    }
    // Check if hex code
    else if (isHexCode(str.value)) {
      category = 'exempt';
    }
    // Check if technical/code pattern
    else if (isTechnicalPattern(str.value)) {
      category = 'exempt';
    }
    // Check if concatenated string
    else if (isConcatenatedString(str.value)) {
      category = 'manual';
    }
    // Default to process
    else {
      category = 'process';
    }

    classified.add(
      StringClassification(value: str.value, instances: str.instances, category: category),
    );
  }

  return classified;
}

/// Recursively find all .dart files
List<String> findAllDartFiles(String directory) {
  final files = <String>[];
  final dir = Directory(directory);

  if (!dir.existsSync()) return files;

  try {
    for (final entity in dir.listSync(recursive: true)) {
      if (entity is File && entity.path.endsWith('.dart')) {
        final relativePath = entity.path.replaceFirst('$directory/', 'lib/');
        if (!shouldExcludeFile(relativePath)) {
          files.add(entity.path);
        }
      }
    }
  } catch (e) {
    // Ignore permission errors or other issues
  }

  return files;
}

// =============================================================================
// MAIN SCRIPT
// =============================================================================

void main() async {
  printColoredLn('Auto Localizing Strings script by MajorE', Colors.bold + Colors.cyan);
  printColoredLn('==============================', Colors.cyan);

  // Check if we're in a Flutter project
  if (!File('pubspec.yaml').existsSync()) {
    printColoredLn('Error: Not in a Flutter project root directory', Colors.red);
    exit(1);
  }

  // Check if ARB file exists
  if (!File(arbFilePath).existsSync()) {
    printColoredLn('Error: ARB file not found at $arbFilePath', Colors.red);
    exit(1);
  }

  printColoredLn('Scanning for strings ...', Colors.blue);
  printColoredLn('Excluding these files:', Colors.yellow);
  for (final excluded in excludedFiles) {
    printColoredLn('  - $excluded', Colors.yellow);
  }
  printColoredLn('', Colors.reset);

  // Find all .dart files
  final dartFiles = findAllDartFiles('./lib');
  printColoredLn('Found ${dartFiles.length} .dart files to scan', Colors.blue);

  // Extract all strings
  final allStrings = <StringClassification>[];
  for (final filePath in dartFiles) {
    allStrings.addAll(extractStringsFromFile(filePath));
  }

  // Group unique strings by value, combining instances from multiple files/lines
  final uniqueStrings = <StringClassification>[];
  final stringMap = <String, StringClassification>{};

  for (final str in allStrings) {
    if (stringMap.containsKey(str.value)) {
      // Add instances to existing classification
      stringMap[str.value]!.instances.addAll(str.instances);
    } else {
      // Create new classification
      stringMap[str.value] = StringClassification(
        value: str.value,
        instances: List.from(str.instances),
        category: 'raw', // Will be classified later
      );
    }
  }

  uniqueStrings.addAll(stringMap.values);
  printColoredLn('${uniqueStrings.length} unique strings found', Colors.white);

  // Classify strings
  final classifiedStrings = classifyStrings(uniqueStrings);

  // Count by category
  final counts = <String, int>{};
  for (final str in classifiedStrings) {
    counts[str.category] = (counts[str.category] ?? 0) + 1;
  }

  // Print classification results
  printColoredLn('${counts['replace'] ?? 0} already in arb - marked for replacement', Colors.green);
  printColoredLn('${counts['exempt'] ?? 0} are not user-facing - ignored', Colors.yellow);
  printColoredLn(
    '${(counts['manual'] ?? 0) + (counts['old_manual'] ?? 0)} are complex strings - manual intervention needed',
    Colors.magenta,
  );
  printColoredLn(
    '${counts['process'] ?? 0} direct user facing - marked for processing',
    Colors.blue,
  );
  if (counts['unknown'] != null && counts['unknown']! > 0) {
    printColoredLn('${counts['unknown'] ?? 0} strings left - unsure what they are', Colors.red);
  }
  printColoredLn('Scanning complete', Colors.green);
  printColoredLn('================================', Colors.cyan);

  // Process strings
  final processStrings = classifiedStrings.where((s) => s.category == 'process').toList();
  final replaceStrings = classifiedStrings.where((s) => s.category == 'replace').toList();
  final manualStrings = classifiedStrings.where((s) => s.category == 'manual').toList();

  if (processStrings.isNotEmpty) {
    printColoredLn('Processing ${processStrings.length} strings ...', Colors.blue);

    printColoredLn('- creating arb backup', Colors.blue);
    // Create backup
    final backupPath = createArbBackup();

    printColoredLn('- generating keys', Colors.blue);
    try {
      // Load existing ARB data
      final arbData = loadArbFile();

      // Add new entries
      for (final str in processStrings) {
        final key = generateTranslationKey(str.value);
        final entry = ArbEntry(
          key: key,
          value: str.value,
          description: 'Auto-generated for: ${str.value}',
        );

        // Add to ARB data
        arbData.addAll(entry.toJson());

        // Update the string classification with the key
        str.translationKey = key;
      }

      // Save ARB file
      printColoredLn('- adding to arb', Colors.blue);
      saveArbFile(arbData);

      // Run flutter gen-l10n
      printColoredLn('running flutter gen-l10n...', Colors.blue);
      final success = runFlutterGenL10n();

      if (success) {
        printColoredLn('flutter gen-l10n completed successfully', Colors.green);
        deleteBackup(backupPath);

        // Add processed strings to replace list
        replaceStrings.addAll(processStrings);
      } else {
        printColoredLn('flutter gen-l10n failed, restoring backup', Colors.red);
        restoreArbBackup(backupPath);
        exit(1);
      }
    } catch (e) {
      printColoredLn('Error processing strings: $e', Colors.red);
      restoreArbBackup(backupPath);
      exit(1);
    }

    printColoredLn('Processing complete', Colors.green);
    printColoredLn('================================', Colors.cyan);
  }

  // Replace strings
  if (replaceStrings.isNotEmpty) {
    final sumOfInstances = replaceStrings.fold(0, (sum, string) => sum + string.instances.length);
    printColoredLn(
      'Replacing ${replaceStrings.length} strings in $sumOfInstances instances...',
      Colors.blue,
    );

    // Generate keys for replace strings that don't have them
    for (final str in replaceStrings) {
      str.translationKey ??= generateTranslationKey(str.value);
    }

    replaceStringsInFiles(replaceStrings);
    printColoredLn('Replacement complete', Colors.green);
    printColoredLn('================================', Colors.cyan);
  }

  // Mark manual strings
  if (manualStrings.isNotEmpty) {
    printColoredLn(
      'Marking ${manualStrings.length} strings for manual intervention',
      Colors.magenta,
    );
    markManualStrings(manualStrings);
    printColoredLn('Marking complete', Colors.green);
    printColoredLn('================================', Colors.cyan);
  }

  // Summary
  printColoredLn('Summary', Colors.bold + Colors.cyan);
  printColoredLn('${uniqueStrings.length} strings found (outside excluded files)', Colors.white);
  printColoredLn('${processStrings.length} processed into arb', Colors.green);
  printColoredLn(
    '${replaceStrings.length} replacements with context based translation variables',
    Colors.blue,
  );
  printColoredLn('${manualStrings.length} strings need to be manually processed', Colors.magenta);
  printColoredLn('', Colors.reset);
  printColoredLn('All done!', Colors.bold + Colors.green);
}
