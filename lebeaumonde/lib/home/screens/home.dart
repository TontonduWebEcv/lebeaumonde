import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Home extends StatefulWidget {
  const Home({Key? key, required this.email}) : super(key: key);
  final String email;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late GoogleMapController mapController;

  final LatLng _center = const LatLng(44.837789, -0.57918);

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  void initState() {
    // TODO: implement initState
    getAssociations();
    super.initState();
  }

  final Map<String, Marker> _markers = {};
  Future<dynamic> getAssociations() async {
    final db = FirebaseFirestore.instance;
    final results = await db
        .collection("association")
        .get()
        .then((QuerySnapshot querySnapshot) {
      return querySnapshot.docs;
    });
    setState(() {
      _markers.clear();
      for (final office in results) {
        final marker = Marker(
          markerId: MarkerId(office["name"]),
          position: LatLng(office["coord"].latitude, office["coord"].longitude),
          infoWindow:
              InfoWindow(title: office["name"], snippet: office["description"]),
        );
        _markers[office["name"]] = marker;
      }
    });

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: const CameraPosition(
          target: LatLng(44.837789, -0.57918),
          zoom: 11,
        ),
        markers: _markers.values.toSet(),
      ),
    );
  }
}
