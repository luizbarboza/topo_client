List<List<int>> stitch(Map<String?, dynamic> topology, List<int> arcs) {
  var stitchedArcs = <int, int>{},
      fragmentByStart = <End, Fragment>{},
      fragmentByEnd = <End, Fragment>{},
      fragments = <List<int>>[],
      emptyIndex = -1;

  // Stitch empty arcs first, since they may be subsumed by other arcs.
  for (var j = 0; j < arcs.length; j++) {
    int i = arcs[j], t;
    var arc = (topology["arcs"] as List<List<List<num>>>)[i < 0 ? ~i : i];
    if (arc.length < 3 && arc[1][0] == 0 && arc[1][1] == 0) {
      t = arcs[++emptyIndex];
      arcs[emptyIndex] = i;
      arcs[j] = t;
    }
  }

  List<End> ends(i) {
    var arc = (topology["arcs"] as List<List<List<num>>>)[i < 0 ? ~i : i];
    End p0 = End(arc[0]), p1;
    if (topology["transform"] != null) {
      p1 = End([0, 0]);
      for (final dp in arc) {
        p1
          ..x += dp[0]
          ..y += dp[1];
      }
    } else {
      p1 = End(arc[arc.length - 1]);
    }
    return i < 0 ? [p1, p0] : [p0, p1];
  }

  for (final i in arcs) {
    var e = ends(i), start = e[0], end = e[1];
    Fragment? f, g;

    if ((f = fragmentByEnd[start]) != null) {
      fragmentByEnd.remove(f!.end);
      f
        ..add(i)
        ..end = end;
      if ((g = fragmentByStart[end]) != null) {
        fragmentByStart.remove(g!.start);
        var fg = g == f ? f : f.followedBy(g);
        fragmentByStart[fg.start = f.start!] =
            fragmentByEnd[fg.end = g.end!] = fg;
      } else {
        fragmentByStart[f.start!] = fragmentByEnd[f.end!] = f;
      }
    } else if ((f = fragmentByStart[end]) != null) {
      fragmentByStart.remove(f!.start);
      f
        ..addFirst(i)
        ..start = start;
      if ((g = fragmentByEnd[start]) != null) {
        fragmentByEnd.remove(g!.end);
        var gf = g == f ? f : g.followedBy(f);
        fragmentByStart[gf.start = g.start!] =
            fragmentByEnd[gf.end = f.end!] = gf;
      } else {
        fragmentByStart[f.start!] = fragmentByEnd[f.end!] = f;
      }
    } else {
      f = Fragment([i]);
      fragmentByStart[f.start = start] = fragmentByEnd[f.end = end] = f;
    }
  }

  void flush(
      Map<End, Fragment> fragmentByEnd, Map<End, Fragment> fragmentByStart) {
    for (final f in fragmentByEnd.values) {
      fragmentByStart.remove(f.start);
      f
        ..start = null
        ..end = null
        ..forEach((i) {
          stitchedArcs[i < 0 ? ~i : i] = 1;
        });
      fragments.add(f.values);
    }
  }

  flush(fragmentByEnd, fragmentByStart);
  flush(fragmentByStart, fragmentByEnd);
  for (final i in arcs) {
    if (stitchedArcs[i < 0 ? ~i : i] == null) fragments.add([i]);
  }

  return fragments;
}

class End {
  num x, y;

  End(List<num> coordinates)
      : x = coordinates[0],
        y = coordinates[1];

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  bool operator ==(Object other) =>
      other is End && other.x == x && other.y == y;

  @override
  // ignore: avoid_equals_and_hash_code_on_mutable_classes
  int get hashCode => Object.hash(x.hashCode, y.hashCode);
}

class Fragment {
  End? start;
  End? end;
  final List<int> values;

  Fragment(this.values);

  void add(int v) {
    values.add(v);
  }

  void addFirst(int v) {
    values.insert(0, v);
  }

  void forEach(void Function(int) action) {
    values.forEach(action);
  }

  Fragment followedBy(Fragment f) =>
      Fragment(values.followedBy(f.values).toList());
}
