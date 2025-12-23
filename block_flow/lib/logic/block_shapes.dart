class BlockShape {
  final String id;
  final List<List<int>> cells; // 1=filled, 0=empty
  const BlockShape(this.id, this.cells);

  int get h => cells.length;
  int get w => cells.first.length;
  int get filledCount =>
      cells.fold(0, (a, r) => a + r.where((v) => v == 1).length);
}

const List<BlockShape> kShapes = [
  // single / line
  BlockShape('dot', [
    [1]
  ]),
  BlockShape('i2', [
    [1, 1]
  ]),
  BlockShape('i3', [
    [1, 1, 1]
  ]),
  BlockShape('i4', [
    [1, 1, 1, 1]
  ]),

  // squares
  BlockShape('o2', [
    [1, 1],
    [1, 1],
  ]),

  // L shapes
  BlockShape('l3', [
    [1, 0],
    [1, 1],
  ]),
  BlockShape('l4', [
    [1, 0],
    [1, 0],
    [1, 1],
  ]),

  // T
  BlockShape('t', [
    [1, 1, 1],
    [0, 1, 0],
  ]),

  // Z
  BlockShape('z', [
    [1, 1, 0],
    [0, 1, 1],
  ]),
];
