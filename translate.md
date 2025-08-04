# Translation Automation Script Documentation

## Overview
The `translate.py` script automates the internationalization process for Flutter/Dart codebases. It finds user-facing strings, adds them to ARB files, generates localization files, and replaces hardcoded strings with translation getters.

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