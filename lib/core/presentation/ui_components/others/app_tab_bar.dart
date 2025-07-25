import 'package:flutter/material.dart';

import '../../presentation.dart';

class AppTabBar extends StatelessWidget {
  const AppTabBar({super.key, this.controller, required this.tabs});
  final TabController? controller;
  final List<AppTab> tabs;
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      decoration: BoxDecoration(
        color: colors.grey300,
        borderRadius: BorderRadius.circular(64),
      ),
      child: TabBar(
        tabAlignment: TabAlignment.fill,
        indicatorPadding: const EdgeInsets.all(4),
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: tabs,
        dividerHeight: 0,
      ),
    );
  }
}

class AppTab extends Tab {
  const AppTab({
    super.key,
    super.text,
    super.icon,
    super.iconMargin = const EdgeInsets.only(right: 4),
  });
  static const double _kTabHeight = 48.0;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterial(context));

    const double calculatedHeight = _kTabHeight;
    final Widget label;
    if (icon == null) {
      label = _buildLabelText();
    } else if (text == null && child == null) {
      label = icon!;
    } else {
      label = Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            margin: iconMargin,
            child: icon,
          ),
          _buildLabelText(),
        ],
      );
    }

    return SizedBox(
      height: height ?? calculatedHeight,
      child: Center(
        widthFactor: 1,
        child: label,
      ),
    );
  }

  Widget _buildLabelText() {
    return Text(text!, softWrap: false, overflow: TextOverflow.fade);
  }
}
