## 0.0.1

- Initial version, created by 0xmove.

## 0.0.2

- Refactor BCS.

# 0.0.3

- Fix: Iterate MappedListIterable

# 0.0.4

- Fix: read128/read256 padLeft

# 0.0.5

- Fix: Convert Object to Map

# 0.0.6

- Feat: Register Fixed Array Type

# 0.1.0

- Refactor: version 2

# 0.1.1

- Optimize: Reading Bytes

# 0.1.2

- Fix: remove flutter dependency
- Refactor: minor

# 0.2.0

Synced to `f898c13`.

### Behavior changes

- `Bcs.map` now sorts entries by their serialized key bytes before writing, for canonical key ordering. Maps that were not already in canonical key order now produce different (correct) bytes.
- `Hex.decode` (and `fromHEX`) now reject non-hex input (sign characters, whitespace, other non-`[0-9a-fA-F]` characters) with a `FormatException` instead of silently producing corrupt bytes.

### Fixes

- `BcsWriter.ensureSizeOrGrow` grows the buffer to fit a single write larger than `allocateSize` instead of throwing.
- `ulebDecode` throws on a truncated buffer (continuation bit with no more bytes) and on values exceeding `MAX_SAFE_INTEGER`.
- `Bcs.enumeration` read bounds-checks the variant index and throws a descriptive error for an unknown variant.

### Added

- Top-level `compareBcsBytes` (lexicographic byte comparison).
- `Bcs.byteVector()` — a fast `vector<u8>` that reads/writes raw bytes (same wire bytes as `vector(u8())`).
- `BcsWriter.writeBytes(Uint8List)` bulk write.
- Top-level `isSerializedBcs(Object?)` type guard; `bcs_type.dart` is now re-exported from the `bcs.dart` barrel.
- `BcsType.transform` accepts one-directional transforms (`input`/`output` are now optional).
