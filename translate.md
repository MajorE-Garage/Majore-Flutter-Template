# Translation Automation Script Documentation

## Overview
The `translate.py` script automates the internationalization process for Flutter/Dart codebases. It finds user-facing strings, adds them to ARB files, generates localization files, and replaces hardcoded strings with translation getters.

## Feature Set

### Core Functionality
1. **Automated String Detection**
   - Scans all Dart files in the project
   - Identifies user-facing strings in Text, SelectableText, Tooltip, and other widgets
   - Detects strings in property assignments (label, hint, heading, body, title, etc.)
   - Handles multi-line strings with triple quotes
   - Supports both single and double quoted strings

2. **Smart String Filtering**
   - Excludes technical patterns (URLs, API endpoints, file paths, etc.)
   - Excludes code patterns (function calls, brackets, etc.)
   - Excludes variable names (camelCase, snake_case)
   - Excludes constants (UPPER_CASE patterns)
   - Excludes single letters (A, B, C, etc.)
   - Excludes numbers-only strings (1, 2, 123456789, etc.)
   - Excludes punctuation-only strings (!, ?, etc.)
   - Includes strings with 2+ characters (Hi, No, Yes, etc.)

3. **ARB File Management**
   - Automatically adds new strings to the base ARB file
   - Generates unique keys for each string
   - Creates backup before modifications
   - Automatic cleanup of backup files after successful operations
   - Error recovery with backup restoration
   - Handles existing translations without duplication

4. **Code Replacement**
   - Replaces hardcoded strings with `context.translations.keyName`
   - Handles all widget types: Text, SelectableText, Tooltip, etc.
   - Handles property assignments: label, hint, heading, body, title, etc.
   - Supports multi-line string replacement
   - Preserves code formatting and structure
   - Idempotent operations (safe to run multiple times)

5. **Localization Generation**
   - Runs `flutter gen-l10n` to generate localization files
   - Updates generated translation classes
   - Ensures all new strings are available in code

6. **Comprehensive Reporting**
   - Shows total files scanned and processed
   - Lists new strings added to ARB
   - Lists existing strings found
   - Shows detailed string locations with file paths and line numbers
   - Provides clickable file paths in reports
   - Shows total replacements made

7. **Unprocessed String Management**
   - Filters unprocessed strings by category
   - Excludes expected technical patterns from reports
   - Shows only strings that might need manual attention
   - Categorizes by reason: String Concatenation, Too Short, etc.

8. **TODO Comment System**
   - Automatically adds Flutter-style TODO comments for user-facing strings that couldn't be processed
   - Uses format: `// TODO(translation): Translate this string: 'string'`
   - Only adds TODOs for strings that might be user-facing
   - Excludes numbers-only strings from TODO comments
   - Idempotent: won't create duplicate TODOs

9. **Backup Management**
   - Creates backups before ARB file modifications
   - Automatic cleanup after successful operations
   - Error recovery with backup restoration
   - No orphaned backup files

10. **Idempotent Operations**
    - Safe to run multiple times
    - No duplicate string additions
    - No duplicate TODO comments
    - Consistent results across runs

### Advanced Features
11. **Multi-line String Support**
    - Detects strings spanning multiple lines
    - Handles triple-quote delimiters
    - Preserves formatting in multi-line strings

12. **String Type Detection**
    - Automatically determines string context
    - Handles different widget types appropriately
    - Supports property-based string detection

13. **Key Generation**
    - Creates human-readable keys from strings
    - Ensures uniqueness with counter suffixes
    - Handles special characters and spaces
    - Avoids Dart keywords

14. **Error Handling**
    - Graceful handling of file read/write errors
    - Backup restoration on failures
    - Detailed error messages with colored output
    - Continues processing other files on individual failures

15. **Performance Optimization**
    - Groups strings by file to minimize file operations
    - Sorts replacements to avoid line number shifts
    - Efficient regex patterns for string detection

### User Experience
16. **Colored Output**
    - Green for success messages
    - Yellow for warnings and backups
    - Red for errors
    - Blue for information
    - Purple for detailed reports

17. **Detailed Progress**
    - Shows scanning progress
    - Reports file processing status
    - Provides step-by-step feedback

18. **Actionable Reports**
    - Clear next steps for users
    - Identifies files that need manual review
    - Provides specific guidance for unprocessed strings

### Quality Assurance
19. **Comprehensive Testing**
    - Handles edge cases in string detection
    - Robust regex patterns for various code styles
    - Safe string replacement without breaking code

20. **Maintainability**
    - Well-documented code structure
    - Modular design for easy extension
    - Clear separation of concerns

This feature set ensures the script is production-ready, handles all common Flutter internationalization scenarios, and provides a smooth developer experience for migrating existing code to use Flutter's localization system. 

## Assumptions & Patterns

### User-Facing String Patterns
The script identifies user-facing strings based on these patterns:

#### Widget Property Patterns:
- `label:` - Text labels for input fields, buttons, etc.
- `hint:` - Placeholder text for input fields
- `prefixText:` - Prefix text for input fields
- `heading:` - Dialog and section headings
- `body:` - Dialog body text
- `title:` - Widget titles
- `yesLabel:` - Confirmation dialog yes button
- `cancelLabel:` - Confirmation dialog cancel button

#### Direct Text Widget Patterns:
- `Text(` - Direct text widgets with string literals

#### Error/Message Patterns:
- `error:` - Error messages
- `message:` - General messages

### Technical Patterns (Excluded)
The script excludes strings matching these technical patterns:

#### API/Network:
- `http://`, `https://`, `api/`, `endpoint`, `token`, `bearer`, `authorization`

#### JSON/Serialization:
- `toMap`, `fromMap`, `json`, `serialization`, `deserialization`

#### Flutter/Dart Technical:
- `dart:`, `package:`, `import`, `export`, `class`, `enum`, `typedef`
- `const`, `final`, `var`, `String`, `int`, `bool`, `double`, `List`, `Map`
- `Widget`, `BuildContext`, `MaterialApp`, `Scaffold`, `Container`, `Column`
- `Row`, `Text`, `Button`, `AppBar`, `ListView`

#### Debug/Development:
- `debug`, `test`, `mock`, `stub`, `fixture`, `example`
- `TODO`, `FIXME`, `HACK`, `NOTE`, `XXX`

#### File/Path:
- `assets/`, `lib/`, `test/`, `android/`, `ios/`
- `.dart`, `.arb`, `.json`, `.yaml`, `.yml`

#### Variables/Properties:
- `controller`, `key`, `value`, `data`, `response`, `request`
- `status`, `code`, `id`, `type`, `name`, `url`, `uri`, `path`, `file`

#### Error/Exception:
- `exception`, `error`, `failure`, `timeout`, `network`, `server`, `client`
- `unauthorized`, `forbidden`, `not_found`, `bad_request`, `internal_server_error`

#### Date/Time:
- `yyyy-MM-dd`, `HH:mm:ss`, `ISO`, `UTC`, `timestamp`, `date`, `time`, `datetime`

#### Currency/Number:
- `currency`, `amount`, `price`, `cost`, `total`, `sum`, `count`, `number`
- `decimal`, `integer`, `float`, `double`

#### UI/UX:
- `color`, `style`, `theme`, `font`, `size`, `width`, `height`
- `padding`, `margin`, `border`, `radius`, `shadow`, `gradient`, `opacity`

### Common User-Facing Words (Exceptions)
These words are excluded from technical patterns even if they appear in technical contexts:
- `email`, `password`, `name`, `phone`, `address`

### Dart Keywords (Avoided in Key Generation)
The script avoids using these Dart keywords as translation keys:
- `abstract`, `else`, `import`, `show`, `as`, `enum`, `in`, `super`
- `assert`, `export`, `interface`, `switch`, `async`, `extends`, `is`, `sync`
- `await`, `extension`, `library`, `this`, `break`, `external`, `mixin`
- `throw`, `case`, `factory`, `new`, `true`, `catch`, `false`, `null`
- `try`, `class`, `final`, `on`, `typedef`, `const`, `finally`, `operator`
- `var`, `continue`, `for`, `part`, `void`, `covariant`, `Function`
- `rethrow`, `while`, `default`, `get`, `return`, `with`, `deferred`
- `hide`, `set`, `yield`, `do`, `if`, `show`, `dynamic`, `implements`
- `static`, `else`, `import`, `super`

## Algorithm

### Phase 1: Initialization & Setup
1. **`__init__()`** - Initialize configuration:
   - Set ARB directory and base file paths
   - Define user-facing string patterns (labels, hints, Text widgets, etc.)
   - Define technical patterns to exclude (API endpoints, variables, etc.)
   - Define Dart keywords to avoid in key generation

### Phase 2: Codebase Scanning
2. **`scan_codebase()`** → **`find_user_facing_strings()`**:
   - Recursively find all `.dart` files in `lib/` directory
   - For each file, scan line by line for user-facing patterns
   - Extract strings using regex patterns for different widget types
   - Filter out technical strings using `is_technical_string()`
   - Generate unique keys using `generate_key_from_string()`
   - Store string locations with metadata

### Phase 3: String Analysis & Classification
3. **`separate_strings()`** → **`read_existing_translations()`**:
   - Read existing ARB file to get current translations
   - Compare found strings against existing translations
   - Separate into "new strings" (not in ARB) and "existing strings" (already translated)
   - Remove duplicates using set operations

### Phase 4: ARB File Management
4. **`add_strings_to_arb()`**:
   - Create backup of current ARB file
   - Read existing ARB JSON structure
   - For each new string:
     - Generate unique key using `generate_key_from_string()`
     - Ensure key uniqueness (add counter if needed)
     - Add string to ARB with auto-generated description
   - Write updated ARB file with proper JSON formatting

### Phase 5: Localization Generation
5. **`run_flutter_gen_l10n()`**:
   - Execute `flutter gen-l10n` command
   - Generate Dart translation files from ARB
   - Handle errors and provide feedback

### Phase 6: Code Replacement
6. **`replace_strings_in_files()`**:
   - Group strings by file to process efficiently
   - Sort replacements by line number (reverse order to avoid offset issues)
   - For each string location:
     - Read file line by line
     - Use regex to replace hardcoded strings with `context.translations.keyName`
     - Handle different widget types (Text, AppTextField, AppButton, etc.)
     - Write modified file back to disk

### Phase 7: Reporting & Cleanup
7. **`generate_report()`**:
   - Display comprehensive statistics
   - Show new vs existing strings
   - List string locations with context
   - Provide next steps for manual review

## Key Technical Methods

### String Detection:
- **`extract_string_from_text_widget()`** - Handles `Text('string')` patterns
- **`extract_string_from_property()`** - Handles `label: 'string'` patterns
- **`is_technical_string()`** - Filters out non-user-facing strings

### Key Generation:
- **`generate_key_from_string()`** - Creates valid Dart keys with hash-based uniqueness for long strings

### File Processing:
- **Regex-based string extraction** for different widget patterns
- **Line-by-line replacement** to maintain code structure
- **Backup creation** before modifications

## Success Criteria
1. ✅ All user-facing strings identified and categorized
2. ✅ New strings added to ARB file with unique keys
3. ✅ `flutter gen-l10n` executed successfully
4. ✅ Hardcoded strings replaced with `context.translations.keyName`
5. ✅ Comprehensive report generated
6. ✅ No technical strings accidentally included
7. ✅ Backup files created for safety

## Usage
```bash
python3 translate.py
```

## Output
The script provides:
- Colored terminal output with progress indicators
- Detailed statistics about strings found and processed
- List of new strings added to ARB
- List of existing strings found
- File-by-file replacement summary
- Next steps for manual review and testing

## Limitations
- Only processes `.dart` files in the `lib/` directory
- Requires existing ARB setup with `l10n.yaml` configuration
- May need manual review for complex string interpolation
- Backup files must be cleaned up manually or via `dart-format` script 