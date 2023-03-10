import 'feature.dart';
import 'stitch.dart';

/// Returns the GeoJSON MultiLineString geometry object representing the mesh
/// for the specified [object] in the given [topology].
///
/// This is useful for rendering strokes in complicated objects efficiently, as
/// edges that are shared by multiple features are only stroked once. If
/// [object] is not specified, a mesh of the entire topology is returned. The
/// returned geometry is a shallow copy of the source [object]: they may share
/// coordinates.
///
/// An optional [filter] function may be specified to prune arcs from the
/// returned mesh using the topology. The filter function is called once for
/// each candidate arc and takes two arguments, *a* and *b*, two geometry
/// objects that share that arc. Each arc is only included in the resulting mesh
/// if the filter function returns true. For typical map topologies the
/// geometries *a* and *b* are adjacent polygons and the candidate arc is their
/// boundary. If an arc is only used by a single geometry then *a* and *b* are
/// identical. This property is useful for separating interior and exterior
/// boundaries; an easy way to produce a mesh of interior boundaries is:
///
/// ```dart
/// var interiors = mesh(topology, object, (a, b) => a != b);
/// ```
///
/// See this [county choropleth](https://bl.ocks.org/mbostock/4060606) for
/// example. Note: the *a* and *b* objects are TopoJSON objects (pulled directly
/// from the topology), and not automatically converted to GeoJSON features as
/// by [feature].
Map<String?, dynamic> mesh(Map<String?, dynamic> topology,
        [Map<String?, dynamic>? object, filter]) =>
    obj(topology, meshArcs(topology, object, filter))!;

/// Equivalent to [mesh], but returns TopoJSON rather than GeoJSON.
///
/// The returned geometry is a shallow copy of the source [object]: they may
/// share scoordinates.
Map<String?, dynamic> meshArcs(Map<String?, dynamic> topology,
    [Map<String?, dynamic>? object,
    bool Function(Map<String?, dynamic>, Map<String?, dynamic>)? filter]) {
  List<int> arcs;
  if (object != null) {
    arcs = _extractArcs(topology, object, filter);
  } else {
    arcs = List.generate(
        (topology["arcs"] as List<List<List<num>>>).length, (i) => i);
  }
  return {"type": "MultiLineString", "arcs": stitch(topology, arcs)};
}

List<int> _extractArcs(
    Map<String?, dynamic> topology, Map<String?, dynamic> object,
    [bool Function(Map<String?, dynamic>, Map<String?, dynamic>)? filter]) {
  var arcs = <int>[], geomsByArc = <int, List<Map<String?, dynamic>>>{};
  late Map<String?, dynamic> geom;

  void extract0(int i) {
    var j = i < 0 ? ~i : i;
    (geomsByArc[j] ?? (geomsByArc[j] = [])).add({"i": i, "g": geom});
  }

  void extract1(List<int> arcs) {
    arcs.forEach(extract0);
  }

  void extract2(List<List<int>> arcs) {
    arcs.forEach(extract1);
  }

  void extract3(List<List<List<int>>> arcs) {
    arcs.forEach(extract2);
  }

  void geometry(Map<String?, dynamic> o) {
    switch ((geom = o)["type"] as String?) {
      case "GeometryCollection":
        (o["geometries"] as List<Map<String?, dynamic>>).forEach(geometry);
        break;
      case "LineString":
        extract1(o["arcs"] as List<int>);
        break;
      case "MultiLineString":
      case "Polygon":
        extract2(o["arcs"] as List<List<int>>);
        break;
      case "MultiPolygon":
        extract3(o["arcs"] as List<List<List<int>>>);
        break;
    }
  }

  geometry(object);

  geomsByArc.forEach(filter == null
      ? (_, geoms) {
          arcs.add(geoms[0]["i"] as int);
        }
      : (_, geoms) {
          if (filter(geoms[0]["g"] as Map<String?, dynamic>,
              geoms[geoms.length - 1]["g"] as Map<String?, dynamic>)) {
            arcs.add(geoms[0]["i"] as int);
          }
        });

  return arcs;
}
