import 'bisect.dart';

/// Returns an array representing the set of neighboring objects for each object
/// in the specified [objects] array.
///
/// The returned array has the same number of elements as the input array; each
/// element *i* in the returned array is the array of indexes for neighbors of
/// object *i* in the input array. For example, if the specified objects array
/// contains the features *foo* and *bar*, and these features are neighbors,
/// the returned array will be \[\[1\], \[0\]\], indicating that *foo* is a
/// neighbor of *bar* and *vice versa*. Each array of neighbor indexes for each
/// object is guaranteed to be sorted in ascending order.
///
/// For a practical example, see the
/// [world map](https://bl.ocks.org/mbostock/4180634) with topological coloring.
List<List<int>> neighbors(List<Map<String?, dynamic>> objects) {
  var indexesByArc = <int, List<int>>{}, // arc index -> array of object indexes
      neighbors = List<List<int>>.generate(objects.length, (_) => []);

  void line(List<int> arcs, int i) {
    for (var a in arcs) {
      if (a < 0) a = ~a;
      var o = indexesByArc[a];
      if (o != null) {
        o.add(i);
      } else {
        indexesByArc[a] = [i];
      }
    }
  }

  void polygon(List<List<int>> arcs, int i) {
    for (final arc in arcs) {
      line(arc, i);
    }
  }

  var geometryType = <String, Function>{
    "LineString": line,
    "MultiLineString": polygon,
    "Polygon": polygon,
    "MultiPolygon": (arcs, i) => arcs.forEach((arc) => polygon(arc, i))
  };

  void geometry(int i, Map<String?, dynamic> o) {
    if (o["type"] == "GeometryCollection") {
      for (final o in (o["geometries"] as List<Map<String?, dynamic>>)) {
        geometry(i, o);
      }
    } else if (geometryType.containsKey(o["type"])) {
      geometryType[(o["type"] as String)]!((o["arcs"] as List), i);
    }
  }

  objects.asMap().forEach(geometry);

  indexesByArc.forEach((i, indexes) {
    for (var m = indexes.length, j = 0; j < m; ++j) {
      for (var k = j + 1; k < m; ++k) {
        var ij = indexes[j], ik = indexes[k];
        List<int> n;
        if ((i = bisect(n = neighbors[ij], ik)) == n.length || n[i] != ik) {
          n.insert(i, ik);
        }
        if ((i = bisect(n = neighbors[ik], ij)) == n.length || n[i] != ij) {
          n.insert(i, ij);
        }
      }
    }
  });

  return neighbors;
}
