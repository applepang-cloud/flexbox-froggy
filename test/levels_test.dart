import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flexbox_froggy/levels.dart';
import 'package:flexbox_froggy/engine.dart';
import 'package:flexbox_froggy/main.dart';

const double _size = 360;

/// 한 레벨을 주어진 플레이어 선언으로 렌더링하고 승리 여부를 계산한다.
Future<bool> _evaluate(
  WidgetTester tester,
  Level level,
  Map<String, String> playerDecls,
) async {
  final stackKey = GlobalKey();
  final n = level.board.length;
  final frogKeys = List.generate(n, (_) => GlobalKey());
  final lilyKeys = List.generate(n, (_) => GlobalKey());

  Widget cell(GlobalKey k) => Container(
    key: k,
    width: kItem,
    height: kItem,
    margin: const EdgeInsets.all(kMargin),
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: _size,
            height: _size,
            child: Stack(
              key: stackKey,
              children: [
                PondLayer(
                  config: buildConfig(level, level.solution),
                  board: level.board,
                  size: _size,
                  buildItem: (i, c) => cell(lilyKeys[i]),
                ),
                PondLayer(
                  config: buildConfig(level, playerDecls),
                  board: level.board,
                  size: _size,
                  buildItem: (i, c) => cell(frogKeys[i]),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  tester.takeException(); // 오답 시 발생할 수 있는 오버플로 페인트 예외는 무시

  Offset pos(GlobalKey k) {
    final sb = stackKey.currentContext!.findRenderObject() as RenderBox;
    final b = k.currentContext!.findRenderObject() as RenderBox;
    return sb.globalToLocal(b.localToGlobal(Offset.zero));
  }

  String key(Offset p) => '${p.dx.round()},${p.dy.round()}';
  final board = level.board;
  final frogs = {for (var i = 0; i < n; i++) key(pos(frogKeys[i])): board[i]};
  for (var i = 0; i < n; i++) {
    if (frogs[key(pos(lilyKeys[i]))] != board[i]) return false;
  }
  return true;
}

void main() {
  testWidgets('레벨 데이터 무결성', (tester) async {
    expect(levels.length, 24);
    for (final l in levels) {
      expect(l.solution.isNotEmpty, true, reason: '${l.name} solution 비어있음');
      if (l.isChildTarget) {
        for (final idx in l.targetChildren!) {
          expect(idx, lessThan(l.board.length), reason: '${l.name} 자식 인덱스 범위초과');
        }
      }
    }
  });

  for (final level in levels) {
    testWidgets('정답 입력 시 통과: ${level.name}', (tester) async {
      final won = await _evaluate(tester, level, level.solution);
      expect(tester.takeException(), isNull, reason: '${level.name} 렌더 예외');
      expect(won, isTrue, reason: '${level.name} 정답으로 통과하지 못함');
    });

    testWidgets('빈 입력 시 실패: ${level.name}', (tester) async {
      final won = await _evaluate(tester, level, const {});
      expect(won, isFalse, reason: '${level.name} 빈 입력인데 통과됨');
    });
  }
}
