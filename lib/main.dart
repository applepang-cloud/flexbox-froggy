import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'levels.dart';
import 'engine.dart';

void main() => runApp(const FroggyApp());

class FroggyApp extends StatelessWidget {
  const FroggyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flexbox 개구리',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6FBF3B),
        fontFamily: 'monospace',
      ),
      home: const GameScreen(),
    );
  }
}

Color colorFor(String c) => switch (c) {
  'g' => const Color(0xFF6FBF3B),
  'r' => const Color(0xFFE0533D),
  _ => const Color(0xFFF0C419),
};

const double kCell = 62; // 한 칸(아이템+여백)
const double kMargin = 3;
const double kItem = kCell - 2 * kMargin;

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});
  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final _code = TextEditingController();
  final _stackKey = GlobalKey();
  late List<GlobalKey> _frogKeys;
  late List<GlobalKey> _lilyKeys;

  int _index = 0;
  bool _won = false;
  SharedPreferences? _prefs;
  final Set<String> _solved = {};

  Level get _level => levels[_index];

  @override
  void initState() {
    super.initState();
    _makeKeys();
    _load();
  }

  Future<void> _load() async {
    _prefs = await SharedPreferences.getInstance();
    _solved.addAll(_prefs!.getStringList('solved') ?? const []);
    _index = (_prefs!.getInt('level') ?? 0).clamp(0, levels.length - 1);
    _loadLevel(_index);
  }

  void _makeKeys() {
    final n = _level.board.length;
    _frogKeys = List.generate(n, (_) => GlobalKey());
    _lilyKeys = List.generate(n, (_) => GlobalKey());
  }

  void _loadLevel(int i) {
    setState(() {
      _index = i.clamp(0, levels.length - 1);
      _won = false;
      _makeKeys();
      _code.text = _prefs?.getString('code_${_level.name}') ?? '';
    });
    _prefs?.setInt('level', _index);
    _scheduleCheck();
  }

  void _onCodeChanged() {
    _prefs?.setString('code_${_level.name}', _code.text);
    setState(() {});
    _scheduleCheck();
  }

  void _scheduleCheck() {
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkWin());
  }

  Offset? _posOf(GlobalKey k) {
    final stackBox = _stackKey.currentContext?.findRenderObject() as RenderBox?;
    final box = k.currentContext?.findRenderObject() as RenderBox?;
    if (stackBox == null || box == null || !box.hasSize) return null;
    return stackBox.globalToLocal(box.localToGlobal(Offset.zero));
  }

  void _checkWin() {
    final board = _level.board;
    // 원본과 동일: 개구리 위치(반올림)→색 맵을 만들고, 모든 연잎 위치에
    // 같은 색 개구리가 정확히 올라와 있는지 검사한다.
    final frogs = <String, String>{};
    for (var i = 0; i < board.length; i++) {
      final p = _posOf(_frogKeys[i]);
      if (p == null) return; // 아직 레이아웃 전
      frogs['${p.dx.round()},${p.dy.round()}'] = board[i];
    }
    var ok = true;
    for (var i = 0; i < board.length && ok; i++) {
      final lp = _posOf(_lilyKeys[i]);
      if (lp == null) return;
      if (frogs['${lp.dx.round()},${lp.dy.round()}'] != board[i]) ok = false;
    }
    if (ok && !_won) {
      _solved.add(_level.name);
      _prefs?.setStringList('solved', _solved.toList());
    }
    if (ok != _won) setState(() => _won = ok);
  }

  void _insertProp(String prop, String value) {
    final decls = parseDeclarations(_code.text);
    decls[prop] = value;
    _code.text = decls.entries
        .map((e) => '  ${e.key}: ${e.value};')
        .join('\n');
    _onCodeChanged();
  }

  // ── 아이템 위젯 ──────────────────────────────
  Widget _frog(int i, String c) {
    return Container(
      key: _frogKeys[i],
      width: kItem,
      height: kItem,
      margin: const EdgeInsets.all(kMargin),
      alignment: Alignment.center,
      child: Container(
        width: kItem * 0.82,
        height: kItem * 0.82,
        decoration: BoxDecoration(
          color: colorFor(c),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.25),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text('🐸', style: TextStyle(fontSize: kItem * 0.42)),
      ),
    );
  }

  Widget _lily(int i, String c) {
    return Container(
      key: _lilyKeys[i],
      width: kItem,
      height: kItem,
      margin: const EdgeInsets.all(kMargin),
      alignment: Alignment.center,
      child: Container(
        width: kItem * 0.95,
        height: kItem * 0.95,
        decoration: BoxDecoration(
          color: colorFor(c).withValues(alpha: 0.30),
          shape: BoxShape.circle,
          border: Border.all(color: colorFor(c).withValues(alpha: 0.8), width: 3),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final solvedCount = _solved.length;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2E7D32),
        foregroundColor: Colors.white,
        title: Text('Flexbox 개구리  ·  ${_index + 1}/${levels.length}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: Text(
                '✅ $solvedCount',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.grid_view),
            tooltip: '레벨 선택',
            onPressed: _showLevelPicker,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, c) {
          final wide = c.maxWidth > 760;
          final pondSize =
              (wide ? 360.0 : c.maxWidth - 24).clamp(240.0, 360.0);
          final pond = _buildPond(pondSize);
          final panel = _buildPanel();
          if (wide) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Center(child: SingleChildScrollView(child: pond)),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: SingleChildScrollView(child: panel)),
              ],
            );
          }
          return SingleChildScrollView(
            child: Column(
              children: [const SizedBox(height: 12), pond, panel],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPond(double size) {
    final solutionCfg = buildConfig(_level, _level.solution);
    final playerCfg = buildConfig(_level, parseDeclarations(_code.text));
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7EC8E3), Color(0xFF4A9BD1)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF2E7D32), width: 4),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        key: _stackKey,
        children: [
          PondLayer(
            config: solutionCfg,
            board: _level.board,
            size: size,
            buildItem: _lily,
          ),
          PondLayer(
            config: playerCfg,
            board: _level.board,
            size: size,
            buildItem: _frog,
          ),
          if (_won)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 8,
              child: Center(child: _WinBadge()),
            ),
        ],
      ),
    );
  }

  Widget _buildPanel() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            _level.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              _level.instructions,
              style: const TextStyle(fontSize: 13.5, height: 1.5),
            ),
          ),
          const SizedBox(height: 16),
          _buildEditor(),
          const SizedBox(height: 12),
          _buildHints(),
          const SizedBox(height: 16),
          _buildNav(),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    const codeStyle = TextStyle(
      fontFamily: 'monospace',
      fontSize: 14,
      height: 1.4,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF272822),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _level.before,
            style: codeStyle.copyWith(color: const Color(0xFF8FB573)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: TextField(
              controller: _code,
              onChanged: (_) => _onCodeChanged(),
              maxLines: null,
              minLines: 1,
              autocorrect: false,
              enableSuggestions: false,
              style: codeStyle.copyWith(color: const Color(0xFFFFD866)),
              cursorColor: Colors.white,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: '  여기에 CSS 작성…',
                hintStyle: TextStyle(color: Color(0xFF75715E)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          Text(
            _level.after,
            style: codeStyle.copyWith(color: const Color(0xFF8FB573)),
          ),
        ],
      ),
    );
  }

  Widget _buildHints() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '힌트 — 탭하면 자동 입력',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 6),
        for (final prop in _level.properties)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Text(
                  '$prop:',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                for (final v in propertyValues[prop] ?? const [])
                  ActionChip(
                    label: Text(v, style: const TextStyle(fontSize: 12)),
                    visualDensity: VisualDensity.compact,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () => _insertProp(prop, v),
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildNav() {
    return Row(
      children: [
        OutlinedButton.icon(
          onPressed: _index > 0 ? () => _loadLevel(_index - 1) : null,
          icon: const Icon(Icons.chevron_left),
          label: const Text('이전'),
        ),
        const Spacer(),
        FilledButton.icon(
          onPressed: _index < levels.length - 1
              ? () => _loadLevel(_index + 1)
              : null,
          style: FilledButton.styleFrom(
            backgroundColor: _won ? const Color(0xFF2E7D32) : null,
          ),
          icon: const Icon(Icons.chevron_right),
          label: Text(_won ? '다음 ▶' : '다음'),
        ),
      ],
    );
  }

  void _showLevelPicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) => GridView.count(
        crossAxisCount: 6,
        padding: const EdgeInsets.all(16),
        children: [
          for (var i = 0; i < levels.length; i++)
            Padding(
              padding: const EdgeInsets.all(4),
              child: InkWell(
                onTap: () {
                  Navigator.pop(context);
                  _loadLevel(i);
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: _solved.contains(levels[i].name)
                        ? const Color(0xFF6FBF3B)
                        : (i == _index
                              ? const Color(0xFFBBDEFB)
                              : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }
}

class _WinBadge extends StatelessWidget {
  const _WinBadge();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF2E7D32),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black38, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: const Text(
        '통과! 🎉 개구리가 모두 연잎에 올라탔어요',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}
