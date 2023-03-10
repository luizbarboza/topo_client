import 'package:test/test.dart';
import 'package:topo_client/topo_client.dart' as topojson;
import 'package:topo_parse/topo_parse.dart' as topojson;

void main() {
  test("mesh ignores null geometries", () {
    var topology = topojson.parseObject(
        {"type": "Topology", "objects": <String, dynamic>{}, "arcs": []});
    expect(topojson.mesh(topology, {"type": null}),
        {"type": "MultiLineString", "coordinates": []});
  });

  test("mesh stitches together two connected line strings", () {
    var topology = <String, dynamic>{
      "type": "Topology",
      "objects": {
        "collection": {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "LineString",
              "arcs": [0]
            },
            {
              "type": "LineString",
              "arcs": [1]
            }
          ]
        }
      },
      "arcs": [
        [
          [1, 0],
          [2, 0]
        ],
        [
          [0, 0],
          [1, 0]
        ]
      ]
    };
    expect(topojson.mesh(topology, topology["objects"]["collection"]), {
      "type": "MultiLineString",
      "coordinates": [
        [
          [0, 0],
          [1, 0],
          [2, 0]
        ].map((a) => a.map((b) => closeTo(b, 1e-6)))
      ]
    });
  });

  test("mesh does not stitch together two disconnected line strings", () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "collection": {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "LineString",
              "arcs": [0]
            },
            {
              "type": "LineString",
              "arcs": [1]
            }
          ]
        }
      },
      "arcs": [
        [
          [2, 0],
          [3, 0]
        ],
        [
          [0, 0],
          [1, 0]
        ]
      ]
    };
    expect(topojson.mesh(topology, topology["objects"]["collection"]), {
      "type": "MultiLineString",
      "coordinates": [
        [
          [2, 0],
          [3, 0]
        ],
        [
          [0, 0],
          [1, 0]
        ]
      ]
    });
  });
}
