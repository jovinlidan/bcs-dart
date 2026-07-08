import 'package:bcs_dart/legacy_bcs.dart';
import 'package:bcs_dart/utils.dart';
import 'package:test/test.dart';

void main() {
  dynamic serde(LegacyBCS bcs, type, data) {
    final ser = bcs.ser(type, data).hex();
    final de = bcs.de(type, ser, Encoding.hex);
    return de;
  }

  group("BCS: Config", () {
    test("should work wtesth Rust config", () {
      final bcs = LegacyBCS(getRustConfig());
      final value = ["beep", "boop", "beep"];
      expect(serde(bcs, "Vec<string>", value), value);
    });

    test("should work wtesth Sui Move config", () {
      final bcs = LegacyBCS(getSuiMoveConfig());
      final value = ["beep", "boop", "beep"];
      expect(serde(bcs, "vector<string>", value), value);
    });

    test("should fork config", () {
      final bcsV1 = LegacyBCS(getSuiMoveConfig());
      bcsV1.registerStructType("User", {"name": "string"});

      final bcsV2 = LegacyBCS.fromBCS(bcsV1);
      bcsV2.registerStructType("Worker", {"user": "User", "experience": "u64"});

      expect(bcsV1.hasType("Worker"), false);
      expect(bcsV2.hasType("Worker"), true);
    });

    test("should work wtesth custom config", () {
      final bcs = LegacyBCS(BcsConfig(
          genericSeparators: ("[", "]"),
          addressLength: 1,
          addressEncoding: Encoding.hex,
          vectorType: "array",
          types: BcsConfigTypes(structs: {
            "StesteConfig": {"tags": "array[Name]"},
          }, enums: {
            "Option[T]": {"none": null, "some": "T"},
          }, aliases: {
            "Name": 'string'
          })));

      final value_1 = {
        "tags": ["beep", "boop", "beep"]
      };
      expect(serde(bcs, "StesteConfig", value_1), value_1);

      final value_2 = {
        "some": ["what", "do", "we", "test"]
      };
      expect(serde(bcs, "Option[array[string]]", value_2), value_2);
    });
  });
}
