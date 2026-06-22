// CSS flexbox 선언을 Flutter Flex/Wrap 레이아웃으로 변환하는 엔진.
import 'package:flutter/material.dart';
import 'levels.dart';

/// "key: value;" 줄들을 파싱한다. (대소문자 무시)
Map<String, String> parseDeclarations(String css) {
  final map = <String, String>{};
  for (final part in css.split(RegExp(r'[;\n]'))) {
    final idx = part.indexOf(':');
    if (idx < 0) continue;
    final key = part.substring(0, idx).trim().toLowerCase();
    final value = part.substring(idx + 1).trim().toLowerCase();
    if (key.isEmpty || value.isEmpty) continue;
    map[key] = value;
  }
  return map;
}

/// 컨테이너 속성과 자식별 속성으로 나뉜 레이아웃 설정.
class LayoutConfig {
  final Map<String, String> container;
  final Map<int, Map<String, String>> children;
  const LayoutConfig(this.container, this.children);
}

/// 레벨 + 플레이어(또는 정답) 선언 → LayoutConfig
LayoutConfig buildConfig(Level level, Map<String, String> decls) {
  final container = <String, String>{...level.base};
  final children = <int, Map<String, String>>{};
  if (level.isChildTarget) {
    for (final i in level.targetChildren!) {
      children[i] = decls;
    }
  } else {
    container.addAll(decls);
  }
  return LayoutConfig(container, children);
}

// ── CSS 값 → Flutter enum 매핑 ───────────────────────────────

MainAxisAlignment _mainAxis(String? v) {
  switch (v) {
    case 'flex-end':
    case 'end':
      return MainAxisAlignment.end;
    case 'center':
      return MainAxisAlignment.center;
    case 'space-between':
      return MainAxisAlignment.spaceBetween;
    case 'space-around':
      return MainAxisAlignment.spaceAround;
    case 'space-evenly':
      return MainAxisAlignment.spaceEvenly;
    default:
      return MainAxisAlignment.start;
  }
}

/// 자식 한 개의 교차축 정렬 (align-items / align-self).
Alignment _crossAlign(String? v, bool horizontalMain) {
  switch (v) {
    case 'flex-end':
    case 'end':
      return horizontalMain ? Alignment.bottomCenter : Alignment.centerRight;
    case 'center':
      return Alignment.center;
    case 'flex-start':
    case 'start':
    case 'stretch':
    case 'baseline':
    default:
      return horizontalMain ? Alignment.topCenter : Alignment.centerLeft;
  }
}

WrapAlignment _wrapAlign(String? v) {
  switch (v) {
    case 'flex-end':
    case 'end':
      return WrapAlignment.end;
    case 'center':
      return WrapAlignment.center;
    case 'space-between':
      return WrapAlignment.spaceBetween;
    case 'space-around':
      return WrapAlignment.spaceAround;
    case 'space-evenly':
      return WrapAlignment.spaceEvenly;
    default:
      return WrapAlignment.start;
  }
}

/// align-content 전용: 미지정 시 CSS 기본값 stretch 를 근사(행을 위/아래로 분산).
/// 이렇게 해야 flex-start 등 정답값과 기본값이 구분되어 레벨이 미리 풀리지 않는다.
WrapAlignment _runAlign(String? v) =>
    v == null ? WrapAlignment.spaceBetween : _wrapAlign(v);

WrapCrossAlignment _wrapCross(String? v) {
  switch (v) {
    case 'flex-end':
    case 'end':
      return WrapCrossAlignment.end;
    case 'center':
      return WrapCrossAlignment.center;
    default:
      return WrapCrossAlignment.start;
  }
}

/// 한 개의 연못 레이어(연잎 또는 개구리들)를 렌더링한다.
class PondLayer extends StatelessWidget {
  final LayoutConfig config;
  final String board;
  final double size;
  final Widget Function(int index, String colorChar) buildItem;

  const PondLayer({
    super.key,
    required this.config,
    required this.board,
    required this.size,
    required this.buildItem,
  });

  int _orderOf(int i) {
    final v = config.children[i]?['order'] ?? config.container['order'];
    return int.tryParse(v ?? '0') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    // flex-flow 단축 속성 펼치기
    final cont = <String, String>{...config.container};
    if (cont.containsKey('flex-flow')) {
      for (final p in cont['flex-flow']!.split(RegExp(r'\s+'))) {
        if (p.contains('wrap')) {
          cont.putIfAbsent('flex-wrap', () => p);
        } else if (p.startsWith('row') || p.startsWith('column')) {
          cont.putIfAbsent('flex-direction', () => p);
        }
      }
    }

    final dir = cont['flex-direction'] ?? 'row';
    final wrapVal = cont['flex-wrap'] ?? 'nowrap';
    final horizontalMain = dir.startsWith('row');
    final mainReverse = dir.endsWith('reverse');
    final isWrap = wrapVal == 'wrap' || wrapVal == 'wrap-reverse';
    final crossReverse = wrapVal == 'wrap-reverse';
    final justify = cont['justify-content'];
    final alignItems = cont['align-items'];
    final alignContent = cont['align-content'];

    // order 기준 정렬(안정적: 동률이면 원본 순서)
    final indices = List.generate(board.length, (i) => i);
    indices.sort((a, b) {
      final oa = _orderOf(a), ob = _orderOf(b);
      return oa != ob ? oa.compareTo(ob) : a.compareTo(b);
    });

    TextDirection td;
    VerticalDirection vd;
    if (horizontalMain) {
      td = mainReverse ? TextDirection.rtl : TextDirection.ltr;
      vd = crossReverse ? VerticalDirection.up : VerticalDirection.down;
    } else {
      vd = mainReverse ? VerticalDirection.up : VerticalDirection.down;
      td = crossReverse ? TextDirection.rtl : TextDirection.ltr;
    }

    Widget layout;
    if (isWrap) {
      layout = Wrap(
        direction: horizontalMain ? Axis.horizontal : Axis.vertical,
        alignment: _wrapAlign(justify),
        runAlignment: _runAlign(alignContent),
        crossAxisAlignment: _wrapCross(alignItems),
        textDirection: td,
        verticalDirection: vd,
        children: [for (final i in indices) buildItem(i, board[i])],
      );
    } else {
      layout = Flex(
        direction: horizontalMain ? Axis.horizontal : Axis.vertical,
        mainAxisAlignment: _mainAxis(justify),
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        textDirection: td,
        verticalDirection: vd,
        children: [
          for (final i in indices)
            Align(
              alignment: _crossAlign(
                config.children[i]?['align-self'] ?? alignItems,
                horizontalMain,
              ),
              child: buildItem(i, board[i]),
            ),
        ],
      );
    }

    return SizedBox(width: size, height: size, child: layout);
  }
}
