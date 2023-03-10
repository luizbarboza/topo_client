/// Applies this transform function to the specified [point], returning a new
/// point with the transformed coordinates.
///
/// If the specified [index] is truthy, the input [point] is treated as relative
/// to the previous point passed to this transform, as is the case with
/// delta-encoded arcs.
typedef Transform = List<Object?> Function(List<Object?> point, [int index]);
