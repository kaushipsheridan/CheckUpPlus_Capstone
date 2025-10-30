import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../models/clinic_model.dart';
import '../services/firebase_service.dart';

class NearbyClinicsMapScreen extends StatefulWidget {
  const NearbyClinicsMapScreen({super.key});

  @override
  State<NearbyClinicsMapScreen> createState() => _NearbyClinicsMapScreenState();
}

class _NearbyClinicsMapScreenState extends State<NearbyClinicsMapScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  Marker? _userMarker;
  List<Clinic> _clinics = [];
  LatLng? _userLocation;

  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(43.6709, -79.7396), // Default: Shoppers World Brampton
    zoom: 14,
  );

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final userLocation = await _firebaseService.getUserLocation();
      final clinics = await _firebaseService.getClinics();

      final userMarker = Marker(
        markerId: const MarkerId('user_location'),
        position: userLocation,
        infoWindow: const InfoWindow(title: 'You Are Here'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );

      setState(() {
        _userLocation = userLocation;
        _userMarker = userMarker;
        _clinics = clinics;
        _markers
          ..clear()
          ..add(userMarker)
          ..addAll(_createClinicMarkers(clinics));
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(userLocation, 14),
      );
    } catch (e) {
      debugPrint("Error loading map data: $e");
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load location data.')));
    }
  }

  Set<Marker> _createClinicMarkers(List<Clinic> clinics) {
    return clinics.map((clinic) {
      return Marker(
        markerId: MarkerId(clinic.id),
        position: LatLng(clinic.lat, clinic.lng),
        infoWindow: InfoWindow(
          title: clinic.name,
          snippet: clinic.address,
          onTap: () => _showClinicDetails(clinic),
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      );
    }).toSet();
  }

  void _showClinicDetails(Clinic clinic) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                clinic.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text("📍 ${clinic.address}"),
              const SizedBox(height: 4),
              Text("📞 ${clinic.phone}"),
              const SizedBox(height: 4),
              Text(
                "🏥 ${clinic.specialty.isNotEmpty ? clinic.specialty : 'General Clinic'}",
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                label: const Text('Close'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Center map back to user’s current location
  void _goToUserLocation() {
    if (_userLocation != null && _mapController != null) {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(_userLocation!, 14),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User location not available yet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nearby Clinics Map')),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialCameraPosition,
            markers: _markers,
            myLocationEnabled: true, // show blue dot
            myLocationButtonEnabled: false, // we use custom button
            onMapCreated: (controller) {
              _mapController = controller;
              _loadData();
            },
          ),

          // Floating GPS button (bottom right)
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: _goToUserLocation,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
