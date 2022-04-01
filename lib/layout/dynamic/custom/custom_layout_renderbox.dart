import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:legend_design_widgets/layout/dynamic/custom/custom_layout_items.dart';

class CustomLayoutRenderBox extends RenderBox
    with SlottedContainerRenderObjectMixin<int>, DebugOverflowIndicatorMixin {
  final LegendCustomLayout customLayout;
  final List<int> indexes;

  CustomLayoutRenderBox({
    required this.customLayout,
    required this.indexes,
  });

  List<RenderBox>? _children;

  late Size contentSize;

  @override
  Iterable<RenderBox> get children {
    List<RenderBox> boxes = [];

    for (var i = 0; i < indexes.length; i++) {
      RenderBox? r = childForSlot(i);
      if (r != null) boxes.add(r);
    }
    return boxes;
  }

  List<Size> getIterableSizesRow(
      List<LegendCustomLayout> items, BoxConstraints constraints) {
    List<Size> sizes = [];
    BoxConstraints childConstraints = constraints;

    Map<int, RenderBox> noWidthSpecified = {};

    for (int i = 0; i < items.length; i++) {
      LegendCustomLayout layout = items[i];
      if (layout is LegendCustomWidget) {
        final RenderBox? child = childForSlot(layout.id);
        if (child != null) {
          double m_width = child.getMinIntrinsicWidth(100);
          if (m_width == 0) {
            print("");
            noWidthSpecified[i] = child;
            continue;
          }

          child.layout(childConstraints, parentUsesSize: true);
          sizes.add(child.size);
          childConstraints = childConstraints.copyWith(
              maxWidth: childConstraints.maxWidth - child.size.width);
        }
      } else if (layout is LegendCustomRow) {
        List<Size> rowSizes =
            getIterableSizesRow(layout.children, childConstraints);
        print(rowSizes);
      } else if (layout is LegendCustomColumn) {
        List<Size> columnSizes =
            getIterableSizesRow(layout.children, childConstraints);
        print(columnSizes);
        Size maxSize = Size.zero;
        for (Size s in columnSizes) {
          if (s.width > maxSize.width) {
            maxSize = s;
          }
        }
        sizes.add(maxSize);
        // childConstraints = childConstraints.copyWith(
        //   maxWidth: childConstraints.maxWidth - maxSize.width);
      }
    }

    noWidthSpecified.forEach((index, box) {
      box.layout(childConstraints, parentUsesSize: true);

      childConstraints = childConstraints.copyWith(
          maxWidth: childConstraints.maxWidth - box.size.width);

      sizes.insert(index, box.size);
    });

    return sizes;
  }

  List<Size> getIterableSizesColumn(
      List<LegendCustomLayout> items, BoxConstraints constraints) {
    List<Size> sizes = [];
    BoxConstraints childConstraints = constraints;
    for (LegendCustomLayout layout in items) {
      if (layout is LegendCustomWidget) {
        final RenderBox? child = childForSlot(layout.id);
        if (child != null) {
          child.layout(childConstraints, parentUsesSize: true);
          sizes.add(child.size);
          childConstraints = childConstraints.copyWith(
              maxHeight: childConstraints.maxHeight - child.size.height);
        }
      } else if (layout is LegendCustomRow) {
        List<Size> rowSizes =
            getIterableSizesColumn(layout.children, childConstraints);
        print(rowSizes);
      } else if (layout is LegendCustomColumn) {
        List<Size> columnSizes =
            getIterableSizesColumn(layout.children, childConstraints);
        print(columnSizes);
        Size maxSize = Size.zero;
        for (Size s in columnSizes) {
          if (s.width > maxSize.width) {
            maxSize = s;
          }
        }
        sizes.add(maxSize);
        // childConstraints = childConstraints.copyWith(
        //   maxWidth: childConstraints.maxWidth - maxSize.width);
      }
    }

    return sizes;
  }

  Size layoutItem(LegendCustomLayout layout, Offset offset,
      BoxConstraints childConstraints) {
    if (layout is LegendCustomWidget) {
      final RenderBox? child = childForSlot(layout.id);

      if (child != null) {
        child.layout(childConstraints, parentUsesSize: true);
        BoxParentData childParentData = child.parentData as BoxParentData;

        childParentData.offset = offset;
        return child.size;
      }
    } else if (layout is LegendCustomColumn) {
      // Spacing
      double? spacing = layout.spacing;

      // Constraints
      BoxConstraints constraints = childConstraints.copyWith(minWidth: 0);

      double height = 0;

      double width =
          isNotInfinite(constraints.maxWidth) ? constraints.maxWidth : 0;
      double mWidth = constraints.maxWidth;

      //
      List<Size> childSizes =
          getIterableSizesColumn(layout.children, constraints);

      // CrossAxisAligment
      CrossAxisAlignment? crossAxisAligment = layout.crossAxisAlignment;

      List<double> crossAxisSpacing = [];
      if (crossAxisAligment != null) {
        childSizes.forEach((size) {
          switch (crossAxisAligment) {
            case CrossAxisAlignment.center:
              double indent = 0;
              if (size.width < mWidth) {
                indent = (mWidth - size.width) / 2;
              }
              crossAxisSpacing.add(indent);
              break;
            case CrossAxisAlignment.end:
              double indent = 0;
              if (size.width < mWidth) {
                indent = (mWidth - size.width);
              }
              crossAxisSpacing.add(indent);
              break;
            case CrossAxisAlignment.start:
              crossAxisSpacing.add(0);
              break;

            default:
          }
        });
      }

      // Max Vertical Extent
      double mColWidth = 0;

      Offset columnOffset = offset;
      for (var i = 0; i < layout.children.length; i++) {
        // Update Constraints

        // Cross Axis Aligment
        double crossAxisSpace = 0;
        if (crossAxisAligment != null) {
          crossAxisSpace = crossAxisSpacing[i];
        }

        Size childSize = layoutItem(
          layout.children[i],
          Offset(columnOffset.dx + crossAxisSpace, columnOffset.dy),
          constraints,
        );

        // Add to rowWidth
        height += childSize.height;

        // Max
        if (childSize.height > mColWidth) mColWidth = childSize.height;

        // Add Spacing
        if (i != layout.children.length - 1 && spacing != null) {
          height += spacing;
        }

        // Update Offset
        columnOffset = Offset(columnOffset.dx, height);
      }

      return Size(width, height);
    } else if (layout is LegendCustomRow) {
      // Width of the Row
      double width = 0;

      // Max Width of the Row
      double mWidth = childConstraints.maxWidth;

      // Constraints
      BoxConstraints constraints = childConstraints.copyWith(minWidth: 0);

      double height =
          isNotInfinite(constraints.maxHeight) ? constraints.maxHeight : 0;

      Offset rowOffset = offset;

      // Spacing
      double? spacing = layout.spacing;
      List<Size> childSizes = getIterableSizesRow(layout.children, constraints);

      // CrossAxisAligment
      CrossAxisAlignment? crossAxisAligment = layout.crossAxisAlignment;

      // Max Vertical Extent
      double mRowHeight = 0;
      for (Size s in childSizes) {
        if (s.height > mRowHeight) {
          mRowHeight = s.height;
        }
      }

      List<double> crossAxisSpacing = [];
      if (crossAxisAligment != null) {
        childSizes.forEach((size) {
          switch (crossAxisAligment) {
            case CrossAxisAlignment.center:
              double indent = 0;
              if (size.height < mRowHeight) {
                indent = (mRowHeight - size.height) / 2;
              }
              crossAxisSpacing.add(indent);
              break;
            case CrossAxisAlignment.end:
              double indent = 0;
              if (size.height < mRowHeight) {
                indent = (mRowHeight - size.height);
              }
              crossAxisSpacing.add(indent);
              break;
            case CrossAxisAlignment.start:
              crossAxisSpacing.add(0);
              break;

            default:
          }
        });
      }

      // MainAxis Spacing Calculations
      MainAxisAlignment? mainAxisAlignment = layout.mainAxisAlignment;
      List<double> spaceEvenly = [];
      List<double> spaceBetween = [];
      double centerHorizontalOffset = -1;
      double endHorizontalOffset = -1;

      // Flex
      bool childHasFlex =
          layout.children.any((element) => element.flex != null);

      if (childHasFlex) {
        List<LegendCustomLayout> flexItems = [];

        // Get Sizes
        List<Size> itemsSizes =
            getIterableSizesRow(layout.children, constraints);

        List<Size> noFlexItemsSizes = [];

        for (var i = 0; i < layout.children.length; i++) {
          LegendCustomLayout item = layout.children[i];
          if (item.flex != null) {
            flexItems.add(item);
          } else {
            noFlexItemsSizes.add(itemsSizes[i]);
          }
        }

        double filledSpace = 0;
        for (Size size in noFlexItemsSizes) {
          filledSpace += size.width;
        }
        if (spacing != null)
          filledSpace += spacing * (layout.children.length - 1);

        // Get FlexSum
        int flexSum = 0;
        flexItems.forEach((element) {
          if (element.flex != null) flexSum += element.flex!;
        });

        double remainingWidth = mWidth - filledSpace;

        double flexUnit = remainingWidth / flexSum;

        childSizes = [];
        for (var i = 0; i < layout.children.length; i++) {
          LegendCustomLayout item = layout.children[i];

          if (item.flex != null) {
            int flex = item.flex!;
            double height = itemsSizes[i].height;
            double width = flex * flexUnit;

            childSizes.add(Size(width, height));
          } else {
            childSizes.add(itemsSizes[i]);
          }
        }
        print(childSizes);
      } else if (mainAxisAlignment != null) {
        // Set Spacing null as we don't need it
        spacing = null;

        switch (mainAxisAlignment) {
          case MainAxisAlignment.spaceEvenly:
            double filledSpace = 0;
            for (Size s in childSizes) {
              filledSpace += s.width;
            }

            double rem = mWidth - filledSpace;

            double space = rem / (childSizes.length + 1);

            for (var i = 0; i < childSizes.length + 1; i++) {
              spaceEvenly.add(space);
            }
            break;
          case MainAxisAlignment.spaceBetween:
            double filledSpace = 0;
            for (Size s in childSizes) {
              filledSpace += s.width;
            }

            double rem = mWidth - filledSpace;

            double space = rem / (childSizes.length - 1);

            for (var i = 0; i < childSizes.length - 1; i++) {
              spaceBetween.add(space);
            }
            break;

          case MainAxisAlignment.center:
            spacing = layout.spacing;
            double filledSpace = 0;
            for (Size s in childSizes) {
              filledSpace += s.width;
            }

            filledSpace += spacing! * (childSizes.length - 1);

            double rem = mWidth - filledSpace;

            double space = rem / 2;

            centerHorizontalOffset = space;
            break;
          case MainAxisAlignment.end:
            spacing = layout.spacing;
            double filledSpace = 0;
            for (Size s in childSizes) {
              filledSpace += s.width;
            }

            filledSpace += spacing! * (childSizes.length - 1);

            double rem = mWidth - filledSpace;

            endHorizontalOffset = rem;
            break;
          default:
        }
      }

      bool s_evenly = spaceEvenly.isNotEmpty;
      bool s_between = spaceBetween.isNotEmpty;
      bool s_center = centerHorizontalOffset != -1;
      bool s_end = endHorizontalOffset != -1;

      if (!childHasFlex) {
        if (s_evenly) {
          rowOffset = Offset(offset.dx + spaceEvenly[0], offset.dy);
        }

        if (s_center) {
          rowOffset = Offset(offset.dx + centerHorizontalOffset, offset.dy);
        }

        if (s_end) {
          rowOffset = Offset(offset.dx + endHorizontalOffset, offset.dy);
        }
      }

      // Layout
      double c_width = 0;
      mRowHeight = 0;
      for (var i = 0; i < layout.children.length; i++) {
        // Update Constraints
        constraints = constraints.copyWith(
          minHeight: height,
          maxWidth: constraints.maxWidth - c_width, // - rowOffset.dx,
        );

        if (childHasFlex) {
          double flexWidth = childSizes[i].width;
          constraints = constraints.copyWith(
            minWidth: flexWidth,
            maxWidth: flexWidth,
          );
        }

        double crossAxisSpace = 0;
        if (crossAxisAligment != null) {
          crossAxisSpace = crossAxisSpacing[i];
        }

        Size childSize = layoutItem(layout.children[i],
            Offset(rowOffset.dx, rowOffset.dy + crossAxisSpace), constraints);

        // Add to rowWidth
        c_width = childSize.width;

        // Add Spacing
        if (i != layout.children.length - 1 && spacing != null) {
          c_width += spacing;
        }

        // MainAxisSpacing Between
        if (s_between) {
          if (i != layout.children.length - 1) {
            c_width += spaceBetween[i];
          }
        }

        // MainAxisSpacing Between
        if (s_evenly) {
          c_width += spaceEvenly[i + 1];
        }

        // Update Offset
        rowOffset = Offset(rowOffset.dx + c_width, rowOffset.dy);

        if (mRowHeight < childSize.height) {
          mRowHeight = childSize.height;
        }
      }

      return Size(mWidth, mRowHeight);
    }

    return Size.zero;
  }

  bool isNotInfinite(final double maxWidth) {
    return maxWidth != double.infinity;
  }

  @override
  void performLayout() {
    // Children are allowed to be as big as they want (= unconstrained).
    BoxConstraints constraints = this.constraints;

    print(constraints.maxWidth);

    contentSize = layoutItem(customLayout, Offset.zero, constraints);
    /*
    for (RenderBox box in children) {
      box.layout(constraints, parentUsesSize: true);
      _positionChild(box, offset);

      s = box.size;
      offset = Offset(offset.dx + s.width, offset.dy + s.height);

      _childrenSize =
          Size(_childrenSize.width + s.width, _childrenSize.height + s.height);
    }*/

    // Calculate the overall size and constrain it to the given constraints.
    // Any overflow is marked (in debug mode) during paint.

    size = constraints.constrain(contentSize);
  }

  void _positionChild(RenderBox child, Offset offset) {
    (child.parentData! as BoxParentData).offset = offset;
  }

  // PAINT

  @override
  void paint(PaintingContext context, Offset offset) {
    // Paint the background.

    context.canvas.drawRect(
      offset & size,
      Paint()..color = Colors.red,
    );

    void paintChild(RenderBox child, PaintingContext context, Offset offset) {
      final BoxParentData childParentData = child.parentData! as BoxParentData;
      context.paintChild(child, childParentData.offset + offset);
    }

    for (RenderBox box in children) {
      paintChild(box, context, offset);
    }

    // Paint an overflow indicator in debug mode if the children want to be
    // larger than the incoming constraints allow.
    assert(() {
      paintOverflowIndicator(
        context,
        offset,
        Offset.zero & size,
        Offset.zero & contentSize,
      );
      return true;
    }());
  }

  // HIT TEST

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    for (final RenderBox child in children) {
      final BoxParentData parentData = child.parentData! as BoxParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: parentData.offset,
        position: position,
        hitTest: (BoxHitTestResult result, Offset transformed) {
          assert(transformed == position - parentData.offset);
          return child.hitTest(result, position: transformed);
        },
      );
      if (isHit) {
        return true;
      }
    }
    return false;
  }

  // INTRINSICS

  // Incoming height/width are ignored as children are always laid out unconstrained.

  @override
  double computeMinIntrinsicWidth(double height) {
    double width = 0;
    for (RenderBox box in children) {
      width += box.getMinIntrinsicWidth(double.infinity);
    }

    return width;
  }

  @override
  double computeMaxIntrinsicWidth(double height) {
    double width = 0;
    for (RenderBox box in children) {
      width += box.getMaxIntrinsicWidth(double.infinity);
    }

    return width;
  }

  @override
  double computeMinIntrinsicHeight(double width) {
    double height = 0;
    for (RenderBox box in children) {
      height += box.getMinIntrinsicHeight(double.infinity);
    }

    return height;
  }

  @override
  double computeMaxIntrinsicHeight(double width) {
    double height = 0;
    for (RenderBox box in children) {
      height += box.getMaxIntrinsicHeight(double.infinity);
    }

    return height;
  }

  @override
  Size computeDryLayout(BoxConstraints constraints) {
    const BoxConstraints childConstraints = BoxConstraints();
    Size s = Size.zero;
    for (RenderBox box in children) {
      Size boxSize = box.computeDryLayout(childConstraints);
      s = Size(s.width + boxSize.width, s.height + boxSize.height);
    }

    return constraints.constrain(s);
  }
}