// ignore_for_file: lines_longer_than_80_chars

import 'dart:io';

import 'package:test/test.dart';
import 'package:topo_client/topo_client.dart' as topojson;
import 'package:topo_parse/topo_parse.dart' as topojson;

void main() {
  test("topojson.quantize(topology, n) quantizes the input topology", () {
    Map<String?, dynamic> topology;
    expect(
        topojson.quantize(
            topology = topojson.parseString(
                File("./test/topojson/polygon.json").readAsStringSync()),
            topojson.transform(topology, 1e4)),
        topojson.parseString(
            File("./test/topojson/polygon-q1e4.json").readAsStringSync()));
    expect(
        topojson.quantize(
            topology = topojson.parseString(
                File("./test/topojson/polygon.json").readAsStringSync()),
            topojson.transform(topology, 1e5)),
        topojson.parseString(
            File("./test/topojson/polygon-q1e5.json").readAsStringSync()));
  });

  test(
      "topojson.quantize(topology, n) ensures that each arc has at least two points",
      () {
    var topology = topojson
        .parseString(File("./test/topojson/empty.json").readAsStringSync());
    expect(
        topojson.quantize(topology, topojson.transform(topology, 1e4)),
        topojson.parseString(
            File("./test/topojson/empty-q1e4.json").readAsStringSync()));
  });

  test(
      "topojson.quantize(topology, n) preserves the id, bbox and properties of input objects",
      () {
    var topology = topojson.parseString(
        File("./test/topojson/properties.json").readAsStringSync());
    expect(
        topojson.quantize(topology, topojson.transform(topology, 1e4)),
        topojson.parseString(
            File("./test/topojson/properties-q1e4.json").readAsStringSync()));
  });

  test(
      "topojson.quantize(topology, n) throws an error if n is not at least two",
      () {
    var topology = topojson
        .parseString(File("./test/topojson/polygon.json").readAsStringSync());
    expect(() => topojson.quantize(topology, topojson.transform(topology, 0)),
        throwsArgumentError);
    expect(() => topojson.quantize(topology, topojson.transform(topology, 1.5)),
        throwsArgumentError);
    /*expect(() => topojson.quantize(topology, topojson.transform(topology)),
        throwsArgumentError);*/
    /*expect(
        () => topojson.quantize(
            topology, topojson.transform(topology, undefined)),
        throwsArgumentError);*/
    expect(
        () => topojson.quantize(
            topology, topojson.transform(topology, double.nan)),
        throwsUnsupportedError);
    /*expect(
        () => topojson.quantize(topology, topojson.transform(topology, null)),
        throwsArgumentError);*/
    expect(() => topojson.quantize(topology, topojson.transform(topology, -2)),
        throwsArgumentError);
  });

  test(
      "topojson.quantize(topology, n) throws an error if the topology is already quantized",
      () {
    var topology = topojson.parseString(
        File("./test/topojson/polygon-q1e4.json").readAsStringSync());
    expect(() => topojson.quantize(topology, topojson.transform(topology, 1e4)),
        throwsStateError);
  });

  test(
      "topojson.quantize(topology, n) returns a new topology with a bounding box",
      () {
    var before = topojson.parseString(
            File("./test/topojson/polygon.json").readAsStringSync()),
        transform = topojson.transform(before, 1e4);
    before["bbox"] = null;
    var after = topojson.quantize(before, transform);
    expect(
        after,
        topojson.parseString(
            File("./test/topojson/polygon-q1e4.json").readAsStringSync()));
    expect(after["bbox"], [0, 0, 10, 10]);
    expect(before["bbox"], isNull);
  });
}
