import 'identity.dart';
import 'transform_function.dart';

/// Returns a point [transform] function to remove delta-encoding and apply the
/// transform.
///
/// If the [transform] is null, returns the identity function.
Transform pointTransform(Map<String?, List<num>>? transform) {
  if (transform == null) return identity;
  late num x0, y0;
  var kx = transform["scale"]![0],
      ky = transform["scale"]![1],
      dx = transform["translate"]![0],
      dy = transform["translate"]![1];
  return (input, [i = 0]) {
    if (i == 0) x0 = y0 = 0;
    var j = 2, n = input.length, output = <Object?>[];
    output
      ..add((x0 += input[0] as num) * kx + dx)
      ..add((y0 += input[1] as num) * ky + dy);
    while (j < n) {
      output.add(input[j]);
      ++j;
    }
    return output;
  };
}
