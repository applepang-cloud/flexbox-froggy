// 24개 레벨 데이터 — 원본 thomaspark/flexboxfroggy 에서 추출 후 Flutter용으로 가공.
// 배경(연잎)은 solution 으로, 전경(개구리)은 플레이어 CSS 로 배치된다.

class Level {
  final String name;
  final String title; // 한국어 짧은 제목
  final String board; // 'g'=초록 'r'=빨강 'y'=노랑
  final Map<String, String> base; // 컨테이너에 미리 적용된 속성(display 제외)
  final Map<String, String> solution; // 정답 선언 (대상에 적용)
  final List<int>? targetChildren; // null=컨테이너 대상, 아니면 자식 인덱스들
  final String selectorLabel; // 자식 대상 표시용 셀렉터 라벨
  final String before; // 편집창 위에 보여줄 읽기전용 CSS
  final String after; // 편집창 아래 (보통 "}")
  final String instructions; // 한국어 설명
  final List<String> properties; // 이 레벨에서 다루는 속성(힌트 칩)

  const Level({
    required this.name,
    required this.title,
    required this.board,
    this.base = const {},
    required this.solution,
    this.targetChildren,
    this.selectorLabel = '',
    required this.before,
    this.after = '}',
    required this.instructions,
    required this.properties,
  });

  bool get isChildTarget => targetChildren != null;
}

// 속성별 사용 가능한 값 (힌트 칩)
const Map<String, List<String>> propertyValues = {
  'justify-content': [
    'flex-start',
    'flex-end',
    'center',
    'space-between',
    'space-around',
    'space-evenly',
  ],
  'align-items': ['flex-start', 'flex-end', 'center', 'stretch', 'baseline'],
  'flex-direction': ['row', 'row-reverse', 'column', 'column-reverse'],
  'order': ['1', '2', '3', '-1'],
  'align-self': ['flex-start', 'flex-end', 'center', 'stretch'],
  'flex-wrap': ['nowrap', 'wrap', 'wrap-reverse'],
  'flex-flow': ['row wrap', 'column wrap', 'row-reverse wrap'],
  'align-content': [
    'flex-start',
    'flex-end',
    'center',
    'space-between',
    'space-around',
    'stretch',
  ],
};

const List<Level> levels = [
  Level(
    name: 'justify-content 1',
    title: 'justify-content ①',
    board: 'g',
    solution: {'justify-content': 'flex-end'},
    before: '#pond {\n  display: flex;',
    instructions:
        'Flexbox 개구리에 오신 걸 환영해요! CSS를 작성해서 개구리를 같은 색 연잎으로 안내하세요.\n\n'
        'justify-content 는 아이템을 가로로 정렬합니다.\n'
        '• flex-start: 왼쪽 정렬\n'
        '• flex-end: 오른쪽 정렬\n'
        '• center: 가운데 정렬\n'
        '• space-between: 양끝 정렬, 사이 균등\n'
        '• space-around: 아이템 주위 균등\n\n'
        '예) justify-content: flex-end; 는 개구리를 오른쪽으로 보냅니다.',
    properties: ['justify-content'],
  ),
  Level(
    name: 'justify-content 2',
    title: 'justify-content ②',
    board: 'gy',
    solution: {'justify-content': 'center'},
    before: '#pond {\n  display: flex;',
    instructions: '연잎이 가운데 모여 있어요. justify-content 로 두 개구리를 가운데로 모으세요.',
    properties: ['justify-content'],
  ),
  Level(
    name: 'justify-content 3',
    title: 'justify-content ③',
    board: 'gyr',
    solution: {'justify-content': 'space-around'},
    before: '#pond {\n  display: flex;',
    instructions:
        'space-around 는 각 아이템 주위에 균등한 여백을 줍니다. 개구리들을 연잎 위로 펼쳐 보세요.',
    properties: ['justify-content'],
  ),
  Level(
    name: 'justify-content 4',
    title: 'justify-content ④',
    board: 'gyr',
    solution: {'justify-content': 'space-between'},
    before: '#pond {\n  display: flex;',
    instructions:
        'space-between 은 첫/마지막 아이템을 양 끝에 붙이고 나머지는 균등하게 띄웁니다.',
    properties: ['justify-content'],
  ),
  Level(
    name: 'align-items 1',
    title: 'align-items ①',
    board: 'gyr',
    solution: {'align-items': 'flex-end'},
    before: '#pond {\n  display: flex;',
    instructions:
        'align-items 는 아이템을 세로로 정렬합니다.\n'
        '• flex-start: 위쪽\n'
        '• flex-end: 아래쪽\n'
        '• center: 가운데\n\n'
        '개구리들을 아래쪽 연잎으로 내려보내세요.',
    properties: ['align-items'],
  ),
  Level(
    name: 'align-items 2',
    title: 'align-items ②',
    board: 'g',
    solution: {'justify-content': 'center', 'align-items': 'center'},
    before: '#pond {\n  display: flex;',
    instructions:
        'justify-content(가로)와 align-items(세로)를 함께 쓰면 정중앙에 놓을 수 있어요. '
        '두 속성을 모두 작성해 보세요.',
    properties: ['justify-content', 'align-items'],
  ),
  Level(
    name: 'align-items 3',
    title: 'align-items ③',
    board: 'gyr',
    solution: {'justify-content': 'space-around', 'align-items': 'flex-end'},
    before: '#pond {\n  display: flex;',
    instructions: '가로로는 고르게 펼치고(space-around), 세로로는 아래쪽으로 정렬해 보세요.',
    properties: ['justify-content', 'align-items'],
  ),
  Level(
    name: 'flex-direction 1',
    title: 'flex-direction ①',
    board: 'gyr',
    solution: {'flex-direction': 'row-reverse'},
    before: '#pond {\n  display: flex;',
    instructions:
        'flex-direction 은 아이템이 쌓이는 방향을 정합니다.\n'
        '• row: 왼→오 (기본)\n'
        '• row-reverse: 오→왼\n'
        '• column: 위→아래\n'
        '• column-reverse: 아래→위\n\n'
        '연잎 순서가 뒤집혀 있어요. 방향을 반대로 바꿔보세요.',
    properties: ['flex-direction'],
  ),
  Level(
    name: 'flex-direction 2',
    title: 'flex-direction ②',
    board: 'gyr',
    solution: {'flex-direction': 'column'},
    before: '#pond {\n  display: flex;',
    instructions: 'column 으로 개구리를 세로로 쌓아 위→아래 연잎에 올리세요.',
    properties: ['flex-direction'],
  ),
  Level(
    name: 'flex-direction 3',
    title: 'flex-direction ③',
    board: 'gyr',
    solution: {'flex-direction': 'row-reverse', 'justify-content': 'flex-end'},
    before: '#pond {\n  display: flex;',
    instructions:
        '방향을 뒤집으면 flex-start/flex-end 의 의미도 함께 뒤집힙니다. '
        '두 속성을 조합해 개구리를 옮겨보세요.',
    properties: ['flex-direction', 'justify-content'],
  ),
  Level(
    name: 'flex-direction 4',
    title: 'flex-direction ④',
    board: 'gyr',
    solution: {'flex-direction': 'column', 'justify-content': 'flex-end'},
    before: '#pond {\n  display: flex;',
    instructions: 'column 방향에서는 justify-content 가 세로축을 제어합니다.',
    properties: ['flex-direction', 'justify-content'],
  ),
  Level(
    name: 'flex-direction 5',
    title: 'flex-direction ⑤',
    board: 'gyr',
    solution: {
      'flex-direction': 'column-reverse',
      'justify-content': 'space-between',
    },
    before: '#pond {\n  display: flex;',
    instructions: 'column-reverse 와 space-between 을 함께 사용해 보세요.',
    properties: ['flex-direction', 'justify-content'],
  ),
  Level(
    name: 'flex-direction 6',
    title: 'flex-direction ⑥',
    board: 'gyr',
    solution: {
      'flex-direction': 'row-reverse',
      'justify-content': 'center',
      'align-items': 'flex-end',
    },
    before: '#pond {\n  display: flex;',
    instructions: '지금까지 배운 세 속성을 모두 조합하는 단계입니다. 차근차근 작성해 보세요.',
    properties: ['flex-direction', 'justify-content', 'align-items'],
  ),
  Level(
    name: 'order 1',
    title: 'order ①',
    board: 'gyr',
    base: {},
    solution: {'order': '2'},
    targetChildren: [1],
    selectorLabel: '.yellow',
    before: '#pond {\n  display: flex;\n}\n\n.yellow {',
    instructions:
        'order 는 각 아이템의 순서를 정합니다. 기본값은 0이고, 값이 클수록 뒤로 갑니다.\n\n'
        '노란 개구리(.yellow)에 order 를 지정해 맨 뒤로 보내세요.',
    properties: ['order'],
  ),
  Level(
    name: 'order 2',
    title: 'order ②',
    board: 'gggrg',
    base: {},
    solution: {'order': '-1'},
    targetChildren: [3],
    selectorLabel: '.red',
    before: '#pond {\n  display: flex;\n}\n\n.red {',
    instructions: '음수 order 도 가능합니다. 빨간 개구리(.red)를 맨 앞으로 보내세요.',
    properties: ['order'],
  ),
  Level(
    name: 'align-self 1',
    title: 'align-self ①',
    board: 'ggygg',
    base: {'align-items': 'flex-start'},
    solution: {'align-self': 'flex-end'},
    targetChildren: [2],
    selectorLabel: '.yellow',
    before: '#pond {\n  display: flex;\n  align-items: flex-start;\n}\n\n.yellow {',
    instructions:
        'align-self 는 한 아이템만 따로 세로 정렬합니다(align-items 무시).\n\n'
        '노란 개구리(.yellow)만 아래쪽 연잎으로 내려보내세요.',
    properties: ['align-self'],
  ),
  Level(
    name: 'align-self 2',
    title: 'align-self ②',
    board: 'ygygg',
    base: {'align-items': 'flex-start'},
    solution: {'align-self': 'flex-end', 'order': '2'},
    targetChildren: [0, 2],
    selectorLabel: '.yellow',
    before: '#pond {\n  display: flex;\n  align-items: flex-start;\n}\n\n.yellow {',
    instructions: 'order 와 align-self 를 함께 써서 노란 개구리들을 연잎으로 옮기세요.',
    properties: ['align-self', 'order'],
  ),
  Level(
    name: 'flex-wrap 1',
    title: 'flex-wrap ①',
    board: 'ygggggr',
    solution: {'flex-wrap': 'wrap'},
    before: '#pond {\n  display: flex;',
    instructions:
        'flex-wrap 은 한 줄에 다 못 들어가는 아이템을 다음 줄로 넘깁니다.\n'
        '• nowrap: 줄바꿈 안 함 (기본)\n'
        '• wrap: 넘치면 아래로\n'
        '• wrap-reverse: 넘치면 위로\n\n'
        '개구리들을 여러 줄로 펼쳐 연잎에 올리세요.',
    properties: ['flex-wrap'],
  ),
  Level(
    name: 'flex-wrap 2',
    title: 'flex-wrap ②',
    board: 'gggggrrrrryyyyy',
    solution: {'flex-direction': 'column', 'flex-wrap': 'wrap'},
    before: '#pond {\n  display: flex;',
    instructions: 'flex-direction 과 flex-wrap 을 함께 사용해 격자 모양으로 배치해 보세요.',
    properties: ['flex-direction', 'flex-wrap'],
  ),
  Level(
    name: 'flex-flow 1',
    title: 'flex-flow ①',
    board: 'gggggrrrrryyyyy',
    solution: {'flex-flow': 'column wrap'},
    before: '#pond {\n  display: flex;',
    instructions:
        'flex-flow 는 flex-direction 과 flex-wrap 을 한 번에 쓰는 단축 속성입니다.\n\n'
        '예) flex-flow: column wrap;',
    properties: ['flex-flow'],
  ),
  Level(
    name: 'align-content 1',
    title: 'align-content ①',
    board: 'ggggggggggggggg',
    base: {'flex-wrap': 'wrap'},
    solution: {'align-content': 'flex-start'},
    before: '#pond {\n  display: flex;\n  flex-wrap: wrap;',
    instructions:
        'align-content 는 여러 줄(행) 전체를 세로로 정렬합니다. (한 줄일 땐 효과 없음)\n'
        '• flex-start, flex-end, center, space-between, space-around\n\n'
        '모든 줄을 위쪽으로 모으세요.',
    properties: ['align-content'],
  ),
  Level(
    name: 'align-content 2',
    title: 'align-content ②',
    board: 'ggggggggggggggg',
    base: {'flex-wrap': 'wrap'},
    solution: {'align-content': 'flex-end'},
    before: '#pond {\n  display: flex;\n  flex-wrap: wrap;',
    instructions: '이번엔 모든 줄을 아래쪽으로 모으세요.',
    properties: ['align-content'],
  ),
  Level(
    name: 'align-content 3',
    title: 'align-content ③',
    board: 'rgggyrgggyrgggy',
    base: {'flex-wrap': 'wrap'},
    solution: {'flex-direction': 'column-reverse', 'align-content': 'center'},
    before: '#pond {\n  display: flex;\n  flex-wrap: wrap;',
    instructions: 'flex-direction 과 align-content 를 조합하는 단계입니다.',
    properties: ['flex-direction', 'align-content'],
  ),
  Level(
    name: 'align-content 4',
    title: 'align-content ④ (마지막)',
    board: 'rggggyy',
    solution: {
      'flex-direction': 'column-reverse',
      'flex-wrap': 'wrap-reverse',
      'align-content': 'space-between',
      'justify-content': 'center',
    },
    before: '#pond {\n  display: flex;',
    instructions:
        '마지막 도전! 지금까지 배운 모든 속성을 조합해야 합니다. '
        '개구리를 모두 연잎으로 안내하면 게임 클리어! 🎉',
    properties: [
      'flex-direction',
      'flex-wrap',
      'align-content',
      'justify-content',
    ],
  ),
];
