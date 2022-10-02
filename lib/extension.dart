extension DateEx on DateTime? {
  int compareToWithNull(DateTime? d2) {
    if (this == null && d2 == null) {
      return 0;
    } else if (this == null) {
      return 1;
    } else if (d2 == null) {
      return -1;
    } else {
      return this!.compareTo(d2);
    }
  }
}
