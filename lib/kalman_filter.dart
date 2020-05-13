import 'dart:math';
 class KalmanLatLong {
   static KalmanLatLong instance = KalmanLatLong(3);///Recommended Q for walking
   final double MinAccuracy = 1.0;
   int Q_metres_per_second;
   double timeStamp_milliseconds;
   double lat;
   double lng;
   double variance; // P matrix.  Negative means object uninitialised.  NB: units irrelevant, as long as same units used throughout

   KalmanLatLong(int Q_metres_per_second) { this.Q_metres_per_second = Q_metres_per_second; variance = -1; }

   double getLat() { return lat; }
   double getLng() { return lng; }
   double getAccuracy() { return sqrt(variance); }

   void SetState(double lat, double lng, double accuracy, double TimeStamp_milliseconds) {
    this.lat=lat; this.lng=lng;
    variance = accuracy * accuracy; this.timeStamp_milliseconds=TimeStamp_milliseconds;
  }
   void process(double latMeasurement, double lngMeasurement, double accuracy, double TimeStamp_milliseconds) {

    if (accuracy < MinAccuracy){
      accuracy = MinAccuracy;}
    //if no initial variance
    if (variance < 0) {
      this.timeStamp_milliseconds = TimeStamp_milliseconds;
      lat=latMeasurement; lng = lngMeasurement;
      variance = accuracy*accuracy;
    } else {
      //apply filter
      double timeIncMilliseconds = TimeStamp_milliseconds - this.timeStamp_milliseconds;
      if (timeIncMilliseconds > 0) {
        variance += timeIncMilliseconds * Q_metres_per_second * Q_metres_per_second / 1000;
        this.timeStamp_milliseconds = TimeStamp_milliseconds;}

      /// Kalman gain matrix K = Covarariance * Inverse(Covariance + MeasurementVariance)
      double K = variance / (variance + accuracy * accuracy);
      /// apply K
      lat += K * (latMeasurement - lat);
      lng += K * (lngMeasurement - lng);
      /// new Covarariance  matrix is (IdentityMatrix - K) * Covarariance
      variance = (1 - K) * variance;
    }
  }
}