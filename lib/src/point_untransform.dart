import 'identity.dart';
import 'transform_function.dart';

/// Returns a point [transform] function to apply quantized delta-encoding and
/// remove the transform.
///
/// If the [transform] is null, returns the identity function.
Transform untransformPoint(Map<String?, List<num>>? transform) {
  if (transform == null) return identity;
  late num x0, y0;
  var kx = transform["scale"]![0],
      ky = transform["scale"]![1],
      dx = transform["translate"]![0],
      dy = transform["translate"]![1];
  return (input, [i = 0]) {
    if (i == 0) x0 = y0 = 0;
    var j = 2,
        n = input.length,
        output = <Object?>[],
        x1 = (((input[0] as num) - dx) / kx).round(),
        y1 = (((input[1] as num) - dy) / ky).round();
    output.add(x1 - x0);
    x0 = x1;
    output.add(y1 - y0);
    y0 = y1;
    while (j < n) {
      output.add(input[j]);
      ++j;
    }
    return output;
  };
}
