import 'package:appflowy_editor/src/flutter/overlay.dart';
import 'package:appflowy_editor/src/render/toolbar/toolbar_item.dart';
import 'package:appflowy_editor/src/render/toolbar/toolbar_item_widget.dart';
import 'package:flutter/material.dart' hide Overlay, OverlayEntry;

import 'package:appflowy_editor/src/editor_state.dart';

mixin ToolbarMixin<T extends StatefulWidget> on State<T> {
  void hide();
}

class ToolbarWidget extends StatefulWidget {
  const ToolbarWidget({
    Key? key,
    required this.editorState,
    required this.layerLink,
    required this.offset,
    required this.highlightColor,
    required this.items,
    this.alignment = Alignment.topLeft,
  }) : super(key: key);

  final EditorState editorState;
  final LayerLink layerLink;
  final Offset offset;
  final Color highlightColor;

  final List<ToolbarItem> items;

  final Alignment alignment;

  @override
  State<ToolbarWidget> createState() => _ToolbarWidgetState();
}

class _ToolbarWidgetState extends State<ToolbarWidget> with ToolbarMixin {
  OverlayEntry? _listToolbarOverlay;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.offset.dx,
      left: widget.offset.dy,
      child: CompositedTransformFollower(
        link: widget.layerLink,
        showWhenUnlinked: true,
        offset: widget.offset,
        followerAnchor: widget.alignment,
        child: _buildToolbar(context, widget.highlightColor),
      ),
    );
  }

  @override
  void hide() {
    _listToolbarOverlay?.remove();
    _listToolbarOverlay = null;
  }

  Widget _buildToolbar(BuildContext context, Color highlightColor) {
    return Material(
      borderRadius: BorderRadius.circular(8.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 8.0, right: 8.0),
        child: SizedBox(
          height: 32.0,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.items
                .map(
                  (item) => Center(
                    child: item.builder?.call(
                          context,
                          widget.editorState,
                          highlightColor,
                        ) ??
                        item.itemBuilder?.call(context, widget.editorState) ??
                        ToolbarItemWidget(
                          item: item,
                          isHighlight: item.highlightCallback
                                  ?.call(widget.editorState) ??
                              false,
                          onPressed: () {
                            item.handler?.call(widget.editorState, context);
                            widget.editorState.service.keyboardService
                                ?.enable();
                          },
                        ),
                  ),
                )
                .toList(growable: false),
          ),
        ),
      ),
    );
  }
}
