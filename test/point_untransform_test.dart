// ignore_for_file: lines_longer_than_80_chars

import 'package:test/test.dart';
import 'package:topo_client/topo_client.dart' as topojson;

void main() {
  test(
      "topojson.untransformPoint(topology) returns the identity function if transform is undefined",
      () {
    var untransform = topojson.untransformPoint(null);
    List<Object?> point;
    expect(untransform(point = []), point);
  });

  test(
      "topojson.untransformPoint(topology) returns a point-transform function if transform is defined",
      () {
    var untransform = topojson.untransformPoint({
      "scale": [2, 3],
      "translate": [4, 5]
    });
    expect(untransform([16, 26]), [6, 7]);
  });

  test("unstransformPoint(point) returns a new point", () {
    var untransform = topojson.untransformPoint({
          "scale": [2, 3],
          "translate": [4, 5]
        }),
        point = [16, 26];
    expect(untransform(point), [6, 7]);
    expect(point, [16, 26]);
  });

  test("unstransformPoint(point) preserves extra dimensions", () {
    var untransform = topojson.untransformPoint({
      "scale": [2, 3],
      "translate": [4, 5]
    });
    expect(untransform([16, 26, 42]), [6, 7, 42]);
    expect(untransform([16, 26, "foo"]), [6, 7, "foo"]);
    expect(untransform([16, 26, "foo", 42]), [6, 7, "foo", 42]);
  });

  test("unstransformPoint(point) untransforms individual points", () {
    var untransform = topojson.untransformPoint({
      "scale": [2, 3],
      "translate": [4, 5]
    });
    expect(untransform([6, 11]), [1, 2]);
    expect(untransform([10, 17]), [3, 4]);
    expect(untransform([14, 23]), [5, 6]);
  });

  test("unstransformPoint(point, index) untransforms delta-encoded arcs", () {
    var untransform = topojson.untransformPoint({
      "scale": [2, 3],
      "translate": [4, 5]
    });
    expect(untransform([6, 11], 0), [1, 2]);
    expect(untransform([12, 23], 1), [3, 4]);
    expect(untransform([22, 41], 2), [5, 6]);
    expect(untransform([24, 47], 3), [1, 2]);
    expect(untransform([30, 59], 4), [3, 4]);
    expect(untransform([40, 77], 5), [5, 6]);
  });

  test(
      "unstransformPoint(point, index) untransforms multiple delta-encoded arcs",
      () {
    var untransform = topojson.untransformPoint({
      "scale": [2, 3],
      "translate": [4, 5]
    });
    expect(untransform([6, 11], 0), [1, 2]);
    expect(untransform([12, 23], 1), [3, 4]);
    expect(untransform([22, 41], 2), [5, 6]);
    expect(untransform([6, 11], 0), [1, 2]);
    expect(untransform([12, 23], 1), [3, 4]);
    expect(untransform([22, 41], 2), [5, 6]);
  });
}
