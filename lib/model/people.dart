import 'package:cloud_firestore/cloud_firestore.dart';

class People {
  String? key;
  String name;
  String latitude;
  String longitude;
  late DocumentReference reference;

  People(
      {required this.name,
      required this.latitude,
      required this.longitude});

  People.fromMap(Map<String, dynamic> map, {required this.reference})
      : assert(map['name'] != null),
        assert(map['latitude'] != null),
        assert(map['longitude'] != null),
        name = map['name'],
        latitude = map['latitude'],
        longitude = map['longitude'];

  People.fromSnapshot(DocumentSnapshot snapshot)
      : this.fromMap(snapshot.data() as Map<String, dynamic>,
            reference: snapshot.reference);

  toJson() {
    return {
      'name': name,
      'latitude': latitude,
      'longitude': longitude
    };
  }
}
