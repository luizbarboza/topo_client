import 'bbox.dart';
import 'point_untransform.dart';

/// Returns a shallow copy of the specified [topology] with
/// [quantized and delta-encoded](https://github.com/topojson/topojson-specification#213-arcs)
/// arcs according to the specified
/// [transform] object.
///
/// If the [topology] is already quantized, an error is thrown.
Map<String?, dynamic> quantize(
    Map<String?, dynamic> topology, Map<String?, List<num>> transform) {
  if (topology.containsKey("transform")) throw StateError("already quantized");

  var t = untransformPoint(transform),
      box = (topology["bbox"] as List<num>? ?? bbox(topology)),
      inputs = (topology["objects"] as Map<String?, Map<String?, dynamic>>),
      outputs = <String, Map<String?, dynamic>>{};

  List<Object?> quantizePoint(List<Object?> point) => t(point);

  Map<String?, dynamic> quantizeGeometry(Map<String?, dynamic> input) {
    Map<String?, dynamic> output;
    switch ((input["type"] as String)) {
      case "GeometryCollection":
        output = {
          "type": "GeometryCollection",
          "geometries": (input["geometries"] as List<Map<String?, dynamic>>)
              .map(quantizeGeometry)
              .toList()
        };
        break;
      case "Point":
        output = {
          "type": "Point",
          "coordinates": quantizePoint(input["coordinates"] as List<Object?>)
        };
        break;
      case "MultiPoint":
        output = {
          "type": "MultiPoint",
          "coordinates":
              (input["coordinates"] as List<List<Object?>>).map(quantizePoint)
        };
        break;
      default:
        return input;
    }
    if (input["id"] != null) output["id"] = input["id"];
    if (input["bbox"] != null) output["bbox"] = input["bbox"];
    if (input["properties"] != null) output["properties"] = input["properties"];
    return output;
  }

  List<List<Object?>> quantizeArc(List<List<Object?>> input) {
    var i = 0, n = input.length, output = <List<Object?>>[];
    List<Object?> p;
    output.add(t(input[0], 0));
    while (++i < n) {
      if ((p = t(input[i], i))[0] != 0 || p[1] != 0) {
        output.add(p); // non-coincident points
      }
    }
    if (output.length == 1) {
      output.add([0, 0]); // an arc must have at least two points
    }
    return output;
  }

  inputs.forEach((key, geometry) {
    outputs[key!] = quantizeGeometry(geometry);
  });

  return {
    "type": "Topology",
    "bbox": box,
    "transform": transform,
    "objects": outputs,
    "arcs": (topology["arcs"] as List<List<List<Object?>>>)
        .map(quantizeArc)
        .toList()
  };
}
