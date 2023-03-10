// ignore_for_file: lines_longer_than_80_chars

import 'package:test/test.dart';
import 'package:topo_client/topo_client.dart' as topojson;

void main() {
  test("neighbors returns an empty array for empty input", () {
    expect(topojson.neighbors([]), []);
  });

//
// A-----B
//
// C-----D
//
  test("neighbors returns an empty array for objects with no neighbors", () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "ab": {
          "type": "LineString",
          "arcs": [0]
        },
        "cd": {
          "type": "LineString",
          "arcs": [1]
        }
      },
      "arcs": [
        [
          [0, 0],
          [1, 0]
        ],
        [
          [0, 1],
          [1, 1]
        ]
      ]
    };
    expect(
        topojson
            .neighbors([topology["objects"]["ab"], topology["objects"]["cd"]]),
        [[], []]);
  });

//
// A-----B-----C
//
  test(
      "neighbors geometries that only share isolated points are not considered neighbors",
      () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "ab": {
          "type": "LineString",
          "arcs": [0]
        },
        "bc": {
          "type": "LineString",
          "arcs": [1]
        }
      },
      "arcs": [
        [
          [0, 0],
          [1, 0]
        ],
        [
          [1, 0],
          [2, 0]
        ]
      ]
    };
    expect(
        topojson
            .neighbors([topology["objects"]["ab"], topology["objects"]["bc"]]),
        [[], []]);
  });

//
// A-----B-----C-----D
//
  test("neighbors geometries that share arcs are considered neighbors", () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "abc": {
          "type": "LineString",
          "arcs": [0, 1]
        },
        "bcd": {
          "type": "LineString",
          "arcs": [1, 2]
        }
      },
      "arcs": [
        [
          [0, 0],
          [1, 0]
        ],
        [
          [1, 0],
          [2, 0]
        ],
        [
          [2, 0],
          [3, 0]
        ]
      ]
    };
    expect(
        topojson.neighbors(
            [topology["objects"]["abc"], topology["objects"]["bcd"]]),
        [
          [1],
          [0]
        ]);
  });

//
// A-----B-----C-----D
//
  test("neighbors geometries that share reversed arcs are considered neighbors",
      () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "abc": {
          "type": "LineString",
          "arcs": [0, 1]
        },
        "dcb": {
          "type": "LineString",
          "arcs": [2, -2]
        }
      },
      "arcs": [
        [
          [0, 0],
          [1, 0]
        ],
        [
          [1, 0],
          [2, 0]
        ],
        [
          [3, 0],
          [2, 0]
        ]
      ]
    };
    expect(
        topojson.neighbors(
            [topology["objects"]["abc"], topology["objects"]["dcb"]]),
        [
          [1],
          [0]
        ]);
  });

//
// A-----B-----C-----D-----E-----F
//
  test("neighbors neighbors are returned in sorted order by index", () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "abcd": {
          "type": "LineString",
          "arcs": [0, 1, 2]
        },
        "bcde": {
          "type": "LineString",
          "arcs": [1, 2, 3]
        },
        "cdef": {
          "type": "LineString",
          "arcs": [2, 3, 4]
        },
        "dbca": {
          "type": "LineString",
          "arcs": [-3, -2, -1]
        },
        "edcb": {
          "type": "LineString",
          "arcs": [-4, -3, -2]
        },
        "fedc": {
          "type": "LineString",
          "arcs": [-5, -4, -3]
        }
      },
      "arcs": [
        [
          [0, 0],
          [1, 0]
        ],
        [
          [1, 0],
          [2, 0]
        ],
        [
          [2, 0],
          [3, 0]
        ],
        [
          [3, 0],
          [4, 0]
        ],
        [
          [4, 0],
          [5, 0]
        ]
      ]
    };
    expect(
        topojson.neighbors([
          topology["objects"]["abcd"],
          topology["objects"]["bcde"],
          topology["objects"]["cdef"],
          topology["objects"]["dbca"],
          topology["objects"]["edcb"],
          topology["objects"]["fedc"]
        ]),
        [
          [1, 2, 3, 4, 5],
          [0, 2, 3, 4, 5],
          [0, 1, 3, 4, 5],
          [0, 1, 2, 4, 5],
          [0, 1, 2, 3, 5],
          [0, 1, 2, 3, 4]
        ]);
  });

//
// A-----B-----E     G
// |     |     |     |\
// |     |     |     | \
// |     |     |     |  \
// |     |     |     |   \
// |     |     |     |    \
// D-----C-----F     I-----H
//
  test("neighbors the polygons ABCDA and BEFCB are neighbors, but GHIG is not",
      () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "abcda": {
          "type": "Polygon",
          "arcs": [
            [0, 1]
          ]
        },
        "befcb": {
          "type": "Polygon",
          "arcs": [
            [2, -1]
          ]
        },
        "ghig": {
          "type": "Polygon",
          "arcs": [
            [3]
          ]
        }
      },
      "arcs": [
        [
          [1, 0],
          [1, 1]
        ],
        [
          [1, 1],
          [0, 1],
          [0, 0],
          [1, 0]
        ],
        [
          [1, 0],
          [2, 0],
          [2, 1],
          [1, 1]
        ],
        [
          [3, 0],
          [4, 1],
          [3, 1],
          [3, 0]
        ]
      ]
    };
    expect(
        topojson.neighbors([
          topology["objects"]["abcda"],
          topology["objects"]["befcb"],
          topology["objects"]["ghig"]
        ]),
        [
          [1],
          [0],
          []
        ]);
  });

//
// A-----------B-----------C
// |           |           |
// |           |           |
// |     D-----E-----F     |
// |     |           |     |
// |     |           |     |
// |     G-----H-----I     |
// |           |           |
// |           |           |
// J-----------K-----------L
//
  test(
      "neighbors the polygons ABEDGHKJA and BCLKHIFEB are neighbors, and not listed twice",
      () {
    var topology = <String?, dynamic>{
      "type": "Topology",
      "objects": {
        "abdeghkja": {
          "type": "Polygon",
          "arcs": [
            [0, 1, 2, 3]
          ]
        },
        "bclkhifeb": {
          "type": "Polygon",
          "arcs": [
            [4, -3, 5, -1]
          ]
        }
      },
      "arcs": [
        [
          [2, 0],
          [2, 1]
        ],
        [
          [2, 1],
          [1, 1],
          [1, 2],
          [2, 2]
        ],
        [
          [2, 2],
          [2, 3]
        ],
        [
          [2, 3],
          [0, 3],
          [0, 0],
          [2, 0]
        ],
        [
          [2, 0],
          [4, 0],
          [4, 3],
          [2, 3]
        ],
        [
          [2, 2],
          [3, 2],
          [3, 1],
          [2, 1]
        ]
      ]
    };
    expect(
        topojson.neighbors([
          topology["objects"]["abdeghkja"],
          topology["objects"]["bclkhifeb"]
        ]),
        [
          [1],
          [0]
        ]);
  });
}
