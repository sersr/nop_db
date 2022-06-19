import 'package:collection/collection.dart';

const equality = DeepCollectionEquality();

bool matchListItem(Iterable v, Iterable y) => y.any(v.contains);
