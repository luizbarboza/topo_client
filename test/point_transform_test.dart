// ignore_for_file: lines_longer_than_80_chars

import 'package:test/test.dart';
import 'package:topo_client/topo_client.dart' as topojson;

void main() {
  test(
      "toppojson.transformPoint(topology) returns the identity function if transform is undefined",
      () {
    var transform = topojson.pointTransform(null);
    List<Object?> point;
    expect(transform(point = []), point);
  });

  test(
      "toppojson.transformPoint(topology) returns a point-transform function if transform is defined",
      () {
    var transform = topojson.pointTransform({
      "scale": [2, 3],
      "translate": [4, 5]
    });
    expect(transform([6, 7]), [16, 26]);
  });

  test("transformPoint(point) returns a new point", () {
    var transform = topojson.pointTransform({
          "scale": [2, 3],
          "translate": [4, 5]
        }),
        point = [6, 7];
    expect(transform(point), [16, 26]);
    expect(point, [6, 7]);
  });

  test("transformPoint(point) preserves extra dimensions", () {
    var transform = topojson.pointTransform({
      "scale": [2, 3],
      "translate": [4, 5]
    });
    expect(transform([6, 7, 42]), [16, 26, 42]);
    expect(transform([6, 7, "foo"]), [16, 26, "foo"]);
    expect(transform([6, 7, "foo", 42]), [16, 26, "foo", 42]);
  });

  test("transformPoint(point) transforms individual points", () {
    var transform = topojson.pointTransform({
      "scale": [2, 3],
      "translate": [4, 5]
    });
    expect(transform([1, 2]), [6, 11]);
    expect(transform([3, 4]), [10, 17]);
    expect(transform([5, 6]), [14, 23]);
  });

  test("transformPoint(point, index) transforms delta-encoded arcs", () {
    var transform = topojson.pointTransform({
      "scale": [2, 3],
      "translate": [4, 5]
    });
    expect(transform([1, 2], 0), [6, 11]);
    expect(transform([3, 4], 1), [12, 23]);
    expect(transform([5, 6], 2), [22, 41]);
    expect(transform([1, 2], 3), [24, 47]);
    expect(transform([3, 4], 4), [30, 59]);
    expect(transform([5, 6], 5), [40, 77]);
  });

  test("transformPoint(point, index) transforms multiple delta-encoded arcs",
      () {
    var transform = topojson.pointTransform({
      "scale": [2, 3],
      "translate": [4, 5]
    });
    expect(transform([1, 2], 0), [6, 11]);
    expect(transform([3, 4], 1), [12, 23]);
    expect(transform([5, 6], 2), [22, 41]);
    expect(transform([1, 2], 0), [6, 11]);
    expect(transform([3, 4], 1), [12, 23]);
    expect(transform([5, 6], 2), [22, 41]);
  });
}
