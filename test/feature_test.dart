// ignore_for_file: lines_longer_than_80_chars

import 'package:test/test.dart';
import 'package:topo_client/topo_client.dart' as topojson;
import 'package:topo_parse/topo_parse.dart' as topojson;

void main() {
  test("topojson.feature the geometry type is preserved", () {
    var t = simpleTopology({
      "type": "Polygon",
      "arcs": [
        [0]
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"])["geometry"]["type"],
        "Polygon");
  });

  test("topojson.feature Point is a valid geometry type", () {
    var t = simpleTopology({
      "type": "Point",
      "coordinates": [0, 0]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "Point",
        "coordinates": [0, 0]
      }
    });
  });

  test("topojson.feature MultiPoint is a valid geometry type", () {
    var t = simpleTopology({
      "type": "MultiPoint",
      "coordinates": [
        [0, 0]
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "MultiPoint",
        "coordinates": [
          [0, 0]
        ]
      }
    });
  });

  test("topojson.feature LineString is a valid geometry type", () {
    var t = simpleTopology({
      "type": "LineString",
      "arcs": [0]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [0, 0],
          [1, 0],
          [1, 1],
          [0, 1],
          [0, 0]
        ]
      }
    });
  });

  test("topojson.feature MultiLineString is a valid geometry type", () {
    var t = simpleTopology({
      "type": "MultiLineString",
      "arcs": [
        [0]
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "MultiLineString",
        "coordinates": [
          [
            [0, 0],
            [1, 0],
            [1, 1],
            [0, 1],
            [0, 0]
          ]
        ]
      }
    });
  });

  test("topojson.feature line-strings have at least two coordinates", () {
    var t = simpleTopology({
      "type": "LineString",
      "arcs": [3]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [1, 1],
          [1, 1]
        ]
      }
    });
    t = simpleTopology({
      "type": "MultiLineString",
      "arcs": [
        [3],
        [4]
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "MultiLineString",
        "coordinates": [
          [
            [1, 1],
            [1, 1]
          ],
          [
            [0, 0],
            [0, 0]
          ]
        ]
      }
    });
  });

  test("topojson.feature Polygon is a valid feature type", () {
    var t = simpleTopology({
      "type": "Polygon",
      "arcs": [
        [0]
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "Polygon",
        "coordinates": [
          [
            [0, 0],
            [1, 0],
            [1, 1],
            [0, 1],
            [0, 0]
          ]
        ]
      }
    });
  });

  test("topojson.feature MultiPolygon is a valid feature type", () {
    var t = simpleTopology({
      "type": "MultiPolygon",
      "arcs": [
        [
          [0]
        ]
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "MultiPolygon",
        "coordinates": [
          [
            [
              [0, 0],
              [1, 0],
              [1, 1],
              [0, 1],
              [0, 0]
            ]
          ]
        ]
      }
    });
  });

  test("topojson.feature polygons are closed, with at least four coordinates",
      () {
    var topology = <String, dynamic>{
      "type": "Topology",
      "transform": {
        "scale": [1, 1],
        "translate": [0, 0]
      },
      "objects": {
        "foo": {
          "type": "Polygon",
          "arcs": [
            [0]
          ]
        },
        "bar": {
          "type": "Polygon",
          "arcs": [
            [0, 1]
          ]
        }
      },
      "arcs": [
        [
          [0, 0],
          [1, 1]
        ],
        [
          [1, 1],
          [-1, -1]
        ]
      ]
    };
    expect(
        topojson.feature(topology, topology["objects"]["foo"])["geometry"]
            ["coordinates"],
        [
          [
            [0, 0],
            [1, 1],
            [0, 0],
            [0, 0]
          ]
        ]);
    expect(
        topojson.feature(topology, topology["objects"]["bar"])["geometry"]
            ["coordinates"],
        [
          [
            [0, 0],
            [1, 1],
            [0, 0],
            [0, 0]
          ]
        ]);
  });

  test(
      "topojson.feature top-level geometry collections are mapped to feature collections",
      () {
    var t = simpleTopology({
      "type": "GeometryCollection",
      "geometries": [
        {
          "type": "MultiPolygon",
          "arcs": [
            [
              [0]
            ]
          ]
        }
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "properties": {},
          "geometry": {
            "type": "MultiPolygon",
            "coordinates": [
              [
                [
                  [0, 0],
                  [1, 0],
                  [1, 1],
                  [0, 1],
                  [0, 0]
                ]
              ]
            ]
          }
        }
      ]
    });
  });

  test("topojson.feature geometry collections can be nested", () {
    var t = simpleTopology({
      "type": "GeometryCollection",
      "geometries": [
        {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Point",
              "coordinates": [0, 0]
            }
          ]
        }
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "properties": {},
          "geometry": {
            "type": "GeometryCollection",
            "geometries": [
              {
                "type": "Point",
                "coordinates": [0, 0]
              }
            ]
          }
        }
      ]
    });
  });

  test(
      "topojson.feature top-level geometry collections do not have ids, but second-level geometry collections can",
      () {
    var t = simpleTopology({
      "type": "GeometryCollection",
      "id": "collection",
      "geometries": [
        {
          "type": "GeometryCollection",
          "id": "feature",
          "geometries": [
            {
              "type": "Point",
              "id": "geometry",
              "coordinates": [0, 0]
            }
          ]
        }
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "id": "feature",
          "properties": {},
          "geometry": {
            "type": "GeometryCollection",
            "geometries": [
              {
                "type": "Point",
                "coordinates": [0, 0]
              }
            ]
          }
        }
      ]
    });
  });

  test(
      "topojson.feature top-level geometry collections do not have properties, but second-level geometry collections can",
      () {
    var t = simpleTopology({
      "type": "GeometryCollection",
      "properties": {"collection": true},
      "geometries": [
        {
          "type": "GeometryCollection",
          "properties": {"feature": true},
          "geometries": [
            {
              "type": "Point",
              "properties": {"geometry": true},
              "coordinates": [0, 0]
            }
          ]
        }
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"]), {
      "type": "FeatureCollection",
      "features": [
        {
          "type": "Feature",
          "properties": {"feature": true},
          "geometry": {
            "type": "GeometryCollection",
            "geometries": [
              {
                "type": "Point",
                "coordinates": [0, 0]
              }
            ]
          }
        }
      ]
    });
  });

  test("topojson.feature the object id is promoted to feature id", () {
    var t = simpleTopology({
      "id": "foo",
      "type": "Polygon",
      "arcs": [
        [0]
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"])["id"], "foo");
  });

  test(
      "topojson.feature any object properties are promoted to feature properties",
      () {
    var t = simpleTopology({
      "type": "Polygon",
      "properties": {"color": "orange", "size": 42},
      "arcs": [
        [0]
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"])["properties"],
        {"color": "orange", "size": 42});
  });

  test("topojson.feature the object id is optional", () {
    var t = simpleTopology({
      "type": "Polygon",
      "arcs": [
        [0]
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"])["id"], isNull);
  });

  test("topojson.feature object properties are created if missing", () {
    var t = simpleTopology({
      "type": "Polygon",
      "arcs": [
        [0]
      ]
    });
    expect(topojson.feature(t, t["objects"]["foo"])["properties"], {});
  });

  test("topojson.feature arcs are converted to coordinates", () {
    var t = simpleTopology({
      "type": "Polygon",
      "arcs": [
        [0]
      ]
    });
    expect(
        topojson.feature(t, t["objects"]["foo"])["geometry"]["coordinates"], [
      [
        [0, 0],
        [1, 0],
        [1, 1],
        [0, 1],
        [0, 0]
      ]
    ]);
  });

  test("topojson.feature negative arc indexes indicate reversed coordinates",
      () {
    var t = simpleTopology({
      "type": "Polygon",
      "arcs": [
        [~0]
      ]
    });
    expect(
        topojson.feature(t, t["objects"]["foo"])["geometry"]["coordinates"], [
      [
        [0, 0],
        [0, 1],
        [1, 1],
        [1, 0],
        [0, 0]
      ]
    ]);
  });

  test(
      "topojson.feature when multiple arc indexes are specified, coordinates are stitched together",
      () {
    var t = simpleTopology({
      "type": "LineString",
      "arcs": [1, 2]
    });
    expect(
        topojson.feature(t, t["objects"]["foo"])["geometry"]["coordinates"], [
      [0, 0],
      [1, 0],
      [1, 1],
      [0, 1],
      [0, 0]
    ]);
    t = simpleTopology({
      "type": "Polygon",
      "arcs": [
        [~2, ~1]
      ]
    });
    expect(
        topojson.feature(t, t["objects"]["foo"])["geometry"]["coordinates"], [
      [
        [0, 0],
        [0, 1],
        [1, 1],
        [1, 0],
        [0, 0]
      ]
    ]);
  });

  test(
      "topojson.feature unknown geometry types are converted to null geometries",
      () {
    var topology = topojson.parseObject({
      "type": "Topology",
      "transform": {
        "scale": [1, 1],
        "translate": [0, 0]
      },
      "objects": {
        "foo": {"id": "foo"},
        "bar": {
          "type": "Invalid",
          "properties": {"bar": 2}
        },
        "baz": {
          "type": "GeometryCollection",
          "geometries": [
            {"type": "Unknown", "id": "unknown"}
          ]
        }
      },
      "arcs": []
    });
    expect(topojson.feature(topology, topology["objects"]["foo"]),
        {"type": "Feature", "id": "foo", "properties": {}, "geometry": null});
    expect(topojson.feature(topology, topology["objects"]["bar"]), {
      "type": "Feature",
      "properties": {"bar": 2},
      "geometry": null
    });
    expect(topojson.feature(topology, topology["objects"]["baz"]), {
      "type": "FeatureCollection",
      "features": [
        {"type": "Feature", "id": "unknown", "properties": {}, "geometry": null}
      ]
    });
  });

  test("topojson.feature preserves additional dimensions in Point geometries",
      () {
    var t = topojson.parseObject({
      "type": "Topology",
      "objects": {
        "point": {
          "type": "Point",
          "coordinates": [1, 2, "foo"]
        }
      },
      "arcs": []
    });
    expect(topojson.feature(t, t["objects"]["point"]), {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "Point",
        "coordinates": [1, 2, "foo"]
      }
    });
  });

  test(
      "topojson.feature preserves additional dimensions in MultiPoint geometries",
      () {
    var t = topojson.parseObject({
      "type": "Topology",
      "objects": {
        "points": {
          "type": "MultiPoint",
          "coordinates": [
            [1, 2, "foo"]
          ]
        }
      },
      "arcs": []
    });
    expect(topojson.feature(t, t["objects"]["points"]), {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "MultiPoint",
        "coordinates": [
          [1, 2, "foo"]
        ]
      }
    });
  });

  test(
      "topojson.feature preserves additional dimensions in LineString geometries",
      () {
    var t = <String, dynamic>{
      "type": "Topology",
      "objects": {
        "line": {
          "type": "LineString",
          "arcs": [0]
        }
      },
      "arcs": [
        [
          [1, 2, "foo"],
          [3, 4, "bar"]
        ]
      ]
    };
    expect(topojson.feature(t, t["objects"]["line"]), {
      "type": "Feature",
      "properties": {},
      "geometry": {
        "type": "LineString",
        "coordinates": [
          [1, 2, "foo"],
          [3, 4, "bar"]
        ]
      }
    });
  });
}

Map<String?, dynamic> simpleTopology(Map<String, dynamic> object) =>
    topojson.parseObject({
      "type": "Topology",
      "transform": {
        "scale": [1, 1],
        "translate": [0, 0]
      },
      "objects": {"foo": object},
      "arcs": [
        [
          [0, 0],
          [1, 0],
          [0, 1],
          [-1, 0],
          [0, -1]
        ],
        [
          [0, 0],
          [1, 0],
          [0, 1]
        ],
        [
          [1, 1],
          [-1, 0],
          [0, -1]
        ],
        [
          [1, 1]
        ],
        [
          [0, 0]
        ]
      ]
    });
