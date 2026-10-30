// Short label shown in the vehicle badge, e.g. "Jeepney" -> "JEEP".
String transportBadge(String modeName) {
  switch (modeName.toLowerCase()) {
    case 'jeepney':
      return 'JEEP';
    case 'e-bus':
    case 'ebus':
      return 'E-BUS';
    default:
      return modeName.toUpperCase();
  }
}
