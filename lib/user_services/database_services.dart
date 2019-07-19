class Loc3D {
  double latitude;
  double longitude;
  double altitude;

  Loc3D(double lati, double longi, double alti) {
    this.latitude = lati;
    this.longitude = longi;
    this.altitude = alti;
  }
}

class DatabaseServices {
  Future<Loc3D> getCarLocation() async {
    double lati = 33.753891;
    double longi = -84.389412;
    double alti = 257.88;
    return Loc3D(lati, longi, alti);
  }
}
