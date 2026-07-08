import 'dart:typed_data';
import 'package:test/test.dart';
import 'package:bcs_dart/bcs.dart';
import 'package:bcs_dart/uleb.dart';

void main() {
  group('map sorts entries by serialized key bytes', () {
    test(
        'single-byte keys serialize in canonical order regardless of insertion',
        () {
      final t = Bcs.map(Bcs.u8(), Bcs.u8());
      // Inserted out of order; must serialize sorted by key: len=2, (1,10), (2,20)
      final bytes = t.serialize({2: 20, 1: 10}).toBytes();
      expect(bytes, equals(Uint8List.fromList([2, 1, 10, 2, 20])));
    });

    test('round-trips back to a map', () {
      final t = Bcs.map(Bcs.u8(), Bcs.string());
      final bytes = t.serialize({3: 'c', 1: 'a', 2: 'b'}).toBytes();
      final back = t.parse(bytes);
      expect(back[1], 'a');
      expect(back[2], 'b');
      expect(back[3], 'c');
    });

    test('multi-byte (u16) keys sort by big-endian byte order on the wire', () {
      // u16 is little-endian on the wire, so compareBcsBytes orders by LE bytes.
      final t = Bcs.map(Bcs.u16(), Bcs.u8());
      final bytes = t.serialize({256: 1, 1: 2}).toBytes();
      // key 1 -> LE [1,0]; key 256 -> LE [0,1]; sorted: [0,1] < [1,0]
      // so 256 comes first: len=2, key256(00 01) val(01), key1(01 00) val(02)
      expect(bytes, equals(Uint8List.fromList([2, 0, 1, 1, 1, 0, 2])));
    });
  });

  group('compareBcsBytes', () {
    test('lexicographic with length tie-break', () {
      expect(compareBcsBytes(u8(1), u8(2)) < 0, true);
      expect(compareBcsBytes(u8(2), u8(1)) > 0, true);
      expect(
          compareBcsBytes(Uint8List.fromList([1]), Uint8List.fromList([1, 0])) <
              0,
          true);
      expect(compareBcsBytes(u8(1), u8(1)), 0);
    });
  });

  group('hex validation', () {
    test('rejects sign/whitespace/non-hex', () {
      expect(() => fromHEX('a-b'), throwsA(isA<FormatException>()));
      expect(() => fromHEX('+a'), throwsA(isA<FormatException>()));
      expect(() => fromHEX('GG'), throwsA(isA<FormatException>()));
      expect(() => fromHEX('12 34'), throwsA(isA<FormatException>()));
    });

    test('valid hex still round-trips', () {
      expect(fromHEX('0a'), equals(Uint8List.fromList([10])));
      expect(fromHEX('0x01'), equals(Uint8List.fromList([1])));
      expect(fromHEX('111'), equals(Uint8List.fromList([1, 17])));
    });
  });

  group('byteVector', () {
    test('produces the same bytes as vector(u8())', () {
      final bv = Bcs.byteVector().serialize([1, 2, 3]).toBytes();
      final vu8 = Bcs.vector(Bcs.u8()).serialize([1, 2, 3]).toBytes();
      expect(bv, equals(Uint8List.fromList([3, 1, 2, 3])));
      expect(bv, equals(vu8));
    });

    test('round-trips', () {
      final t = Bcs.byteVector();
      expect(t.parse(t.serialize([9, 8, 7]).toBytes()),
          equals(Uint8List.fromList([9, 8, 7])));
    });
  });

  group('isSerializedBcs type guard', () {
    test('true for SerializedBcs, false otherwise', () {
      expect(isSerializedBcs(Bcs.u8().serialize(1)), true);
      expect(isSerializedBcs(5), false);
      expect(isSerializedBcs(null), false);
    });
  });

  group('uleb decode guards', () {
    test('throws on truncated continuation byte', () {
      expect(() => ulebDecode(Uint8List.fromList([0x80])),
          throwsA(isA<FormatException>()));
    });
  });
}

Uint8List u8(int v) => Uint8List.fromList([v]);
