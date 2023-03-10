// ignore_for_file: lines_longer_than_80_chars

import 'package:test/test.dart';
import 'package:topo_client/topo_client.dart' as topojson;
import 'package:topo_parse/topo_parse.dart' as topojson;

void main() {
  test("merge ignores null geometries", () {
    var topology = topojson.parseObject(
        {"type": "Topology", "objects": <String, dynamic>{}, "arcs": []});
    expect(
        topojson.merge(topology, [
          {"type": null}
        ]),
        {"type": "MultiPolygon", "coordinates": []});
  });

//
// +----+----+            +----+----+
// |    |    |            |         |
// |    |    |    ==>     |         |
// |    |    |            |         |
// +----+----+            +----+----+
//
  test("merge stitches together two side-by-side polygons", () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "collection": {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Polygon",
              "arcs": [
                [0, 1]
              ]
            },
            {
              "type": "Polygon",
              "arcs": [
                [-1, 2]
              ]
            }
          ]
        }
      },
      "arcs": [
        [
          [1, 1],
          [1, 0]
        ],
        [
          [1, 0],
          [0, 0],
          [0, 1],
          [1, 1]
        ],
        [
          [1, 1],
          [2, 1],
          [2, 0],
          [1, 0]
        ]
      ]
    };
    expect(
        topojson.merge(
            topology, topology["objects"]["collection"]["geometries"]),
        {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [1, 0],
                [0, 0],
                [0, 1],
                [1, 1],
                [2, 1],
                [2, 0],
                [1, 0]
              ]
            ]
          ]
        });
  });

//
// +----+----+            +----+----+
// |    |    |            |         |
// |    |    |    ==>     |         |
// |    |    |            |         |
// +----+----+            +----+----+
//
  test("merge stitches together geometry collections", () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "collection": {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Polygon",
              "arcs": [
                [0, 1]
              ]
            },
            {
              "type": "Polygon",
              "arcs": [
                [-1, 2]
              ]
            }
          ]
        }
      },
      "arcs": [
        [
          [1, 1],
          [1, 0]
        ],
        [
          [1, 0],
          [0, 0],
          [0, 1],
          [1, 1]
        ],
        [
          [1, 1],
          [2, 1],
          [2, 0],
          [1, 0]
        ]
      ]
    };
    expect(topojson.merge(topology, [topology["objects"]["collection"]]), {
      "type": "MultiPolygon",
      "coordinates": [
        [
          [
            [1, 0],
            [0, 0],
            [0, 1],
            [1, 1],
            [2, 1],
            [2, 0],
            [1, 0]
          ]
        ]
      ]
    });
  });

//
// +----+ +----+            +----+ +----+
// |    | |    |            |    | |    |
// |    | |    |    ==>     |    | |    |
// |    | |    |            |    | |    |
// +----+ +----+            +----+ +----+
//
  test("merge does not stitch together two separated polygons", () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "collection": {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Polygon",
              "arcs": [
                [0]
              ]
            },
            {
              "type": "Polygon",
              "arcs": [
                [1]
              ]
            }
          ]
        }
      },
      "arcs": [
        [
          [0, 0],
          [0, 1],
          [1, 1],
          [1, 0],
          [0, 0]
        ],
        [
          [2, 0],
          [2, 1],
          [3, 1],
          [3, 0],
          [2, 0]
        ]
      ]
    };
    expect(
        topojson.merge(
            topology, topology["objects"]["collection"]["geometries"]),
        {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [0, 0],
                [0, 1],
                [1, 1],
                [1, 0],
                [0, 0]
              ]
            ],
            [
              [
                [2, 0],
                [2, 1],
                [3, 1],
                [3, 0],
                [2, 0]
              ]
            ]
          ]
        });
  });

//
// +-----------+            +-----------+
// |           |            |           |
// |   +---+   |    ==>     |   +---+   |
// |   |   |   |            |   |   |   |
// |   +---+   |            |   +---+   |
// |           |            |           |
// +-----------+            +-----------+
//
  test("merge does not stitch together a polygon and its hole", () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "collection": {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Polygon",
              "arcs": [
                [0],
                [1]
              ]
            }
          ]
        }
      },
      "arcs": [
        [
          [0, 0],
          [0, 3],
          [3, 3],
          [3, 0],
          [0, 0]
        ],
        [
          [1, 1],
          [2, 1],
          [2, 2],
          [1, 2],
          [1, 1]
        ]
      ]
    };
    expect(
        topojson.merge(
            topology, topology["objects"]["collection"]["geometries"]),
        {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [0, 0],
                [0, 3],
                [3, 3],
                [3, 0],
                [0, 0]
              ],
              [
                [1, 1],
                [2, 1],
                [2, 2],
                [1, 2],
                [1, 1]
              ]
            ]
          ]
        });
  });

//
// +-----------+            +-----------+
// |           |            |           |
// |   +---+   |    ==>     |           |
// |   |   |   |            |           |
// |   +---+   |            |           |
// |           |            |           |
// +-----------+            +-----------+
//
  test("merge stitches together a polygon surrounding another polygon", () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "collection": {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Polygon",
              "arcs": [
                [0],
                [1]
              ]
            },
            {
              "type": "Polygon",
              "arcs": [
                [-2]
              ]
            }
          ]
        }
      },
      "arcs": [
        [
          [0, 0],
          [0, 3],
          [3, 3],
          [3, 0],
          [0, 0]
        ],
        [
          [1, 1],
          [2, 1],
          [2, 2],
          [1, 2],
          [1, 1]
        ]
      ]
    };
    expect(
        topojson.merge(
            topology, topology["objects"]["collection"]["geometries"]),
        {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [0, 0],
                [0, 3],
                [3, 3],
                [3, 0],
                [0, 0]
              ]
            ]
          ]
        });
  });

//
// +-----------+-----------+            +-----------+-----------+
// |           |           |            |                       |
// |   +---+   |   +---+   |    ==>     |   +---+       +---+   |
// |   |   |   |   |   |   |            |   |   |       |   |   |
// |   +---+   |   +---+   |            |   +---+       +---+   |
// |           |           |            |                       |
// +-----------+-----------+            +-----------+-----------+
//
  test("merge stitches together two side-by-side polygons with holes", () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "collection": {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Polygon",
              "arcs": [
                [0, 1],
                [2]
              ]
            },
            {
              "type": "Polygon",
              "arcs": [
                [-1, 3],
                [4]
              ]
            }
          ]
        }
      },
      "arcs": [
        [
          [3, 3],
          [3, 0]
        ],
        [
          [3, 0],
          [0, 0],
          [0, 3],
          [3, 3]
        ],
        [
          [1, 1],
          [2, 1],
          [2, 2],
          [1, 2],
          [1, 1]
        ],
        [
          [3, 3],
          [6, 3],
          [6, 0],
          [3, 0]
        ],
        [
          [4, 1],
          [5, 1],
          [5, 2],
          [4, 2],
          [4, 1]
        ]
      ]
    };
    expect(
        topojson.merge(
            topology, topology["objects"]["collection"]["geometries"]),
        {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [3, 0],
                [0, 0],
                [0, 3],
                [3, 3],
                [6, 3],
                [6, 0],
                [3, 0]
              ],
              [
                [1, 1],
                [2, 1],
                [2, 2],
                [1, 2],
                [1, 1]
              ],
              [
                [4, 1],
                [5, 1],
                [5, 2],
                [4, 2],
                [4, 1]
              ]
            ]
          ]
        });
  });

//
// +-------+-------+            +-------+-------+
// |       |       |            |               |
// |   +---+---+   |    ==>     |   +---+---+   |
// |   |       |   |            |   |       |   |
// |   +---+---+   |            |   +---+---+   |
// |       |       |            |               |
// +-------+-------+            +-------+-------+
//
  test("merge stitches together two horseshoe polygons, creating a hole", () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "collection": {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Polygon",
              "arcs": [
                [0, 1, 2, 3]
              ]
            },
            {
              "type": "Polygon",
              "arcs": [
                [-3, 4, -1, 5]
              ]
            }
          ]
        }
      },
      "arcs": [
        [
          [2, 3],
          [2, 2]
        ],
        [
          [2, 2],
          [1, 2],
          [1, 1],
          [2, 1]
        ],
        [
          [2, 1],
          [2, 0]
        ],
        [
          [2, 0],
          [0, 0],
          [0, 3],
          [2, 3]
        ],
        [
          [2, 1],
          [3, 1],
          [3, 2],
          [2, 2]
        ],
        [
          [2, 3],
          [4, 3],
          [4, 0],
          [2, 0]
        ]
      ]
    };
    expect(
        topojson.merge(
            topology, topology["objects"]["collection"]["geometries"]),
        {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [2, 0],
                [0, 0],
                [0, 3],
                [2, 3],
                [4, 3],
                [4, 0],
                [2, 0]
              ],
              [
                [2, 2],
                [1, 2],
                [1, 1],
                [2, 1],
                [3, 1],
                [3, 2],
                [2, 2]
              ]
            ]
          ]
        });
  });

//
// +-------+-------+            +-------+-------+
// |       |       |            |               |
// |   +---+---+   |    ==>     |               |
// |   |   |   |   |            |               |
// |   +---+---+   |            |               |
// |       |       |            |               |
// +-------+-------+            +-------+-------+
//
  test(
      "merge stitches together two horseshoe polygons surrounding two other polygons",
      () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "collection": {
          "type": "GeometryCollection",
          "geometries": [
            {
              "type": "Polygon",
              "arcs": [
                [0, 1, 2, 3]
              ]
            },
            {
              "type": "Polygon",
              "arcs": [
                [-3, 4, -1, 5]
              ]
            },
            {
              "type": "Polygon",
              "arcs": [
                [6, -2]
              ]
            },
            {
              "type": "Polygon",
              "arcs": [
                [-7, -5]
              ]
            }
          ]
        }
      },
      "arcs": [
        [
          [2, 3],
          [2, 2]
        ],
        [
          [2, 2],
          [1, 2],
          [1, 1],
          [2, 1]
        ],
        [
          [2, 1],
          [2, 0]
        ],
        [
          [2, 0],
          [0, 0],
          [0, 3],
          [2, 3]
        ],
        [
          [2, 1],
          [3, 1],
          [3, 2],
          [2, 2]
        ],
        [
          [2, 3],
          [4, 3],
          [4, 0],
          [2, 0]
        ],
        [
          [2, 2],
          [2, 1]
        ]
      ]
    };
    expect(
        topojson.merge(
            topology, topology["objects"]["collection"]["geometries"]),
        {
          "type": "MultiPolygon",
          "coordinates": [
            [
              [
                [2, 0],
                [0, 0],
                [0, 3],
                [2, 3],
                [4, 3],
                [4, 0],
                [2, 0]
              ]
            ]
          ]
        });
  });
}
