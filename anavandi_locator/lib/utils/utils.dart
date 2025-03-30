bool isValidCoordinate(double lat, double lon) {
  return !lat.isNaN &&
      !lon.isNaN &&
      lat.isFinite &&
      lon.isFinite &&
      lat >= -90 &&
      lat <= 90 &&
      lon >= -180 &&
      lon <= 180;
}
