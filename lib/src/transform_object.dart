import 'bbox.dart';

/// Returns a transform object computed using the bounding box of the topology.
///
/// The quantization number [n] must be a positive integer greater than one
/// which determines the maximum number of expressible values per dimension in
/// the resulting quantized coordinates; typically, a power of ten is chosen
/// such as 1e4, 1e5 or 1e6. If the [topology] does not already have a
/// [topology]\["bbox"\], one is computed using [bbox]/.
Map<String?, List<num>> transform(Map<String?, dynamic> topology, num n) {
  List<num> box;
  if (!((n = n.floor()) >= 2)) {
    throw ArgumentError.value(n, "n", "must be ≥2 but received");
  }
  box = topology["bbox"] ?? (topology["bbox"] = bbox(topology));
  var x0 = box[0], y0 = box[1], x1 = box[2], y1 = box[3];
  return {
    "scale": [
      if (x1 - x0 != 0) (x1 - x0) / (n - 1) else 1,
      if (y1 - y0 != 0) (y1 - y0) / (n - 1) else 1
    ],
    "translate": [x0, y0]
  };
}
