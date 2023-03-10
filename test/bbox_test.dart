// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:test/test.dart';
import 'package:topo_client/topo_client.dart' as topojson;
import 'package:topo_parse/topo_parse.dart' as topojson;

void main() {
  test("topojson.bbox(topology) ignores the existing bbox, if any", () {
    var bbox = [1, 2, 3, 4];
    expect(
        topojson.bbox(topojson.parseObject(<String, dynamic>{
          "type": "Topology",
          "bbox": bbox,
          "objects": <String, dynamic>{},
          "arcs": []
        })),
        [
          double.infinity,
          double.infinity,
          double.negativeInfinity,
          double.negativeInfinity
        ]);
  });

  test(
      "topojson.bbox(topology) computes the bbox for a quantized topology, if missing",
      () {
    final topology = topojson.parseString(
        File("./test/topojson/polygon-q1e4.json").readAsStringSync());
    expect(topojson.bbox(topology), [0, 0, 10, 10]);
  });

  test(
      "topojson.bbox(topology) computes the bbox for a non-quantized topology, if missing",
      () {
    final topology = topojson
        .parseString(File("./test/topojson/polygon.json").readAsStringSync());
    expect(topojson.bbox(topology), [0, 0, 10, 10]);
  });

  test("topojson.bbox(topology) considers points", () {
    final topology = topojson
        .parseString(File("./test/topojson/point.json").readAsStringSync());
    expect(topojson.bbox(topology), [0, 0, 10, 10]);
  });

  test("topojson.bbox(topology) considers multipoints", () {
    final topology = topojson
        .parseString(File("./test/topojson/points.json").readAsStringSync());
    expect(topojson.bbox(topology), [0, 0, 10, 10]);
  });
}
