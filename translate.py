#!/usr/bin/env python3
"""
Automated Translation Script for Flutter/Dart Codebase
This script finds user-facing strings and automatically adds them to ARB files
"""

import os
import re
import json
import subprocess
import sys
from pathlib import Path
from typing import List, Dict, Tuple, Set, Optional
from dataclasses import dataclass
from enum import Enum

# Colors for output
class Colors:
    RED = '\033[0;31m'
    GREEN = '\033[0;32m'
    YELLOW = '\033[1;33m'
    BLUE = '\033[0;34m'
    PURPLE = '\033[0;35m'
    CYAN = '\033[0;36m'
    NC = '\033[0m'  # No Color

class StringType(Enum):
    TEXT_WIDGET = "Text widget"
    LABEL = "Label"
    HINT = "Hint"
    HEADING = "Heading"
    BODY = "Body"
    TITLE = "Title"
    YES_LABEL = "Yes label"
    CANCEL_LABEL = "Cancel label"
    PREFIX_TEXT = "Prefix text"
    BUTTON_LABEL = "Button label"

@dataclass
class StringLocation:
    string: str
    file_path: str
    line_number: int
    string_type: StringType
    context: str  # The line where the string was found
    key_name: str  # The generated ARB key for this string

class TranslationScript:
    def __init__(self):
        self.arb_dir = "lib/l10n/arbs"
        self.base_arb_file = f"{self.arb_dir}/app_en.arb"
        self.lib_dir = "lib"
        self.temp_file = "temp_translation_work.json"
        
        # User-facing string patterns based on your codebase
        self.user_facing_patterns = {
            # AppTextField patterns
            'label:': StringType.LABEL,
            'hint:': StringType.HINT,
            'prefixText:': StringType.PREFIX_TEXT,
            
            # AppButton patterns
            'label:': StringType.BUTTON_LABEL,
            
            # AppConfirmationDialog patterns
            'heading:': StringType.HEADING,
            'body:': StringType.BODY,
            'yesLabel:': StringType.YES_LABEL,
            'cancelLabel:': StringType.CANCEL_LABEL,
            
            # AppDialog patterns
            'heading:': StringType.HEADING,
            
            # AppDatePicker patterns
            'title:': StringType.TITLE,
            
            # AppSearchField patterns
            'hint:': StringType.HINT,
            
            # Direct Text widgets
            'Text(': StringType.TEXT_WIDGET,
            
            # Error messages
            'error:': StringType.LABEL,
            'message:': StringType.LABEL,
        }
        
        # Technical string patterns to exclude
        self.technical_patterns = [
            # API/Network patterns
            'http://', 'https://', 'api/', 'endpoint', 'token', 'bearer', 'authorization',
            
            # JSON/Serialization patterns
            'toMap', 'fromMap', 'json', 'serialization', 'deserialization',
            
            # Flutter/Dart technical patterns
            'dart:', 'package:', 'import', 'export', 'class', 'enum', 'typedef',
            'const', 'final', 'var', 'String', 'int', 'bool', 'double', 'List', 'Map',
            'Widget', 'BuildContext', 'MaterialApp', 'Scaffold', 'Container', 'Column',
            'Row', 'Text', 'Button', 'AppBar', 'ListView',
            
            # Debug/Development patterns
            'debug', 'test', 'mock', 'stub', 'fixture', 'example', 'TODO', 'FIXME', 'HACK', 'NOTE', 'XXX',
            
            # File/Path patterns
            'assets/', 'lib/', 'test/', 'android/', 'ios/', '.dart', '.arb', '.json', '.yaml', '.yml',
            
            # Variable/Property patterns
            'controller', 'key', 'value', 'data', 'response', 'request', 'status', 'code', 'id',
            'type', 'name', 'email', 'password', 'phone', 'address', 'url', 'uri', 'path', 'file',
            'folder', 'directory',
            
            # Error/Exception patterns
            'exception', 'error', 'failure', 'timeout', 'network', 'server', 'client',
            'unauthorized', 'forbidden', 'not_found', 'bad_request', 'internal_server_error',
            
            # Date/Time patterns
            'yyyy-MM-dd', 'HH:mm:ss', 'ISO', 'UTC', 'timestamp', 'date', 'time', 'datetime',
            
            # Currency/Number patterns
            'currency', 'amount', 'price', 'cost', 'total', 'sum', 'count', 'number',
            'decimal', 'integer', 'float', 'double',
            
            # UI/UX patterns
            'color', 'style', 'theme', 'font', 'size', 'width', 'height', 'padding',
            'margin', 'border', 'radius', 'shadow', 'gradient', 'opacity', 'alpha', 'rgb', 'hex',
        ]
        
        # Dart keywords to avoid in key generation
        self.dart_keywords = {
            'abstract', 'else', 'import', 'show', 'as', 'enum', 'in', 'super', 'assert', 'export',
            'interface', 'switch', 'async', 'extends', 'is', 'sync', 'await', 'extension', 'library',
            'this', 'break', 'external', 'mixin', 'throw', 'case', 'factory', 'new', 'true', 'catch',
            'false', 'null', 'try', 'class', 'final', 'on', 'typedef', 'const', 'finally', 'operator',
            'var', 'continue', 'for', 'part', 'void', 'covariant', 'Function', 'rethrow', 'while',
            'default', 'get', 'return', 'with', 'deferred', 'hide', 'set', 'yield', 'do', 'if',
            'show', 'dynamic', 'implements', 'static', 'else', 'import', 'super'
        }

    def print_colored(self, message: str, color: str = Colors.NC):
        """Print a colored message"""
        print(f"{color}{message}{Colors.NC}")

    def is_technical_string(self, string: str) -> bool:
        """Check if a string is technical and should be excluded"""
        if len(string) < 3:
            return True
            
        # Skip if string contains only special characters or numbers
        if re.match(r'^[0-9\s\-\_\.\,\!\@\#\$\%\^\&\*\(\)\[\]\{\}\|\:\;\'\"\<\>\?\/\\]+$', string):
            return True
            
        # Check against technical patterns
        for pattern in self.technical_patterns:
            if pattern.lower() in string.lower():
                # Skip common user-facing words that happen to be in technical patterns
                if string.lower() in ['email', 'password', 'name', 'phone', 'address']:
                    continue
                return True
                
        # Skip if string is a variable name (camelCase or snake_case)
        if re.match(r'^[a-z][a-zA-Z0-9]*$', string) or re.match(r'^[a-z][a-z0-9_]*$', string):
            return True
            
        # Skip if string contains only uppercase (likely constants)
        if re.match(r'^[A-Z_]+$', string):
            return True
            
        # Skip if string contains code patterns
        if any(char in string for char in ['(', ')', '{', '}']):
            return True
            
        # Skip if string contains variable interpolation
        if '$' in string:
            return True
            
        return False

    def extract_string_from_text_widget(self, line: str) -> Optional[str]:
        """Extract full string from Text('string') or Text("string")"""
        # Match Text('string') or Text("string") - capture the full string
        patterns = [
            r'Text\(\s*[\'"]([^\'"]*)[\'"]\s*\)',  # Text('string') or Text("string")
            r'Text\(\s*[\'"]([^\'"]*)[\'"]\s*,',   # Text('string', other params
        ]
        
        for pattern in patterns:
            match = re.search(pattern, line)
            if match:
                return match.group(1)
        return None

    def extract_string_from_property(self, line: str, property_name: str) -> Optional[str]:
        """Extract full string from property: 'string' or property: 'string'"""
        # Match property: 'string' or property: "string" - capture the full string
        patterns = [
            rf'{property_name}\s*:\s*[\'"]([^\'"]*)[\'"]',  # property: 'string'
            rf'{property_name}\s*:\s*[\'"]([^\'"]*)[\'"]\s*,',  # property: 'string',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, line)
            if match:
                return match.group(1)
        return None

    def find_user_facing_strings(self, file_path: str) -> List[StringLocation]:
        """Find user-facing strings in a Dart file"""
        results = []
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
                
            for line_num, line in enumerate(lines, 1):
                # Check each user-facing pattern
                for pattern, string_type in self.user_facing_patterns.items():
                    if pattern in line:
                        extracted_string = None
                        
                        if string_type == StringType.TEXT_WIDGET:
                            extracted_string = self.extract_string_from_text_widget(line)
                        else:
                            # Extract property name from pattern (remove ':')
                            property_name = pattern.rstrip(':')
                            extracted_string = self.extract_string_from_property(line, property_name)
                        
                        if extracted_string and not self.is_technical_string(extracted_string):
                            key_name = self.generate_key_from_string(extracted_string)
                            results.append(StringLocation(
                                string=extracted_string,
                                file_path=file_path,
                                line_number=line_num,
                                string_type=string_type,
                                context=line.strip(),
                                key_name=key_name
                            ))
                            
        except Exception as e:
            self.print_colored(f"Error reading {file_path}: {e}", Colors.RED)
            
        return results

    def generate_key_from_string(self, string: str) -> str:
        """Generate a valid Dart key from a string with guaranteed uniqueness"""
        
        # Clean the string
        cleaned = re.sub(r'[^a-zA-Z0-9\s]', '', string)
        words = cleaned.lower().split()
        
        # For very long strings, use smart truncation + hash
        if len(words) > 8:
            # Take first 3 words + last meaningful word
            key_words = words[:3]
            if len(words) > 4:
                # Find last meaningful word (not common words)
                common_words = {'the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by'}
                for word in reversed(words[3:]):
                    if word not in common_words and len(word) > 2:
                        key_words.append(word)
                        break
            
            base_key = '_'.join(key_words)
            
            # Add hash to ensure uniqueness for similar sentences
            import hashlib
            hash_object = hashlib.md5(string.encode())
            hash_suffix = hash_object.hexdigest()[:6]  # 6 chars for readability
            key = f"{base_key}_{hash_suffix}"
            
        else:
            # Use all words for shorter strings
            key = '_'.join(words)
        
        # Ensure it doesn't start with a number
        if key and key[0].isdigit():
            key = f"key_{key}"
            
        # Ensure it's not a Dart keyword
        if key in self.dart_keywords:
            key = f"{key}_text"
            
        # Ensure it's not empty
        if not key:
            key = "unknown_string"
            
        return key

    def read_existing_translations(self) -> Dict[str, str]:
        """Read existing translations from base ARB file"""
        existing_translations = {}
        
        if os.path.exists(self.base_arb_file):
            try:
                with open(self.base_arb_file, 'r', encoding='utf-8') as f:
                    arb_data = json.load(f)
                    
                # Extract all string values and their keys
                for key, value in arb_data.items():
                    if not key.startswith('@') and not key.startswith('@@'):
                        if isinstance(value, str):
                            existing_translations[value] = key
                            
            except Exception as e:
                self.print_colored(f"Error reading ARB file: {e}", Colors.RED)
                
        return existing_translations

    def add_strings_to_arb(self, new_strings: List[str]) -> None:
        """Add new strings to the base ARB file"""
        if not new_strings:
            return
            
        # Create backup
        backup_file = f"{self.base_arb_file}.backup"
        if os.path.exists(self.base_arb_file):
            import shutil
            shutil.copy2(self.base_arb_file, backup_file)
            self.print_colored(f"Created backup: {backup_file}", Colors.YELLOW)
        
        # Read current ARB content
        arb_data = {}
        if os.path.exists(self.base_arb_file):
            try:
                with open(self.base_arb_file, 'r', encoding='utf-8') as f:
                    arb_data = json.load(f)
            except Exception as e:
                self.print_colored(f"Error reading ARB file: {e}", Colors.RED)
                return
        
        # Add new strings
        for string in new_strings:
            key = self.generate_key_from_string(string)
            
            # Ensure key is unique
            counter = 1
            original_key = key
            while key in arb_data:
                key = f"{original_key}_{counter}"
                counter += 1
            
            arb_data[key] = string
            arb_data[f"@{key}"] = {
                "description": f"Auto-generated for: {string}"
            }
        
        # Write back to file
        try:
            with open(self.base_arb_file, 'w', encoding='utf-8') as f:
                json.dump(arb_data, f, indent=2, ensure_ascii=False)
            self.print_colored(f"✅ Added {len(new_strings)} new strings to {self.base_arb_file}", Colors.GREEN)
        except Exception as e:
            self.print_colored(f"Error writing ARB file: {e}", Colors.RED)

    def replace_strings_in_files(self, all_strings: List[StringLocation]) -> int:
        """Replace hardcoded strings with translation getters"""
        total_replacements = 0
        
        # Group strings by file
        files_to_update = {}
        for string_loc in all_strings:
            if string_loc.file_path not in files_to_update:
                files_to_update[string_loc.file_path] = []
            files_to_update[string_loc.file_path].append(string_loc)
        
        # Process each file
        for file_path, string_locations in files_to_update.items():
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    content = f.read()
                
                # Sort by line number in reverse order to avoid line number shifts
                string_locations.sort(key=lambda x: x.line_number, reverse=True)
                
                file_modified = False
                for string_loc in string_locations:
                    # Create the replacement string
                    replacement = f"context.translations.{string_loc.key_name}"
                    
                    # Read the file line by line to make precise replacements
                    with open(file_path, 'r', encoding='utf-8') as f:
                        lines = f.readlines()
                    
                    if string_loc.line_number <= len(lines):
                        line = lines[string_loc.line_number - 1]
                        
                        # Replace the string in the line
                        if string_loc.string_type == StringType.TEXT_WIDGET:
                            # Replace in Text('string') or Text("string")
                            new_line = re.sub(
                                r'Text\(\s*[\'"]([^\'"]*)[\'"]\s*\)',
                                f'Text({replacement})',
                                line
                            )
                            new_line = re.sub(
                                r'Text\(\s*[\'"]([^\'"]*)[\'"]\s*,',
                                f'Text({replacement},',
                                new_line
                            )
                        else:
                            # Replace in property assignments
                            property_name = string_loc.string_type.value.lower().replace(' ', '_')
                            if string_loc.string_type == StringType.LABEL:
                                property_name = 'label'
                            elif string_loc.string_type == StringType.HINT:
                                property_name = 'hint'
                            elif string_loc.string_type == StringType.HEADING:
                                property_name = 'heading'
                            elif string_loc.string_type == StringType.BODY:
                                property_name = 'body'
                            elif string_loc.string_type == StringType.YES_LABEL:
                                property_name = 'yesLabel'
                            elif string_loc.string_type == StringType.CANCEL_LABEL:
                                property_name = 'cancelLabel'
                            elif string_loc.string_type == StringType.TITLE:
                                property_name = 'title'
                            elif string_loc.string_type == StringType.PREFIX_TEXT:
                                property_name = 'prefixText'
                            elif string_loc.string_type == StringType.BUTTON_LABEL:
                                property_name = 'label'
                            
                            # Replace the specific property
                            pattern = rf'{property_name}\s*:\s*[\'"]([^\'"]*)[\'"]'
                            new_line = re.sub(pattern, f'{property_name}: {replacement}', line)
                            pattern = rf'{property_name}\s*:\s*[\'"]([^\'"]*)[\'"]\s*,'
                            new_line = re.sub(pattern, f'{property_name}: {replacement},', new_line)
                        
                        if new_line != line:
                            lines[string_loc.line_number - 1] = new_line
                            file_modified = True
                            total_replacements += 1
                
                # Write back to file if modified
                if file_modified:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.writelines(lines)
                    self.print_colored(f"✅ Updated {file_path}", Colors.GREEN)
                    
            except Exception as e:
                self.print_colored(f"Error updating {file_path}: {e}", Colors.RED)
        
        return total_replacements

    def run_flutter_gen_l10n(self) -> bool:
        """Run flutter gen-l10n command"""
        try:
            self.print_colored("🔄 Generating localization files...", Colors.CYAN)
            result = subprocess.run(['flutter', 'gen-l10n'], 
                                 capture_output=True, text=True, check=True)
            self.print_colored("✅ Localization files generated!", Colors.GREEN)
            return True
        except subprocess.CalledProcessError as e:
            self.print_colored(f"❌ Error generating localization files: {e}", Colors.RED)
            if e.stdout:
                self.print_colored(f"stdout: {e.stdout}", Colors.YELLOW)
            if e.stderr:
                self.print_colored(f"stderr: {e.stderr}", Colors.YELLOW)
            return False

    def scan_codebase(self) -> Tuple[List[StringLocation], int]:
        """Scan the entire codebase for user-facing strings"""
        all_strings = []
        total_files = 0
        
        self.print_colored("🔍 Scanning for user-facing strings...", Colors.CYAN)
        print()
        
        # Find all Dart files
        lib_path = Path(self.lib_dir)
        dart_files = list(lib_path.rglob("*.dart"))
        
        for file_path in dart_files:
            total_files += 1
            self.print_colored(f"📄 Processing: {file_path}", Colors.BLUE)
            
            file_strings = self.find_user_facing_strings(str(file_path))
            all_strings.extend(file_strings)
        
        print()
        self.print_colored("✅ Scanning completed!", Colors.GREEN)
        print()
        
        return all_strings, total_files

    def separate_strings(self, all_strings: List[StringLocation]) -> Tuple[List[str], List[str]]:
        """Separate new and existing strings"""
        self.print_colored("📋 Analyzing existing translations...", Colors.CYAN)
        
        existing_translations = self.read_existing_translations()
        new_strings = []
        existing_strings = []
        
        # Use set to avoid duplicates
        seen_strings = set()
        
        for string_loc in all_strings:
            if string_loc.string not in seen_strings:
                seen_strings.add(string_loc.string)
                
                if string_loc.string in existing_translations:
                    existing_strings.append(string_loc.string)
                else:
                    new_strings.append(string_loc.string)
        
        return new_strings, existing_strings

    def generate_report(self, all_strings: List[StringLocation], total_files: int, 
                       new_strings: List[str], existing_strings: List[str], 
                       total_replacements: int) -> None:
        """Generate a comprehensive report"""
        print()
        self.print_colored("📊 Translation Report", Colors.BLUE)
        print("======================")
        print()
        self.print_colored("✅ Summary:", Colors.GREEN)
        print(f"  📄 Total files scanned: {total_files}")
        print(f"  📄 Files with strings: {len(set(sl.file_path for sl in all_strings))}")
        print(f"  🆕 New strings added: {len(new_strings)}")
        print(f"  🔄 Existing strings found: {len(existing_strings)}")
        print(f"  📝 Total unique strings: {len(set(sl.string for sl in all_strings))}")
        print(f"  🔄 Total occurrences replaced: {total_replacements}")
        print()
        
        if new_strings:
            self.print_colored("🆕 New strings added:", Colors.YELLOW)
            for string in new_strings:
                print(f"  • {string}")
            print()
        
        if existing_strings:
            self.print_colored("🔄 Existing strings found:", Colors.BLUE)
            for string in existing_strings:
                print(f"  • {string}")
            print()
        
        # Show string locations
        if all_strings:
            self.print_colored("📍 String locations:", Colors.PURPLE)
            for string_loc in all_strings:
                print(f"  • {string_loc.string}")
                print(f"    File: {string_loc.file_path}:{string_loc.line_number}")
                print(f"    Type: {string_loc.string_type.value}")
                print(f"    Key: {string_loc.key_name}")
                print(f"    Context: {string_loc.context}")
                print()

    def run(self) -> None:
        """Main execution method"""
        self.print_colored("🚀 Automated Translation Script", Colors.BLUE)
        print("==================================")
        print()
        
        # Step 1: Scan codebase
        all_strings, total_files = self.scan_codebase()
        
        # Step 2: Separate new and existing strings
        new_strings, existing_strings = self.separate_strings(all_strings)
        
        # Step 3: Add new strings to ARB file
        self.print_colored("📝 Adding new strings to translations...", Colors.CYAN)
        if new_strings:
            self.add_strings_to_arb(new_strings)
        else:
            self.print_colored("ℹ️  No new strings to add", Colors.YELLOW)
        
        # Step 4: Run flutter gen-l10n
        if new_strings or all_strings:  # Run if there are new strings OR any string replacements
            success = self.run_flutter_gen_l10n()
            if not success:
                self.print_colored("⚠️  Localization generation failed", Colors.YELLOW)
        else:
            self.print_colored("ℹ️  Skipping localization generation (no strings found)", Colors.YELLOW)
        
        # Step 5: Replace strings in code
        self.print_colored("🔄 Replacing strings in code...", Colors.CYAN)
        total_replacements = self.replace_strings_in_files(all_strings)
        
        # Step 6: Generate report
        self.generate_report(all_strings, total_files, new_strings, existing_strings, total_replacements)
        
        # Step 7: Final message
        self.print_colored("🎉 Translation process completed!", Colors.GREEN)
        print()
        self.print_colored("💡 Next steps:", Colors.YELLOW)
        print("  1. Review the generated translations")
        print("  2. Add translations for other languages (Swahili, French, Arabic)")
        print("  3. Test the application to ensure translations work correctly")
        print("  4. Commit the changes to version control")
        print()

def main():
    """Main entry point"""
    script = TranslationScript()
    script.run()

if __name__ == "__main__":
    main() 