import 'point_transform.dart';
import 'reverse.dart';

/// Returns the GeoJSON Feature or FeatureCollection for the specified [object]
/// in the given [topology].
///
/// If the object is a GeometryCollection, a FeatureCollection is returned, and
/// each geometry in the collection is mapped to a Feature. Otherwise, a Feature
/// is returned. The returned feature is a shallow copy of the source [object]:
/// they may share identifiers, bounding boxes, properties and coordinates.
///
/// Some examples:
///
/// * A point is mapped to a feature with a geometry object of type “Point”.
/// * Likewise for line strings, polygons, and other simple geometries.
/// * A null geometry object (of type null in TopoJSON) is mapped to a feature
/// with a null geometry object.
/// * A geometry collection of points is mapped to a feature collection of
/// features, each with a point geometry.
/// * A geometry collection of geometry collections is mapped to a feature
/// collection of features, each with a geometry collection.
Map<String?, dynamic> feature(
        Map<String?, dynamic> topology, Map<String?, dynamic> object) =>
    (object["type"] as String?) == "GeometryCollection"
        ? {
            "type": "FeatureCollection",
            "features": (object["geometries"] as List<Map<String?, dynamic>>)
                .map((o) => _feature(topology, o))
                .toList()
          }
        : _feature(topology, object);

Map<String?, dynamic> _feature(
    Map<String?, dynamic> topology, Map<String?, dynamic> o) {
  var id = o["id"] as String?,
      bbox = o["bbox"] as List<List<num>>?,
      properties = o["properties"] as Map? ?? {},
      geometry = obj(topology, o);
  return id == null && bbox == null
      ? {"type": "Feature", "properties": properties, "geometry": geometry}
      : bbox == null
          ? {
              "type": "Feature",
              "id": id,
              "properties": properties,
              "geometry": geometry
            }
          : {
              "type": "Feature",
              "id": id,
              "bbox": bbox,
              "properties": properties,
              "geometry": geometry
            };
}

Map<String?, dynamic>? obj(
    Map<String?, dynamic> topology, Map<String?, dynamic> o) {
  var t = pointTransform(topology["transform"] as Map<String?, List<num>>?),
      arcs = topology["arcs"] as List<List<List<Object?>>>;

  void arc(int i, List<List<Object?>> points) {
    if (points.isNotEmpty) points.removeLast();
    var a = arcs[i < 0 ? ~i : i], n = a.length;
    for (var k = 0; k < n; ++k) {
      points.add(t(a[k], k));
    }
    if (i < 0) reverse(points, n);
  }

  List<Object?> point(List<Object?> p) => t(p);

  List<List<Object?>> line(List<int> arcs) {
    var points = <List<Object?>>[];
    for (var i = 0, n = arcs.length; i < n; ++i) {
      arc(arcs[i], points);
    }
    if (points.length < 2) {
      points.add(points[0]); // This should never happen per the specification.
    }
    return points;
  }

  List<List<Object?>> ring(List<int> arcs) {
    var points = line(arcs);
    while (points.length < 4) {
      points.add(points[0]); // This may happen if an arc has only two points.
    }
    return points;
  }

  List<List<List<Object?>>> polygon(List<List<int>> arcs) =>
      arcs.map(ring).toList();

  Map<String?, dynamic>? geometry(Map<String?, dynamic> o) {
    String? type = o["type"];
    List coordinates;
    switch (type) {
      case "GeometryCollection":
        return {
          "type": type,
          "geometries": (o["geometries"] as List<Map<String?, dynamic>>)
              .map(geometry)
              .toList()
        };
      case "Point":
        coordinates = point(o["coordinates"] as List<Object?>);
        break;
      case "MultiPoint":
        coordinates =
            (o["coordinates"] as List<List<Object?>>).map(point).toList();
        break;
      case "LineString":
        coordinates = line(o["arcs"] as List<int>);
        break;
      case "MultiLineString":
        coordinates = (o["arcs"] as List<List<int>>).map(line).toList();
        break;
      case "Polygon":
        coordinates = polygon(o["arcs"] as List<List<int>>);
        break;
      case "MultiPolygon":
        coordinates =
            (o["arcs"] as List<List<List<int>>>).map(polygon).toList();
        break;
      default:
        return null;
    }
    return {"type": type, "coordinates": coordinates};
  }

  return geometry(o);
}
