import 'package:event_taxi/event_taxi.dart';

class PlaceCallEvent extends Event {
  final String phoneNumber;
  final bool placeCall;
  PlaceCallEvent(this.phoneNumber, {this.placeCall = true});
}
