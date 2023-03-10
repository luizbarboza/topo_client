Manipulate TopoJSON, such as to merge shapes, and convert it back to
GeoJSON.

The **topo_client** package provides tools for manipulating
[TopoJSON](https://github.com/topojson/topojson), such as to [merge] shapes
or [quantize] coordinates, and for converting back to GeoJSON (using
[feature]) for rendering with standard tools such as
[GeoPath](https://pub.dev/documentation/d4_geo/latest/d4_geo/GeoPath-class.html).
For example,
[bl.ocks.org/3783604](https://bl.ocks.org/mbostock/3783604):

```dart
import 'dart:convert';

import 'package:d4_geo/d4_geo.dart';
import 'package:http/http.dart' as http;

void main() async {
  var path = GeoPath();

  String url = "https://d3js.org/us-10m.v1.json";
  final response = await http.get(Uri.parse(url));

  path(jsonDecode(response.body));
}
```
