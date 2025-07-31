// ignore_for_file: prefer_single_quotes, prefer_adjacent_string_concatenation

import 'package:flutter/material.dart';

import '../core/presentation/presentation.dart';

/// Comprehensive test file for the translation script
/// This file contains all possible use cases to test the script's accuracy and limits
class ComprehensiveTestCases extends StatelessWidget {
  const ComprehensiveTestCases({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Translation Test Cases')),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ========================================
            // BASIC TEXT WIDGETS - SHOULD BE PROCESSED
            // ========================================
            _buildSection('Basic Text Widgets - Should Be Processed', [
              // Simple text widgets
              Text('Simple Text Widget'),
              Text("Double quoted widget"),
              SelectableText('Selectable text widget'),
              SelectableText("Double quoted selectable text"),

              // Text with nested quotes
              Text('Text with "nested" quotes'),
              Text("Text with 'nested' quotes"),
              SelectableText('Selectable Text with "nested" quotes'),
              SelectableText("Selectable Text with 'nested' quotes"),

              // Text with special characters
              Text('Text with special chars: !@#\$%^&*()'),
              Text('Text with numbers 123 456 789'),
              Text('Text with punctuation: hello world'),
            ]),

            // ========================================
            // TOOLTIP WIDGETS - SHOULD BE PROCESSED
            // ========================================
            _buildSection('Tooltip Widgets - Should Be Processed', [
              Tooltip(message: 'Simple tooltip message', child: Container()),
              Tooltip(message: "Double quoted tooltip", child: Container()),
              Tooltip(message: 'Tooltip with "nested" quotes', child: Container()),
              Tooltip(message: "Tooltip with 'nested' quotes", child: Container()),
            ]),

            // ========================================
            // NAVIGATION WIDGETS - SHOULD BE PROCESSED
            // ========================================
            _buildSection('Navigation Widgets - Should Be Processed', [
              // BottomNavigationBar with items
              SizedBox(
                height: 100,
                child: BottomNavigationBar(
                  items: [
                    BottomNavigationBarItem(
                      label: 'Home',
                      tooltip: 'Navigate to home',
                      icon: Icon(Icons.home),
                    ),
                    BottomNavigationBarItem(
                      label: "Profile",
                      tooltip: "View your profile",
                      icon: Icon(Icons.person),
                    ),
                  ],
                  currentIndex: 0,
                  onTap: (index) {},
                ),
              ),
            ]),

            // ========================================
            // MENU WIDGETS - SHOULD BE PROCESSED
            // ========================================
            _buildSection('Menu Widgets - Should Be Processed', [
              // PopupMenuButton as alternative to ContextMenuButton
              PopupMenuButton<String>(
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'copy', child: Text('Copy to clipboard')),
                  PopupMenuItem(value: 'paste', child: Text('Paste from clipboard')),
                  PopupMenuItem(value: 'delete', child: Text('Delete item')),
                  PopupMenuItem(value: 'edit', child: Text('Edit item')),
                ],
                child: Container(padding: EdgeInsets.all(8), child: Text('Right click me')),
              ),
            ]),

            // ========================================
            // BUTTON WIDGETS - SHOULD BE PROCESSED
            // ========================================
            _buildSection('Button Widgets - Should Be Processed', [
              ElevatedButton(onPressed: () {}, child: Text('Submit')),
              ElevatedButton(onPressed: () {}, child: Text('Cancel')),
            ]),

            // ========================================
            // APP AND TITLE WIDGETS - SHOULD BE PROCESSED
            // ========================================
            _buildSection('App and Title Widgets - Should Be Processed', [
              // Note: Title and WidgetsApp are typically used at app level
              // For testing purposes, we'll use them in containers
              Title(
                color: context.colors.primaryColor,
                title: 'My Application Title',
                child: Container(),
              ),
              Title(
                color: context.colors.primaryColor,
                title: "Another App Title",
                child: Container(),
              ),
            ]),

            // ========================================
            // TEXT SPAN WIDGETS - SHOULD BE PROCESSED
            // ========================================
            _buildSection('Text Span Widgets - Should Be Processed', [
              RichText(
                text: TextSpan(
                  text: 'This is text span content',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              RichText(
                text: TextSpan(
                  text: "Double quoted text span",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Text span with "nested" quotes',
                  style: TextStyle(color: Colors.black),
                ),
              ),
              RichText(
                text: TextSpan(
                  text: 'Accessibility label for screen readers',
                  style: TextStyle(color: Colors.black),
                ),
              ),
            ]),

            // ========================================
            // CUSTOM APP WIDGETS - SHOULD BE PROCESSED
            // ========================================
            _buildSection('Custom App Widgets - Should Be Processed', [
              AppTextField(
                controller: TextEditingController(),
                label: 'Email address',
                hint: 'Enter your email',
                prefixText: 'Email: ',
              ),
              AppTextField(
                controller: TextEditingController(),
                label: "Password field",
                hint: "Enter your password",
                prefixText: "Pass: ",
              ),
              AppButton.primary(label: 'Login to account', onPressed: () {}),
              AppButton.primary(label: "Create new account", onPressed: () {}),
              AppConfirmationDialog(
                heading: 'Confirm deletion',
                body: 'Are you sure you want to delete this item?',
                yesLabel: 'Yes, delete it',
                cancelLabel: 'No, keep it',
              ),
              AppDialog(heading: 'Information dialog', builder: (context) => Container()),
              AppSearchField(controller: TextEditingController(), hint: 'Search for items...'),
            ]),

            // ========================================
            // MULTI-LINE STRINGS - SHOULD BE PROCESSED
            // ========================================
            _buildSection('Multi-Line Strings - Should Be Processed', [
              Text('''
                This is a multi-line
                text widget that spans
                multiple lines
              '''),
              SelectableText('''
                This is a multi-line
                selectable text widget
                that spans multiple lines
              '''),
              Tooltip(
                message: '''
                  This is a multi-line
                  tooltip message that
                  spans multiple lines
                ''',
                child: Container(),
              ),
              AppTextField(
                controller: TextEditingController(),
                label: '''
                  This is a multi-line
                  label that spans multiple
                  lines for better readability
                ''',
                hint: '''
                  This is a multi-line hint
                  that provides detailed
                  instructions to the user
                ''',
              ),
            ]),

            // ========================================
            // VARIABLE INTERPOLATION - SHOULD BE UNPROCESSED
            // ========================================
            _buildSection('Variable Interpolation - Should Be Unprocessed', [
              Text('Hello ${"user.name"}!'),
              Text('Count: ${"items.length"} items'),
              Text('Error: ${"error.message"}'),
              Text('Welcome ${"firstName"} ${"lastName"}'),
              Text('Price: \$${"price"}'),
              Text('Status: ${"status"} ? \'Active\' : \'Inactive\''),
              SelectableText('User: ${"user.name"}'),
              Tooltip(message: 'Hello ${"user.name"}!', child: Container()),
              AppTextField(
                controller: TextEditingController(),
                label: 'Hello ${"user.name"}',
                hint: 'Enter ${"fieldName"}',
              ),
            ]),

            // ========================================
            // STRING CONCATENATION - SHOULD BE UNPROCESSED
            // ========================================
            _buildSection('String Concatenation - Should Be Unprocessed', [
              Text('Hello ' + 'name' + '!'),
              Text('Count: ' + 'count.toString()' + ' items'),
              Text('Welcome ' + 'firstName' + ' ' + 'lastName'),
              Text('Price: \$' + 'price.toString()'),
              Text('Status: ' + 'isActive' + ' ? \'Active\' : \'Inactive\''),
              SelectableText('User: ' + 'userName'),
              Tooltip(message: 'Hello ' + 'userName' + '!', child: Container()),
              AppTextField(
                controller: TextEditingController(),
                label: 'Hello ' + 'userName',
                hint: 'Enter ' + 'fieldName',
              ),
            ]),

            // ========================================
            // TECHNICAL PATTERNS - SHOULD BE UNPROCESSED
            // ========================================
            _buildSection('Technical Patterns - Should Be Unprocessed', [
              Text('http://api.example.com'),
              Text('https://www.google.com'),
              Text('api/endpoint'),
              Text('toMap()'),
              Text('fromMap()'),
              Text('toString()'),
              Text('debug'),
              Text('TODO: Fix this'),
              Text('FIXME: Implement feature'),
              Text('HACK: Temporary solution'),
              Text('assets/images/logo.png'),
              Text('lib/core/presentation.dart'),
              Text('test/widget_test.dart'),
              Text('android/app/src/main'),
              Text('ios/Runner/Info.plist'),
              Text('pubspec.yaml'),
              Text('README.md'),
              Text('controller'),
              Text('key'),
              Text('value'),
              Text('data'),
              Text('response'),
              Text('request'),
              Text('status'),
              Text('code'),
              Text('id'),
              Text('type'),
              Text('name'),
              Text('email'),
              Text('password'),
              Text('phone'),
              Text('address'),
              Text('url'),
              Text('uri'),
              Text('path'),
              Text('file'),
              Text('folder'),
              Text('directory'),
              Text('exception'),
              Text('error'),
              Text('failure'),
              Text('timeout'),
              Text('network'),
              Text('server'),
              Text('client'),
              Text('unauthorized'),
              Text('forbidden'),
              Text('not_found'),
              Text('bad_request'),
              Text('internal_server_error'),
              Text('yyyy-MM-dd'),
              Text('HH:mm:ss'),
              Text('ISO'),
              Text('UTC'),
              Text('timestamp'),
              Text('date'),
              Text('time'),
              Text('datetime'),
              Text('currency'),
              Text('amount'),
              Text('price'),
              Text('cost'),
              Text('total'),
              Text('sum'),
              Text('count'),
              Text('number'),
              Text('decimal'),
              Text('integer'),
              Text('float'),
              Text('double'),
              Text('color'),
              Text('style'),
              Text('theme'),
              Text('font'),
              Text('size'),
              Text('width'),
              Text('height'),
              Text('padding'),
              Text('margin'),
              Text('border'),
              Text('radius'),
              Text('shadow'),
              Text('gradient'),
              Text('opacity'),
              Text('alpha'),
              Text('rgb'),
              Text('hex'),
            ]),

            // ========================================
            // TOO SHORT STRINGS - SHOULD BE UNPROCESSED
            // ========================================
            _buildSection('Too Short Strings - Should Be Unprocessed', [
              Text('Hi'),
              Text('OK'),
              Text('No'),
              Text('Yes'),
              Text('A'),
              Text('B'),
              Text('1'),
              Text('2'),
              Text('!'),
              Text('?'),
            ]),

            // ========================================
            // SPECIAL CHARACTERS ONLY - SHOULD BE UNPROCESSED
            // ========================================
            _buildSection('Special Characters Only - Should Be Unprocessed', [
              Text('!@#\$%^&*()'),
              Text('123456789'),
              Text('---'),
              Text('___'),
              Text('...'),
              Text('!!!'),
              Text('???'),
              Text('###'),
              Text('***'),
              Text('+++'),
            ]),

            // ========================================
            // VARIABLE NAMES - SHOULD BE UNPROCESSED
            // ========================================
            _buildSection('Variable Names - Should Be Unprocessed', [
              Text('userName'),
              Text('api_key'),
              Text('firstName'),
              Text('lastName'),
              Text('emailAddress'),
              Text('phoneNumber'),
              Text('streetAddress'),
              Text('zipCode'),
              Text('countryCode'),
              Text('currencyCode'),
            ]),

            // ========================================
            // CONSTANTS - SHOULD BE UNPROCESSED
            // ========================================
            _buildSection('Constants - Should Be Unprocessed', [
              Text('DEBUG_MODE'),
              Text('API_ENDPOINT'),
              Text('MAX_RETRY_COUNT'),
              Text('DEFAULT_TIMEOUT'),
              Text('ERROR_CODE_404'),
              Text('SUCCESS_STATUS'),
              Text('FAILURE_STATUS'),
              Text('PENDING_STATUS'),
              Text('ACTIVE_STATE'),
              Text('INACTIVE_STATE'),
            ]),

            // ========================================
            // CODE PATTERNS - SHOULD BE UNPROCESSED
            // ========================================
            //?
            _buildSection('Code Patterns - Should Be Unprocessed', [
              Text('function()'),
              Text('method(param)'),
              Text('{key: value}'),
              Text('[item1, item2]'),
              Text('(param1, param2)'),
              Text('if (condition)'),
              Text('for (item in list)'),
              Text('while (condition)'),
              Text('try { } catch { }'),
              Text('class MyClass { }'),
            ]),

            // ========================================
            // COMMENT STRINGS - SHOULD BE UNPROCESSED
            // ========================================
            //?    _buildSection('Comment Strings - Should Be Unprocessed', [
            // Text('This is a comment string'),
            /* Text('This is also a comment string') */
            // Text('TODO: This is a comment'),
            /* Text('FIXME: This is a comment') */

            // ========================================
            // COMPLEX EXPRESSIONS - SHOULD BE UNPROCESSED
            // ========================================
            _buildSection('Complex Expressions - Should Be Unprocessed', [
              Text('Hello ${"user.name"} ?? \'Guest\'!'),
              Text('Count: ${"items.length"} > 0 ? ${"items.length"} : \'No items\''),
              Text('Status: ${"isActive"} ? \'Active\' : \'Inactive\' (${"lastUpdated"})'),
              Text('Price: \$${"price.toStringAsFixed(2)"}'),
              Text('User: ${"user.firstName"} ${"user.lastName"}'),
              Text('Date: ${"DateTime.now().toString()"}'),
              Text('URL: ${"baseUrl"}/api/${"endpoint"}'),
              Text('Path: ${"basePath"}/${"fileName"}.${"extension"}'),
              Text('Query: ${"baseUrl"}?${"params.map"}'),
              Text('JSON: ${"jsonEncode(data)"}'),
            ]),

            // ========================================
            // MIXED CASES - EDGE CASES
            // ========================================
            _buildSection('Mixed Cases - Edge Cases', [
              // Valid user-facing strings that contain technical words
              Text('Type to search...'),
              Text('Enter your email address'),
              Text('Enter your phone number'),
              Text('Enter your password'),
              Text('Enter your name'),
              Text('Enter your address'),

              // Strings with numbers but still user-facing
              Text('Enter your age (18+)'),
              Text('Enter your phone number (+1234567890)'),
              Text('Enter your zip code (12345)'),
              Text('Enter your credit card number'),
              Text('Enter your social security number'),

              // Strings with special characters but still user-facing
              Text('Enter your email (user@example.com)'),
              Text('Enter your website (https://example.com)'),
              Text('Enter your phone (+1-234-567-8900)'),
              Text('Enter your address (123 Main St, City, State 12345)'),

              // Multi-line strings with variables (should be unprocessed)
              Text('''
                Hello ${"user.name"}!
                Welcome to our application.
                Your account status is: ${"status"}
              '''),

              // Multi-line strings with concatenation (should be unprocessed)
              Text(
                '''
                Hello ''' +
                    'userName' +
                    '''!
                Welcome to our application.
                Your account status is: ''' +
                    'status' +
                    '''
              ''',
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            title,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue),
          ),
        ),
        ...children.map(
          (child) =>
              Padding(padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: child),
        ),
        Divider(),
      ],
    );
  }
}
