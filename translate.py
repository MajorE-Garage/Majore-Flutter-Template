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
    SELECTABLE_TEXT_WIDGET = "SelectableText widget"
    TOOLTIP_WIDGET = "Tooltip widget"
    BOTTOM_NAVIGATION_BAR_ITEM = "BottomNavigationBarItem widget"
    PLATFORM_MENU_ITEM = "PlatformMenuItem widget"
    CONTEXT_MENU_BUTTON_ITEM = "ContextMenuButtonItem widget"
    BUTTON_STYLE_BUTTON = "ButtonStyleButton widget"
    TITLE_WIDGET = "Title widget"
    WIDGETS_APP = "WidgetsApp widget"
    TEXT_SPAN = "TextSpan widget"
    LABEL = "Label"
    HINT = "Hint"
    HEADING = "Heading"
    BODY = "Body"
    TITLE = "Title"
    YES_LABEL = "Yes label"
    CANCEL_LABEL = "Cancel label"
    PREFIX_TEXT = "Prefix text"
    BUTTON_LABEL = "Button label"

class ExclusionReason(Enum):
    VARIABLE_INTERPOLATION = "Variable interpolation"
    STRING_CONCATENATION = "String concatenation"
    TECHNICAL_PATTERN = "Technical pattern"
    TOO_SHORT = "Too short"
    SPECIAL_CHARACTERS = "Special characters only"
    VARIABLE_NAME = "Variable name"
    CONSTANT_NAME = "Constant name"
    CODE_PATTERN = "Code pattern"
    COMMENT_STRING = "Comment string"
    GENERATED_FILE = "Generated file"

@dataclass
class StringLocation:
    string: str
    file_path: str
    line_number: int
    string_type: StringType
    context: str  # The line where the string was found
    key_name: str  # The generated ARB key for this string
    is_multiline: bool = False  # Track if this is a multi-line string
    end_line_number: Optional[int] = None  # End line for multi-line strings

@dataclass
class UnprocessedStringLocation:
    string: str
    file_path: str
    line_number: int
    context: str  # The line where the string was found
    reason: ExclusionReason
    is_multiline: bool = False
    end_line_number: Optional[int] = None

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
            
            # SelectableText widgets
            'SelectableText(': StringType.SELECTABLE_TEXT_WIDGET,
            
            # Tooltip widgets
            'Tooltip(': StringType.TOOLTIP_WIDGET,
            'message:': StringType.TOOLTIP_WIDGET,
            
            # BottomNavigationBarItem widgets
            'BottomNavigationBarItem(': StringType.BOTTOM_NAVIGATION_BAR_ITEM,
            'label:': StringType.LABEL,
            'tooltip:': StringType.TOOLTIP_WIDGET,
            
            # PlatformMenuItem widgets
            'PlatformMenuItem(': StringType.PLATFORM_MENU_ITEM,
            
            # ContextMenuButtonItem widgets
            'ContextMenuButtonItem(': StringType.CONTEXT_MENU_BUTTON_ITEM,
            
            # ButtonStyleButton widgets
            'ButtonStyleButton(': StringType.BUTTON_STYLE_BUTTON,
            
            # Title widgets
            'Title(': StringType.TITLE_WIDGET,
            'title:': StringType.TITLE,
            
            # WidgetsApp widgets
            'WidgetsApp(': StringType.WIDGETS_APP,
            
            # TextSpan widgets
            'TextSpan(': StringType.TEXT_SPAN,
            'text:': StringType.TEXT_SPAN,
            'semanticsLabel:': StringType.TEXT_SPAN,
            
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

    def is_technical_string(self, string: str) -> Optional[ExclusionReason]:
        """Check if a string is technical and should be excluded, returns exclusion reason"""
        # Exclude single letters (A, B, C, Y, etc.)
        if len(string) == 1 and string.isalpha():
            return ExclusionReason.TOO_SHORT
            
        # Exclude strings that are only numbers
        if string.isdigit():
            return ExclusionReason.TOO_SHORT
            
        # Exclude strings that contain only punctuation and special characters
        if re.match(r'^[0-9\s\-\_\.\,\!\@\#\$\%\^\&\*\(\)\[\]\{\}\|\:\;\'\"\<\>\?\/\\]+$', string):
            return ExclusionReason.SPECIAL_CHARACTERS
            
        # Check against technical patterns
        for pattern in self.technical_patterns:
            if pattern.lower() in string.lower():
                # Skip common user-facing words that happen to be in technical patterns
                exception_words = ['email', 'password', 'name', 'phone', 'address', 'type', 'text']
                if any(word in string.lower() for word in exception_words):
                    continue
                return ExclusionReason.TECHNICAL_PATTERN
                
        # Skip if string is a variable name (camelCase or snake_case)
        if re.match(r'^[a-z][a-zA-Z0-9]*$', string) or re.match(r'^[a-z][a-z0-9_]*$', string):
            return ExclusionReason.VARIABLE_NAME
            
        # Skip if string contains only uppercase (likely constants)
        if re.match(r'^[A-Z_]+$', string):
            return ExclusionReason.CONSTANT_NAME
            
        # Skip if string contains code patterns (but allow variable interpolation)
        if any(char in string for char in ['(', ')']) and not ('${' in string):
            # Debug: Check if this is a multi-line string being excluded
            if '\n' in string:
                self.print_colored(f"DEBUG: Multi-line string excluded as CODE_PATTERN: {string[:100]}...", Colors.YELLOW)
            return ExclusionReason.CODE_PATTERN
            
        # Note: We no longer exclude strings with variable interpolation ($)
        # as these are still user-facing strings that should be translated
        
        return None

    def is_string_concatenation(self, line: str) -> bool:
        """Check if line contains string concatenation"""
        # Patterns for string concatenation
        patterns = [
            r'[\'"][^\'"]*[\'"]\s*\+\s*[\'"][^\'"]*[\'"]',  # 'string' + 'string'
            r'[\'"][^\'"]*[\'"]\s*\+\s*[a-zA-Z_][a-zA-Z0-9_]*',  # 'string' + variable
            r'[a-zA-Z_][a-zA-Z0-9_]*\s*\+\s*[\'"][^\'"]*[\'"]',  # variable + 'string'
        ]
        
        for pattern in patterns:
            if re.search(pattern, line):
                return True
        return False

    def is_comment_line(self, line: str) -> bool:
        """Check if line is a comment"""
        stripped = line.strip()
        return stripped.startswith('//') or stripped.startswith('/*') or stripped.startswith('*')

    def is_generated_file(self, file_path: str) -> bool:
        """Check if file is generated"""
        generated_patterns = [
            'generated',
            'build/',
            '.g.dart',
            '.freezed.dart',
            '.mocks.dart',
        ]
        
        file_path_lower = file_path.lower()
        return any(pattern in file_path_lower for pattern in generated_patterns)

    def extract_string_from_text_widget(self, line: str) -> Optional[str]:
        """Extract full string from Text('string') or Text("string")"""
        # Find Text( and extract the string content - handle variable interpolation
        text_start = line.find('Text(')
        if text_start == -1:
            return None
            
        # Find the opening quote after Text(
        quote_start = line.find("'", text_start)
        if quote_start == -1:
            quote_start = line.find('"', text_start)
        
        if quote_start == -1:
            return None
            
        quote_char = line[quote_start]
        
        # Find the closing quote, accounting for escaped quotes and variable interpolation
        i = quote_start + 1
        while i < len(line):
            if line[i] == quote_char and line[i-1] != '\\':
                # Found the closing quote
                return line[quote_start + 1:i]
            i += 1
        
        return None

    def extract_string_from_selectable_text_widget(self, line: str) -> Optional[str]:
        """Extract full string from SelectableText('string') or SelectableText("string")"""
        # Find SelectableText( and extract the string content - handle variable interpolation
        selectable_start = line.find('SelectableText(')
        if selectable_start == -1:
            return None
            
        # Find the opening quote after SelectableText(
        quote_start = line.find("'", selectable_start)
        if quote_start == -1:
            quote_start = line.find('"', selectable_start)
        
        if quote_start == -1:
            return None
            
        quote_char = line[quote_start]
        
        # Find the closing quote, accounting for escaped quotes and variable interpolation
        i = quote_start + 1
        while i < len(line):
            if line[i] == quote_char and line[i-1] != '\\':
                # Found the closing quote
                return line[quote_start + 1:i]
            i += 1
        
        return None

    def extract_string_from_tooltip_widget(self, line: str) -> Optional[str]:
        """Extract full string from Tooltip(message: 'string') or Tooltip(message: "string")"""
        # Find Tooltip( and extract the message content - handle variable interpolation
        tooltip_start = line.find('Tooltip(')
        if tooltip_start == -1:
            return None
            
        message_start = line.find('message:', tooltip_start)
        if message_start == -1:
            return None
            
        # Find the opening quote after message:
        quote_start = line.find("'", message_start)
        if quote_start == -1:
            quote_start = line.find('"', message_start)
        
        if quote_start == -1:
            return None
            
        quote_char = line[quote_start]
        
        # Find the closing quote, accounting for escaped quotes and variable interpolation
        i = quote_start + 1
        while i < len(line):
            if line[i] == quote_char and line[i-1] != '\\':
                # Found the closing quote
                return line[quote_start + 1:i]
            i += 1
        
        return None

    def extract_string_from_bottom_navigation_bar_item(self, line: str) -> Optional[str]:
        """Extract full string from BottomNavigationBarItem(label: 'string') or BottomNavigationBarItem(tooltip: 'string')"""
        # Find BottomNavigationBarItem( and extract label or tooltip content
        label_match = re.search(r'BottomNavigationBarItem\(\s*label:\s*([\'"])(.*?)\1\s*[\),]', line)
        if label_match:
            return label_match.group(2)
        
        tooltip_match = re.search(r'BottomNavigationBarItem\(\s*tooltip:\s*([\'"])(.*?)\1\s*[\),]', line)
        if tooltip_match:
            return tooltip_match.group(2)
        return None

    def extract_string_from_platform_menu_item(self, line: str) -> Optional[str]:
        """Extract full string from PlatformMenuItem(label: 'string')"""
        # Find PlatformMenuItem( and extract the label content
        menu_match = re.search(r'PlatformMenuItem\(\s*label:\s*([\'"])(.*?)\1\s*[\),]', line)
        if menu_match:
            return menu_match.group(2)
        return None

    def extract_string_from_context_menu_button_item(self, line: str) -> Optional[str]:
        """Extract full string from ContextMenuButtonItem(label: 'string')"""
        # Find ContextMenuButtonItem( and extract the label content
        menu_match = re.search(r'ContextMenuButtonItem\(\s*label:\s*([\'"])(.*?)\1\s*[\),]', line)
        if menu_match:
            return menu_match.group(2)
        return None

    def extract_string_from_button_style_button(self, line: str) -> Optional[str]:
        """Extract full string from ButtonStyleButton(tooltip: 'string')"""
        # Find ButtonStyleButton( and extract the tooltip content
        button_match = re.search(r'ButtonStyleButton\(\s*tooltip:\s*([\'"])(.*?)\1\s*[\),]', line)
        if button_match:
            return button_match.group(2)
        return None

    def extract_string_from_title_widget(self, line: str) -> Optional[str]:
        """Extract full string from Title(title: 'string')"""
        # Find Title( and extract the title content
        title_match = re.search(r'Title\(\s*title:\s*([\'"])(.*?)\1\s*[\),]', line)
        if title_match:
            return title_match.group(2)
        return None

    def extract_string_from_widgets_app(self, line: str) -> Optional[str]:
        """Extract full string from WidgetsApp(title: 'string')"""
        # Find WidgetsApp( and extract the title content
        app_match = re.search(r'WidgetsApp\(\s*title:\s*([\'"])(.*?)\1\s*[\),]', line)
        if app_match:
            return app_match.group(2)
        return None

    def extract_string_from_text_span(self, line: str) -> Optional[str]:
        """Extract full string from TextSpan(text: 'string') or TextSpan(semanticsLabel: 'string')"""
        # Find TextSpan( and extract text or semanticsLabel content
        text_match = re.search(r'TextSpan\(\s*text:\s*([\'"])(.*?)\1\s*[\),]', line)
        if text_match:
            return text_match.group(2)
        
        semantics_match = re.search(r'TextSpan\(\s*semanticsLabel:\s*([\'"])(.*?)\1\s*[\),]', line)
        if semantics_match:
            return semantics_match.group(2)
        return None

    def extract_string_from_property(self, line: str, property_name: str) -> Optional[str]:
        """Extract full string from property: 'string' or property: 'string'"""
        # Find property: and extract the string content
        # Use a more flexible end anchor that handles various endings
        property_match = re.search(rf'{property_name}\s*:\s*([\'"])(.*?)\1\s*[,\]\)]', line)
        if property_match:
            return property_match.group(2)
        return None

    def is_multiline_string_start(self, line: str) -> bool:
        """Check if line starts a multi-line string"""
        # Check for triple-quote strings
        return "'''" in line or '"""' in line

    def get_multiline_delimiter(self, line: str) -> Optional[str]:
        """Get the delimiter type for multi-line strings"""
        if "'''" in line:
            return "'''"
        elif '"""' in line:
            return '"""'
        return None

    def extract_multiline_string(self, lines: List[str], start_line: int) -> Tuple[Optional[str], int]:
        """Extract multi-line string and return (content, end_line)"""
        if start_line >= len(lines):
            return None, start_line
        
        start_line_content = lines[start_line]
        delimiter = self.get_multiline_delimiter(start_line_content)
        
        if not delimiter:
            return None, start_line
        
        self.print_colored(f"DEBUG: Extracting multi-line string with delimiter '{delimiter}' from line: {start_line_content.strip()[:100]}...", Colors.CYAN)
        
        # Find the pattern that contains the delimiter
        patterns = [
            rf'Text\(\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}\s*\)',  # Text('''string''')
            rf'Text\(\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}\s*,',   # Text('''string''', params)
            rf'SelectableText\(\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}\s*\)',  # SelectableText('''string''')
            rf'SelectableText\(\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}\s*,',   # SelectableText('''string''', params)
            rf'message:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',     # message: '''string'''
            rf'label:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',       # label: '''string'''
            rf'hint:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',        # hint: '''string'''
            rf'heading:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',     # heading: '''string'''
            rf'body:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',        # body: '''string'''
            rf'title:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',       # title: '''string'''
            rf'yesLabel:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',    # yesLabel: '''string'''
            rf'cancelLabel:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',  # cancelLabel: '''string'''
            rf'prefixText:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',  # prefixText: '''string'''
        ]
        
        # Try to match on the start line first (single-line multi-line strings)
        for i, pattern in enumerate(patterns):
            match = re.search(pattern, start_line_content, re.DOTALL)
            if match:
                content = match.group(1).strip()
                self.print_colored(f"DEBUG: Matched pattern {i}: {content[:100]}...", Colors.GREEN)
                return content, start_line
        
        self.print_colored(f"DEBUG: No single-line pattern matched, trying multi-line extraction", Colors.YELLOW)
        
        # If not found on start line, look for multi-line strings that span multiple lines
        content_lines = []
        current_line = start_line
        
        # Extract content from start line (after opening delimiter)
        if delimiter in start_line_content:
            # Find the opening delimiter position
            start_pos = start_line_content.find(delimiter)
            if start_pos != -1:
                # Extract content after opening delimiter
                content_after_delimiter = start_line_content[start_pos + len(delimiter):]
                if delimiter in content_after_delimiter:
                    # String ends on same line
                    end_pos = content_after_delimiter.find(delimiter)
                    if end_pos != -1:
                        content = content_after_delimiter[:end_pos].strip()
                        self.print_colored(f"DEBUG: Found single-line multi-line string: {content[:100]}...", Colors.GREEN)
                        return content, start_line
                else:
                    # String continues on next lines
                    content_lines.append(content_after_delimiter)
                    self.print_colored(f"DEBUG: String continues on next lines, starting with: {content_after_delimiter[:50]}...", Colors.CYAN)
        
        # Continue reading until we find the closing delimiter
        current_line += 1
        while current_line < len(lines):
            line = lines[current_line]
            
            if delimiter in line:
                # Found closing delimiter
                end_pos = line.find(delimiter)
                if end_pos != -1:
                    # Add content before closing delimiter
                    content_before_delimiter = line[:end_pos]
                    content_lines.append(content_before_delimiter)
                    self.print_colored(f"DEBUG: Found closing delimiter at line {current_line + 1}", Colors.GREEN)
                    break
                else:
                    # Delimiter in middle of line, continue
                    content_lines.append(line)
            else:
                # No delimiter in this line, add the whole line
                content_lines.append(line)
            
            current_line += 1
        
        if content_lines:
            content = '\n'.join(content_lines).strip()
            self.print_colored(f"DEBUG: Successfully extracted multi-line string: {content[:100]}...", Colors.GREEN)
            return content, current_line
        
        self.print_colored(f"DEBUG: Failed to extract multi-line string", Colors.RED)
        return None, start_line

    def extract_string_from_text_widget_multiline(self, lines: List[str], start_line: int) -> Tuple[Optional[str], int]:
        """Extract multi-line string from Text widget"""
        if start_line >= len(lines):
            return None, start_line
        
        start_line_content = lines[start_line]
        
        # Check for triple-quote patterns in Text widgets
        triple_quote_patterns = [
            r'Text\(\s*[\'"]{3}(.*?)[\'"]{3}\s*\)',  # Text('''string''')
            r'Text\(\s*[\'"]{3}(.*?)[\'"]{3}\s*,',   # Text('''string''', params)
        ]
        
        for pattern in triple_quote_patterns:
            match = re.search(pattern, start_line_content, re.DOTALL)
            if match:
                content = match.group(1).strip()
                return content, start_line
        
        # If not found on single line, look for multi-line strings
        return self.extract_multiline_string(lines, start_line)

    def find_user_facing_strings(self, file_path: str) -> Tuple[List[StringLocation], List[UnprocessedStringLocation]]:
        """Find user-facing strings in a Dart file"""
        results = []
        unprocessed_results = []
        
        try:
            with open(file_path, 'r', encoding='utf-8') as f:
                lines = f.readlines()
            
            # Skip generated files
            if self.is_generated_file(file_path):
                return results, unprocessed_results
                
            i = 0
            while i < len(lines):
                line = lines[i]
                line_num = i + 1
                
                # Skip comment lines
                if self.is_comment_line(line):
                    i += 1
                    continue
                
                # Check for multi-line string start first
                if self.is_multiline_string_start(line):
                    self.print_colored(f"DEBUG: Found multi-line string start at line {line_num}: {line.strip()[:50]}...", Colors.CYAN)
                    # Try to extract multi-line string
                    extracted_string, end_line = self.extract_multiline_string(lines, i)
                    
                    if extracted_string:
                        self.print_colored(f"DEBUG: Extracted multi-line string: {extracted_string[:100]}...", Colors.GREEN)
                        # Check if it's technical
                        exclusion_reason = self.is_technical_string(extracted_string)
                        if exclusion_reason:
                            self.print_colored(f"DEBUG: Multi-line string excluded: {exclusion_reason}", Colors.YELLOW)
                            unprocessed_results.append(UnprocessedStringLocation(
                                string=extracted_string,
                                file_path=file_path,
                                line_number=line_num,
                                context=f"Lines {line_num}-{end_line + 1}",
                                reason=exclusion_reason,
                                is_multiline=True,
                                end_line_number=end_line + 1
                            ))
                        else:
                            self.print_colored(f"DEBUG: Multi-line string will be processed", Colors.GREEN)
                            # Determine string type based on context
                            string_type = self.determine_string_type_from_context(line)
                            
                            key_name = self.generate_key_from_string(extracted_string)
                            results.append(StringLocation(
                                string=extracted_string,
                                file_path=file_path,
                                line_number=line_num,
                                string_type=string_type,
                                context=f"Lines {line_num}-{end_line + 1}",
                                key_name=key_name,
                                is_multiline=True,
                                end_line_number=end_line + 1
                            ))
                    else:
                        self.print_colored(f"DEBUG: Failed to extract multi-line string from line {line_num}", Colors.RED)
                    
                    # Skip to end of multi-line string
                    i = end_line + 1
                    continue
                
                # Check for string concatenation
                if self.is_string_concatenation(line):
                    # Extract strings from concatenation for reporting
                    string_matches = re.findall(r'[\'"]([^\'"]*)[\'"]', line)
                    for match in string_matches:
                        if match.strip():
                            unprocessed_results.append(UnprocessedStringLocation(
                                string=match,
                                file_path=file_path,
                                line_number=line_num,
                                context=line.strip(),
                                reason=ExclusionReason.STRING_CONCATENATION
                            ))
                    i += 1
                    continue
                
                # Check each user-facing pattern for single-line strings
                for pattern, string_type in self.user_facing_patterns.items():
                    if pattern in line:
                        extracted_string = None
                        
                        if string_type == StringType.TEXT_WIDGET:
                            extracted_string = self.extract_string_from_text_widget(line)
                        elif string_type == StringType.SELECTABLE_TEXT_WIDGET:
                            extracted_string = self.extract_string_from_selectable_text_widget(line)
                        elif string_type == StringType.TOOLTIP_WIDGET:
                            extracted_string = self.extract_string_from_tooltip_widget(line)
                        elif string_type == StringType.BOTTOM_NAVIGATION_BAR_ITEM:
                            extracted_string = self.extract_string_from_bottom_navigation_bar_item(line)
                        elif string_type == StringType.PLATFORM_MENU_ITEM:
                            extracted_string = self.extract_string_from_platform_menu_item(line)
                        elif string_type == StringType.CONTEXT_MENU_BUTTON_ITEM:
                            extracted_string = self.extract_string_from_context_menu_button_item(line)
                        elif string_type == StringType.BUTTON_STYLE_BUTTON:
                            extracted_string = self.extract_string_from_button_style_button(line)
                        elif string_type == StringType.TITLE_WIDGET:
                            extracted_string = self.extract_string_from_title_widget(line)
                        elif string_type == StringType.WIDGETS_APP:
                            extracted_string = self.extract_string_from_widgets_app(line)
                        elif string_type == StringType.TEXT_SPAN:
                            extracted_string = self.extract_string_from_text_span(line)
                        else:
                            # Extract property name from pattern (remove ':')
                            property_name = pattern.rstrip(':')
                            extracted_string = self.extract_string_from_property(line, property_name)
                        
                        if extracted_string:
                            # Check if it's technical
                            exclusion_reason = self.is_technical_string(extracted_string)
                            
                            if exclusion_reason:
                                unprocessed_results.append(UnprocessedStringLocation(
                                    string=extracted_string,
                                    file_path=file_path,
                                    line_number=line_num,
                                    context=line.strip(),
                                    reason=exclusion_reason
                                ))
                            else:
                                key_name = self.generate_key_from_string(extracted_string)
                                results.append(StringLocation(
                                    string=extracted_string,
                                    file_path=file_path,
                                    line_number=line_num,
                                    string_type=string_type,
                                    context=line.strip(),
                                    key_name=key_name,
                                    is_multiline=False
                                ))
                
                i += 1
                            
        except Exception as e:
            self.print_colored(f"Error reading {file_path}: {e}", Colors.RED)
            
        return results, unprocessed_results

    def determine_string_type_from_context(self, line: str) -> StringType:
        """Determine string type from the context of the line"""
        if 'Text(' in line:
            return StringType.TEXT_WIDGET
        elif 'SelectableText(' in line:
            return StringType.SELECTABLE_TEXT_WIDGET
        elif 'Tooltip(' in line:
            return StringType.TOOLTIP_WIDGET
        elif 'BottomNavigationBarItem(' in line:
            return StringType.BOTTOM_NAVIGATION_BAR_ITEM
        elif 'PlatformMenuItem(' in line:
            return StringType.PLATFORM_MENU_ITEM
        elif 'ContextMenuButtonItem(' in line:
            return StringType.CONTEXT_MENU_BUTTON_ITEM
        elif 'ButtonStyleButton(' in line:
            return StringType.BUTTON_STYLE_BUTTON
        elif 'Title(' in line:
            return StringType.TITLE_WIDGET
        elif 'WidgetsApp(' in line:
            return StringType.WIDGETS_APP
        elif 'TextSpan(' in line:
            return StringType.TEXT_SPAN
        elif 'label:' in line:
            return StringType.LABEL
        elif 'hint:' in line:
            return StringType.HINT
        elif 'heading:' in line:
            return StringType.HEADING
        elif 'body:' in line:
            return StringType.BODY
        elif 'title:' in line:
            return StringType.TITLE
        elif 'yesLabel:' in line:
            return StringType.YES_LABEL
        elif 'cancelLabel:' in line:
            return StringType.CANCEL_LABEL
        elif 'prefixText:' in line:
            return StringType.PREFIX_TEXT
        else:
            return StringType.TEXT_WIDGET  # Default fallback

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

    def convert_dart_interpolation_to_arb(self, string: str) -> str:
        """Convert Dart string interpolation to ARB-compatible format"""
        # Convert ${"variable"} to {variable}
        # But don't convert literal braces like in 'try { } catch { }'
        import re
        
        # First, escape literal braces that are not part of interpolation
        # Pattern: ${"variable"} -> {variable}
        # But don't convert standalone braces like { } in 'try { } catch { }'
        
        # Replace ${"variable"} with {variable}
        result = re.sub(r'\$\{["\']([^"\']+)["\']\}', r'{\1}', string)
        
        # Escape any remaining standalone braces that are not part of interpolation
        # This handles cases like 'try { } catch { }'
        result = re.sub(r'(?<!\{)\{(?!\w)', r'{{', result)  # Escape opening brace
        result = re.sub(r'\}(?!\})', r'}}', result)  # Escape closing brace
        
        return result

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
            
        # Clean up any existing backup files
        backup_file = f"{self.base_arb_file}.backup"
        if os.path.exists(backup_file):
            try:
                os.remove(backup_file)
            except Exception as e:
                self.print_colored(f"Warning: Could not remove old backup: {e}", Colors.YELLOW)
        
        # Create backup only if we're actually going to modify the file
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
            
            # Convert Dart interpolation to ARB format
            arb_string = self.convert_dart_interpolation_to_arb(string)
            arb_data[key] = arb_string
            arb_data[f"@{key}"] = {
                "description": f"Auto-generated for: {string}"
            }
        
        # Write back to file
        try:
            with open(self.base_arb_file, 'w', encoding='utf-8') as f:
                json.dump(arb_data, f, indent=2, ensure_ascii=False)
            self.print_colored(f"✅ Added {len(new_strings)} new strings to {self.base_arb_file}", Colors.GREEN)
            
            # Clean up backup after successful write
            if os.path.exists(backup_file):
                try:
                    os.remove(backup_file)
                    self.print_colored(f"Cleaned up backup: {backup_file}", Colors.GREEN)
                except Exception as e:
                    self.print_colored(f"Warning: Could not remove backup: {e}", Colors.YELLOW)
                    
        except Exception as e:
            self.print_colored(f"Error writing ARB file: {e}", Colors.RED)
            # Restore from backup if write failed
            if os.path.exists(backup_file):
                try:
                    shutil.copy2(backup_file, self.base_arb_file)
                    self.print_colored(f"Restored from backup after error", Colors.YELLOW)
                except Exception as restore_error:
                    self.print_colored(f"Error restoring from backup: {restore_error}", Colors.RED)

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
                # Read the file once
                with open(file_path, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                
                # Sort by line number in reverse order to avoid line number shifts
                string_locations.sort(key=lambda x: x.line_number, reverse=True)
                
                file_modified = False
                for string_loc in string_locations:
                    # Create the replacement string
                    replacement = f"context.translations.{string_loc.key_name}"
                    
                    if string_loc.line_number <= len(lines):
                        if string_loc.is_multiline:
                            # Handle multi-line string replacement
                            self.print_colored(f"DEBUG: Processing multi-line string: {string_loc.string[:50]}...", Colors.CYAN)
                            if self.replace_multiline_string(lines, string_loc, replacement):
                                file_modified = True
                                total_replacements += 1
                                self.print_colored(f"DEBUG: Successfully replaced multi-line string", Colors.GREEN)
                            else:
                                self.print_colored(f"DEBUG: Failed to replace multi-line string", Colors.RED)
                        else:
                            # Handle single-line string replacement
                            line = lines[string_loc.line_number - 1]
                            original_line = line
                            
                            # Create a more robust replacement system
                            replacement_made = False
                            
                            # Handle different string types with more flexible patterns
                            if string_loc.string_type == StringType.TEXT_WIDGET:
                                # Replace in Text('string') or Text("string")
                                patterns = [
                                    rf'Text\(\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'Text\(\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'Text({replacement})', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.SELECTABLE_TEXT_WIDGET:
                                patterns = [
                                    rf'SelectableText\(\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'SelectableText\(\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'SelectableText({replacement})', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.TOOLTIP_WIDGET:
                                patterns = [
                                    rf'Tooltip\(\s*message:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'Tooltip\(\s*message:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'Tooltip(message: {replacement})', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.BOTTOM_NAVIGATION_BAR_ITEM:
                                patterns = [
                                    rf'BottomNavigationBarItem\(\s*label:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'BottomNavigationBarItem\(\s*label:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                    rf'BottomNavigationBarItem\(\s*tooltip:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'BottomNavigationBarItem\(\s*tooltip:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        if 'label:' in pattern:
                                            new_line = re.sub(pattern, f'BottomNavigationBarItem(label: {replacement})', line)
                                        else:
                                            new_line = re.sub(pattern, f'BottomNavigationBarItem(tooltip: {replacement})', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.PLATFORM_MENU_ITEM:
                                patterns = [
                                    rf'PlatformMenuItem\(\s*label:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'PlatformMenuItem\(\s*label:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'PlatformMenuItem(label: {replacement})', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.CONTEXT_MENU_BUTTON_ITEM:
                                patterns = [
                                    rf'ContextMenuButtonItem\(\s*label:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'ContextMenuButtonItem\(\s*label:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'ContextMenuButtonItem(label: {replacement})', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.BUTTON_STYLE_BUTTON:
                                patterns = [
                                    rf'ButtonStyleButton\(\s*tooltip:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'ButtonStyleButton\(\s*tooltip:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'ButtonStyleButton(tooltip: {replacement})', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.TITLE_WIDGET:
                                patterns = [
                                    rf'Title\(\s*title:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'Title\(\s*title:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'Title(title: {replacement})', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.WIDGETS_APP:
                                patterns = [
                                    rf'WidgetsApp\(\s*title:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'WidgetsApp\(\s*title:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'WidgetsApp(title: {replacement})', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.TEXT_SPAN:
                                patterns = [
                                    rf'TextSpan\(\s*text:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'TextSpan\(\s*text:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                    rf'TextSpan\(\s*semanticsLabel:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                    rf'TextSpan\(\s*semanticsLabel:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        if 'text:' in pattern:
                                            new_line = re.sub(pattern, f'TextSpan(text: {replacement})', line)
                                        else:
                                            new_line = re.sub(pattern, f'TextSpan(semanticsLabel: {replacement})', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.LABEL:
                                patterns = [
                                    rf'label:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                    rf'label:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'label: {replacement},', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.HINT:
                                patterns = [
                                    rf'hint:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                    rf'hint:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'hint: {replacement},', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.HEADING:
                                patterns = [
                                    rf'heading:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                    rf'heading:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'heading: {replacement},', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.BODY:
                                patterns = [
                                    rf'body:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                    rf'body:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'body: {replacement},', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.TITLE:
                                patterns = [
                                    rf'title:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                    rf'title:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'title: {replacement},', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.YES_LABEL:
                                patterns = [
                                    rf'yesLabel:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                    rf'yesLabel:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'yesLabel: {replacement},', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.CANCEL_LABEL:
                                patterns = [
                                    rf'cancelLabel:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                    rf'cancelLabel:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'cancelLabel: {replacement},', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.PREFIX_TEXT:
                                patterns = [
                                    rf'prefixText:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                    rf'prefixText:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'prefixText: {replacement},', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                                
                            elif string_loc.string_type == StringType.BUTTON_LABEL:
                                patterns = [
                                    rf'label:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*,',
                                    rf'label:\s*[\'"]({re.escape(string_loc.string)})[\'"]\s*\)',
                                ]
                                for pattern in patterns:
                                    if re.search(pattern, line):
                                        new_line = re.sub(pattern, f'label: {replacement},', line)
                                        if new_line != line:
                                            lines[string_loc.line_number - 1] = new_line
                                            replacement_made = True
                                            break
                            
                            if replacement_made:
                                file_modified = True
                                total_replacements += 1
                
                # Write the file back only once after all replacements
                if file_modified:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.writelines(lines)
                    self.print_colored(f"✅ Updated {file_path}", Colors.GREEN)
                    
            except Exception as e:
                self.print_colored(f"Error updating {file_path}: {e}", Colors.RED)
        
        return total_replacements

    def replace_multiline_string(self, lines: List[str], string_loc: StringLocation, replacement: str) -> bool:
        """Replace multi-line string with translation getter"""
        start_line = string_loc.line_number - 1
        end_line = string_loc.end_line_number - 1 if string_loc.end_line_number else start_line
        
        if start_line >= len(lines):
            return False
        
        start_line_content = lines[start_line]
        
        # Check for triple-quote patterns
        delimiter = self.get_multiline_delimiter(start_line_content)
        if not delimiter:
            return False
        
        # For multi-line strings that span multiple lines, we need to handle them differently
        if end_line > start_line:
            # Multi-line string spans multiple lines
            return self.replace_spanning_multiline_string(lines, string_loc, replacement, delimiter)
        else:
            # Multi-line string on single line
            return self.replace_single_line_multiline_string(lines, string_loc, replacement, delimiter)
    
    def replace_single_line_multiline_string(self, lines: List[str], string_loc: StringLocation, replacement: str, delimiter: str) -> bool:
        """Replace multi-line string that exists on a single line"""
        start_line = string_loc.line_number - 1
        start_line_content = lines[start_line]
        
        # Try to replace the entire multi-line string on the start line
        patterns = [
            rf'Text\(\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}\s*\)',  # Text('''string''')
            rf'Text\(\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}\s*,',   # Text('''string''', params)
            rf'label:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',       # label: '''string'''
            rf'hint:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',        # hint: '''string'''
            rf'heading:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',     # heading: '''string'''
            rf'body:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',        # body: '''string'''
            rf'title:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',       # title: '''string'''
            rf'yesLabel:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',    # yesLabel: '''string'''
            rf'cancelLabel:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',  # cancelLabel: '''string'''
            rf'prefixText:\s*{re.escape(delimiter)}(.*?){re.escape(delimiter)}',  # prefixText: '''string'''
        ]
        
        for pattern in patterns:
            match = re.search(pattern, start_line_content, re.DOTALL)
            if match:
                # Replace the entire pattern
                if 'Text(' in pattern:
                    # Keep the original structure for Text widgets
                    new_line = re.sub(pattern, f'Text({replacement})', start_line_content)
                else:
                    # For properties, replace with the property name
                    property_match = re.search(r'(\w+):\s*' + re.escape(delimiter), start_line_content)
                    if property_match:
                        property_name = property_match.group(1)
                        new_line = re.sub(pattern, f'{property_name}: {replacement}', start_line_content)
                    else:
                        new_line = re.sub(pattern, replacement, start_line_content)
                
                lines[start_line] = new_line
                return True
        
        return False
    
    def replace_spanning_multiline_string(self, lines: List[str], string_loc: StringLocation, replacement: str, delimiter: str) -> bool:
        """Replace multi-line string that spans multiple lines"""
        start_line = string_loc.line_number - 1
        end_line = string_loc.end_line_number - 1
        
        if start_line >= len(lines) or end_line >= len(lines):
            return False
        
        start_line_content = lines[start_line]
        
        # Find the opening delimiter position
        start_pos = start_line_content.find(delimiter)
        if start_pos == -1:
            return False
        
        # Check what type of widget/property this is
        widget_type = None
        property_name = None
        
        if 'Text(' in start_line_content:
            widget_type = 'Text'
        elif 'SelectableText(' in start_line_content:
            widget_type = 'SelectableText'
        elif 'Tooltip(' in start_line_content:
            widget_type = 'Tooltip'
        elif 'label:' in start_line_content:
            property_name = 'label'
        elif 'hint:' in start_line_content:
            property_name = 'hint'
        elif 'heading:' in start_line_content:
            property_name = 'heading'
        elif 'body:' in start_line_content:
            property_name = 'body'
        elif 'title:' in start_line_content:
            property_name = 'title'
        elif 'yesLabel:' in start_line_content:
            property_name = 'yesLabel'
        elif 'cancelLabel:' in start_line_content:
            property_name = 'cancelLabel'
        elif 'prefixText:' in start_line_content:
            property_name = 'prefixText'
        
        # Replace the start line
        before_delimiter = start_line_content[:start_pos]
        after_delimiter = start_line_content[start_pos + len(delimiter):]
        
        # Check if string ends on same line
        if delimiter in after_delimiter:
            end_pos = after_delimiter.find(delimiter)
            if end_pos != -1:
                # String ends on same line
                after_end = after_delimiter[end_pos + len(delimiter):]
                if widget_type:
                    new_line = f"{before_delimiter}{replacement}{after_end}"
                elif property_name:
                    new_line = f"{before_delimiter}{replacement}{after_end}"
                else:
                    new_line = f"{before_delimiter}{replacement}{after_end}"
                lines[start_line] = new_line
                return True
        
        # String spans multiple lines - replace the start line
        if widget_type:
            # For widgets like Text('''string'''), replace with Text(context.translations.key)
            new_line = f"{before_delimiter}{replacement})"
        elif property_name:
            # For properties like label: '''string''', replace with label: context.translations.key
            new_line = f"{before_delimiter}{replacement},"
        else:
            new_line = f"{before_delimiter}{replacement}"
        
        lines[start_line] = new_line
        
        # Clear intermediate lines (the multi-line string content)
        for i in range(start_line + 1, min(end_line + 1, len(lines))):
            lines[i] = ""
        
        return True

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

    def scan_codebase(self) -> Tuple[List[StringLocation], List[UnprocessedStringLocation], int]:
        """Scan the entire codebase for user-facing strings"""
        all_strings = []
        all_unprocessed_strings = []
        total_files = 0
        
        self.print_colored("🔍 Scanning for user-facing strings...", Colors.CYAN)
        print()
        
        # Find all Dart files
        lib_path = Path(self.lib_dir)
        dart_files = list(lib_path.rglob("*.dart"))
        
        for file_path in dart_files:
            total_files += 1
            # self.print_colored(f"📄 Processing: {file_path}", Colors.BLUE)
            
            # Skip generated files
            if self.is_generated_file(str(file_path)):
                self.print_colored(f"DEBUG: Skipping generated file: {file_path}", Colors.YELLOW)
                continue
            
            processed_strings, unprocessed_strings = self.find_user_facing_strings(str(file_path))
            if processed_strings or unprocessed_strings:
                self.print_colored(f"DEBUG: Found {len(processed_strings)} processed and {len(unprocessed_strings)} unprocessed strings in {file_path}", Colors.CYAN)
            all_strings.extend(processed_strings)
            all_unprocessed_strings.extend(unprocessed_strings)
        
        print()
        self.print_colored("✅ Scanning completed!", Colors.GREEN)
        print()
        
        return all_strings, all_unprocessed_strings, total_files

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

    def generate_unprocessed_report(self, unprocessed_strings: List[UnprocessedStringLocation]) -> None:
        """Generate a detailed report of strings that couldn't be processed automatically"""
        if not unprocessed_strings:
            return
        
        print("\n⚠️  Unprocessed Strings (Manual Review Required)")
        print("=" * 60)
        
        # Group strings by exclusion reason
        grouped_strings = {}
        for string_loc in unprocessed_strings:
            reason = string_loc.reason
            if reason not in grouped_strings:
                grouped_strings[reason] = []
            grouped_strings[reason].append(string_loc)
        
        # Categories that should NOT appear in the report (they are expected)
        excluded_from_report = {
            ExclusionReason.TECHNICAL_PATTERN,
            ExclusionReason.CODE_PATTERN,
            ExclusionReason.CONSTANT_NAME,
            ExclusionReason.VARIABLE_NAME,
            ExclusionReason.SPECIAL_CHARACTERS,
            ExclusionReason.COMMENT_STRING,
            ExclusionReason.GENERATED_FILE,
            # Variable interpolation strings should now be processed, not unprocessed
            ExclusionReason.VARIABLE_INTERPOLATION,
        }
        
        # Categories that should appear in the report (they might need manual attention)
        include_in_report = {
            ExclusionReason.STRING_CONCATENATION,
            ExclusionReason.TOO_SHORT,
        }
        
        # Filter strings to only show those that might need manual attention
        report_strings = []
        for string_loc in unprocessed_strings:
            if string_loc.reason in include_in_report:
                report_strings.append(string_loc)
        
        if not report_strings:
            print("✅ All unprocessed strings are expected (technical patterns, etc.)")
            return
        
        # Group the filtered strings
        grouped_report_strings = {}
        for string_loc in report_strings:
            reason = string_loc.reason
            if reason not in grouped_report_strings:
                grouped_report_strings[reason] = []
            grouped_report_strings[reason].append(string_loc)
        
        # Generate the report
        for reason, strings in grouped_report_strings.items():
            reason_name = reason.value.replace('_', ' ').title()
            print(f"\n🔍 {reason_name}:")
            
            for string_loc in strings:
                # Get first 5 words for preview
                words = string_loc.string.split()[:5]
                preview = ' '.join(words)
                if len(string_loc.string.split()) > 5:
                    preview += "..."
                
                # Create clickable file path
                file_path = string_loc.file_path
                line_info = f"{string_loc.line_number}"
                if string_loc.is_multiline:
                    line_info = f"{string_loc.line_number}-{string_loc.end_line_number}"
                
                print(f"  • \"{preview}\"")
                print(f"    📁 {file_path}:{line_info}")
        
        print("\n💡 Manual Actions Required:")
        print("  • Review each unprocessed string")
        print("  • Decide if it should be translated")
        print("  • Add to ARB file manually if needed")
        print("  • Replace with context.translations.keyName")

    def generate_report(self, all_strings: List[StringLocation], all_unprocessed_strings: List[UnprocessedStringLocation], total_files: int, 
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
        print(f"  ⚠️  Unprocessed strings: {len(all_unprocessed_strings)}")
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
        
        # Generate unprocessed report
        self.generate_unprocessed_report(all_unprocessed_strings)

    def fix_existing_arb_strings(self) -> None:
        """Fix existing ARB strings that have Dart interpolation syntax"""
        if not os.path.exists(self.base_arb_file):
            return
            
        try:
            with open(self.base_arb_file, 'r', encoding='utf-8') as f:
                arb_data = json.load(f)
            
            modified = False
            for key, value in arb_data.items():
                if not key.startswith('@') and isinstance(value, str):
                    # Check if the string contains Dart interpolation
                    if '${' in value and '}' in value:
                        converted = self.convert_dart_interpolation_to_arb(value)
                        if converted != value:
                            arb_data[key] = converted
                            modified = True
                            self.print_colored(f"Fixed ARB string: {key}", Colors.YELLOW)
            
            if modified:
                with open(self.base_arb_file, 'w', encoding='utf-8') as f:
                    json.dump(arb_data, f, indent=2, ensure_ascii=False)
                self.print_colored("✅ Fixed existing ARB strings with Dart interpolation", Colors.GREEN)
                
        except Exception as e:
            self.print_colored(f"Error fixing ARB strings: {e}", Colors.RED)

    def run(self) -> None:
        """Main execution method"""
        self.print_colored("🚀 Automated Translation Script", Colors.BLUE)
        print("==================================")
        print()
        
        # Step 1: Scan codebase
        all_strings, all_unprocessed_strings, total_files = self.scan_codebase()
        
        # Step 2: Separate new and existing strings
        new_strings, existing_strings = self.separate_strings(all_strings)
        
        # Step 3: Add new strings to ARB file
        self.print_colored("📝 Adding new strings to translations...", Colors.CYAN)
        self.add_strings_to_arb(new_strings)
        
        # Step 4.5: Fix existing ARB strings with Dart interpolation
        self.print_colored("🔧 Fixing existing ARB strings with Dart interpolation...", Colors.CYAN)
        self.fix_existing_arb_strings()
        
        # Step 5: Generate localization files
        self.print_colored("🔄 Generating localization files...", Colors.CYAN)
        if new_strings or all_strings:  # Run if there are new strings OR any string replacements
            success = self.run_flutter_gen_l10n()
            if not success:
                self.print_colored("⚠️  Localization generation failed", Colors.YELLOW)
        else:
            self.print_colored("ℹ️  Skipping localization generation (no strings found)", Colors.YELLOW)
        
        # Step 6: Replace strings in code
        self.print_colored("🔄 Replacing strings in code...", Colors.CYAN)
        total_replacements = self.replace_strings_in_files(all_strings)
        
        # Step 7: Generate report
        self.generate_report(all_strings, all_unprocessed_strings, total_files, new_strings, existing_strings, total_replacements)
        
        # Step 8: Add TODO comments for user-facing strings that couldn't be processed
        self.print_colored("📝 Adding TODO comments for unprocessed user-facing strings...", Colors.CYAN)
        self.add_todo_comments_for_unprocessed_strings(all_unprocessed_strings)
        
        # Step 9: Final message
        self.print_colored("🎉 Translation process completed!", Colors.GREEN)
        print()
        self.print_colored("💡 Next steps:", Colors.YELLOW)
        print("  1. Review the generated translations")
        print("  2. Add translations for other languages (Swahili, French, Arabic)")
        print("  3. Test the application to ensure translations work correctly")
        print("  4. Commit the changes to version control")
        print()

    def add_todo_comments_for_unprocessed_strings(self, unprocessed_strings: List[UnprocessedStringLocation]) -> None:
        """Add Flutter-style TODO comments for user-facing strings that couldn't be processed"""
        # Categories that might be user-facing and need TODO comments
        user_facing_categories = {
            ExclusionReason.STRING_CONCATENATION,
            ExclusionReason.TOO_SHORT,
        }
        
        # Group strings by file to avoid multiple file operations
        files_to_update = {}
        for string_loc in unprocessed_strings:
            if string_loc.reason in user_facing_categories:
                # Skip numbers-only strings from TODO comments
                if string_loc.reason == ExclusionReason.TOO_SHORT and string_loc.string.isdigit():
                    continue
                    
                if string_loc.file_path not in files_to_update:
                    files_to_update[string_loc.file_path] = []
                files_to_update[string_loc.file_path].append(string_loc)
        
        for file_path, strings in files_to_update.items():
            try:
                with open(file_path, 'r', encoding='utf-8') as f:
                    lines = f.readlines()
                
                # Sort strings by line number in reverse order to avoid offset issues
                strings.sort(key=lambda x: x.line_number, reverse=True)
                
                modified = False
                for string_loc in strings:
                    line_index = string_loc.line_number - 1  # Convert to 0-based index
                    
                    if line_index < len(lines):
                        original_line = lines[line_index]
                        
                        # Check if TODO comment already exists before this line
                        todo_already_exists = False
                        if line_index > 0:
                            previous_line = lines[line_index - 1].strip()
                            if previous_line.startswith('// TODO(translation):'):
                                todo_already_exists = True
                        
                        if not todo_already_exists:
                            # Create TODO comment
                            todo_comment = f"// TODO(translation): Translate this string: '{string_loc.string}'\n"
                            
                            # Insert TODO comment before the line
                            lines.insert(line_index, todo_comment)
                            modified = True
                
                if modified:
                    with open(file_path, 'w', encoding='utf-8') as f:
                        f.writelines(lines)
                    
                    self.print_colored(f"✅ Added TODO comments to {file_path}", Colors.GREEN)
                    
            except Exception as e:
                self.print_colored(f"❌ Error adding TODO comments to {file_path}: {e}", Colors.RED)

def main():
    """Main entry point"""
    script = TranslationScript()
    script.run()

if __name__ == "__main__":
    main() 