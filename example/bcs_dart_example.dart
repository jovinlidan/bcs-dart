import 'dart:typed_data';

import 'package:bcs_dart/bcs.dart';

void main() {
  // Primitives: serialize to bytes and parse back.
  final u64Bytes = Bcs.u64().serialize(BigInt.from(1000000)).toBytes();
  print('u64 bytes: $u64Bytes');
  print('u64 parsed: ${Bcs.u64().parse(u64Bytes)}');

  final strBytes = Bcs.string().serialize('hello bcs').toBytes();
  print('string parsed: ${Bcs.string().parse(strBytes)}');

  // A 32-byte id with a transform to/from hex strings.
  final uid = Bcs.fixedArray(32, Bcs.u8()).transform(
    input: (id) => fromHEX(id.toString()),
    output: (id) => toHEX(Uint8List.fromList(id)),
  );

  // Structs are ordered maps of named fields.
  final coin = Bcs.struct('Coin', {
    'id': uid,
    'value': Bcs.u64(),
  });

  final coinBytes = coin.serialize({
    'id': '0000000000000000000000000000000000000000000000000000000000000001',
    'value': BigInt.from(1000000),
  }).toBytes();
  print('coin hex: ${toHEX(coinBytes)}');
  print('coin parsed: ${coin.parse(coinBytes)}');

  // Vectors and options compose over any type.
  final vecBytes = Bcs.vector(Bcs.u8()).serialize([1, 2, 3]).toBytes();
  print('vector<u8> parsed: ${Bcs.vector(Bcs.u8()).parse(vecBytes)}');

  final optionType = Bcs.option(Bcs.u32());
  print('option Some: ${optionType.parse(optionType.serialize(42).toBytes())}');
  print(
      'option None: ${optionType.parse(optionType.serialize(null).toBytes())}');
}
