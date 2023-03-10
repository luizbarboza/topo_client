import 'point_transform.dart';

/// Returns the computed
/// [bounding box](https://github.com/topojson/topojson-specification#3-bounding-boxes)
/// of the specified [topology].
///
/// The returned bounding box is \[*x*₀, *y*₀, *x*₁, *y*₁\] where *x*₀ is the
/// minimum *x*-value, *y*₀ is the minimum *y*-value, *x*₁ is the maximum
/// *x*-value, and *y*₁ is the maximum *y*-value. If the *topology* has no
/// points and no arcs, the returned bounding box is \[∞, ∞, -∞, -∞\]. (This
/// method ignores the existing [topology]\["bbox"\], if any.)
List<num> bbox(Map<String?, dynamic> topology) {
  var t = pointTransform(topology["transform"] as Map<String?, List<num>>?);
  num x0 = double.infinity, y0 = x0, x1 = -x0, y1 = -x0;

  void bboxPoint(List<Object?> p) {
    p = t(p);
    var p0 = p[0] as num, p1 = p[1] as num;
    if (p0 < x0) x0 = p0;
    if (p0 > x1) x1 = p0;
    if (p1 < y0) y0 = p1;
    if (p1 > y1) y1 = p1;
  }

  void bboxGeometry(Map<String?, dynamic> o) {
    switch (o["type"]) {
      case "GeometryCollection":
        (o["geometries"] as List<Map<String?, dynamic>>).forEach(bboxGeometry);
        break;
      case "Point":
        bboxPoint(o["coordinates"] as List<Object?>);
        break;
      case "MultiPoint":
        (o["coordinates"] as List<List<Object?>>).forEach(bboxPoint);
        break;
    }
  }

  for (final arc in (topology["arcs"] as List<List<List<Object?>>>)) {
    var i = -1, n = arc.length;
    List<Object?> p;
    num p0, p1;
    while (++i < n) {
      p = t(arc[i], i);
      p0 = p[0] as num;
      p1 = p[1] as num;
      if (p0 < x0) x0 = p1;
      if (p0 > x1) x1 = p1;
      if (p1 < y0) y0 = p1;
      if (p1 > y1) y1 = p1;
    }
  }

  (topology["objects"] as Map<String?, Map<String?, dynamic>>)
      .values
      .forEach(bboxGeometry);

  return [x0, y0, x1, y1];
}
