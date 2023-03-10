import 'feature.dart';
import 'stitch.dart';

double _planarRingArea(List<List<Object?>> ring) {
  var i = -1, n = ring.length, area = 0.0;
  List<Object?> a, b = ring[n - 1];
  while (++i < n) {
    a = b;
    b = ring[i];
    area += (a[0] as num) * (b[1] as num) - (a[1] as num) * (b[0] as num);
  }
  return area.abs(); // Note: doubled area!
}

/// Returns the GeoJSON MultiPolygon geometry object representing the union for
/// the specified array of Polygon and MultiPolygon [objects] in the given
/// [topology].
///
/// Interior borders shared by adjacent polygons are removed. See
/// [Merging States](https://bl.ocks.org/mbostock/5416405) for an example. The
/// returned geometry is a shallow copy of the source [objects]: they may share
/// coordinates.
Map<String?, dynamic> merge(
        Map<String?, dynamic> topology, List<Map<String?, dynamic>> objects) =>
    obj(topology, mergeArcs(topology, objects))!;

/// Equivalent to [merge], but returns TopoJSON rather than GeoJSON.
///
/// The returned geometry is a shallow copy of the source [objects]: they may
/// share coordinates.
Map<String?, dynamic> mergeArcs(
    Map<String?, dynamic> topology, List<Map<String?, dynamic>> objects) {
  var polygonsByArc = <int, List<_Polygon>>{},
      polygons = <_Polygon>[],
      groups = <List<_Polygon>>[];

  void extract(_Polygon polygon) {
    polygon.forEach((ring) {
      for (var arc in ring) {
        (polygonsByArc[arc = arc < 0 ? ~arc : arc] ?? (polygonsByArc[arc] = []))
            .add(polygon);
      }
    });
    polygons.add(polygon);
  }

  void geometry(Map<String?, dynamic> o) {
    switch (o["type"]) {
      case "GeometryCollection":
        (o["geometries"] as List<Map<String?, dynamic>>).forEach(geometry);
        break;
      case "Polygon":
        extract(_Polygon(o["arcs"] as List<List<int>>));
        break;
      case "MultiPolygon":
        for (final v in (o["arcs"] as List<List<List<int>>>)) {
          extract(_Polygon(v));
        }
        break;
    }
  }

  objects.forEach(geometry);

  double area(List<int> ring) => _planarRingArea((obj(topology, {
        "type": "Polygon",
        "arcs": [ring]
      })!["coordinates"] as List<List<List<Object?>>>)[0]);

  for (var polygon in polygons) {
    if (polygon.c == null) {
      var group = <_Polygon>[], neighbors = [polygon];
      polygon.c = 1;
      groups.add(group);
      while (neighbors.isNotEmpty) {
        polygon = neighbors.removeLast();
        group.add(polygon);
        polygon.forEach((ring) {
          for (final arc in ring) {
            for (final polygon in polygonsByArc[arc < 0 ? ~arc : arc]!) {
              if (polygon.c == null) {
                polygon.c = 1;
                neighbors.add(polygon);
              }
            }
          }
        });
      }
    }
  }

  for (final polygon in polygons) {
    polygon.c = null;
  }

  return {
    "type": "MultiPolygon",
    "arcs": groups
        .map((polygons) {
          var arcs = <int>[];
          int n;

          // Extract the exterior (unique) arcs.
          for (final polygon in polygons) {
            polygon.forEach((ring) {
              for (final arc in ring) {
                if (polygonsByArc[arc < 0 ? ~arc : arc]!.length < 2) {
                  arcs.add(arc);
                }
              }
            });
          }

          // Stitch the arcs into one or more rings.
          var stichedArcs = stitch(topology, arcs);

          // If more than one ring is returned,
          // at most one of these rings can be the exterior;
          // choose the one with the greatest absolute area.
          if ((n = stichedArcs.length) > 1) {
            double ki;
            List<int> t;
            for (var i = 1, k = area(stichedArcs[0]); i < n; ++i) {
              if ((ki = area(stichedArcs[i])) > k) {
                t = stichedArcs[0];
                stichedArcs[0] = stichedArcs[i];
                stichedArcs[i] = t;
                k = ki;
              }
            }
          }

          return stichedArcs;
        })
        .where((arcs) => arcs.isNotEmpty)
        .toList()
  };
}

class _Polygon {
  int? c;
  final List<List<int>> _values;

  _Polygon(this._values);

  void add(List<int> v) {
    _values.add(v);
  }

  void forEach(void Function(List<int>) action) {
    _values.forEach(action);
  }
}
