import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/services.dart';
import 'package:equatable/equatable.dart';

part 'map_state.dart';

/// Cubit that controls the [MapScreen],
/// [int] is the floor number map shows
class MapCubit extends Cubit<MapState> {
  static Map<String, dynamic>? roomsData;

  /// Number of the floor we show when screen opens
  static int initialFloor = 2;

  /// Number of the last floor we are able to show
  static int maxFloor = 4;

  List<Map<String, dynamic>> foundRooms = [];

  MapCubit() : super(MapFloorLoaded(floor: initialFloor)) {
    // uncomment when this is completed
    //_loadRoomsData();
  }

  void _loadRoomsData() {
    Future.delayed(Duration.zero, () async {
      if (roomsData == null)
        roomsData =
            json.decode(await rootBundle.loadString('assets/map/rooms.json'));
    });
  }

  void setSearchQuery(String query) {
    final floors = roomsData!['floors'];
    List<Map<String, dynamic>> newFound = [];
    for (int i = 0; i <= MapCubit.maxFloor; i++) {
      for (var room in floors[i.toString()]['r'].values) {
        if (room['t'].toString().toUpperCase().contains(query.toUpperCase()) &&
            query.length > 1) {
          room['floor'] = i;
          room['x'] = floors[i.toString()]['v'][room['i'][0]]['x'];
          room['y'] = floors[i.toString()]['v'][room['i'][0]]['y'];
          print(double.parse(room['x']));
          print(double.parse(room['y']));
          newFound.add(room);
        }
      }
    }
    foundRooms = newFound;
    emit(MapSearchFoundUpdated(floor: state.floor, foundRooms: foundRooms));
  }

  /// Open the floor by [index]
  void goToFloor(int index) => emit(MapFloorLoaded(floor: index));
}
