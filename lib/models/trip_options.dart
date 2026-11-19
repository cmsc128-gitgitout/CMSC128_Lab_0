// collection of routes for a single trip

import 'transit_route.dart';

//blueprint for one single trip-
class TripLeg {
  final TransitRoute route; //routes
  final String startStopId;  //where commuter gets on
  final String endStopId;  //where commuter gets off

  const TripLeg({
    required this.route, 
    required this.startStopId,
    required this.endStopId
  });

}


// puts one or more TripLeg into the list for same structure then helpers 
// also we can use this nalang later for implementation of shortestpath
class TripOptions {
  final List <TripLeg> legs ; 

  const TripOptions({required this.legs});

  //helpers

  bool get isDirect => legs.length ==1; //check if only one trip
  int get transferCount => legs.length -1; 
  String get originStopId =>legs.first.startStopId; // get origin 
  String get destinationState=> legs.last.endStopId;  //get destination

  List<String> get transferStopIds => [
    for (int i = 0; i < legs.length - 1; i++) legs[i].endStopId,
  ];
}



  





}