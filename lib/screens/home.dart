import 'package:checkupplus_capstone/screens/chat.dart';
import 'package:checkupplus_capstone/screens/nearby_clinics_map_screen.dart';
import 'package:checkupplus_capstone/widgets/address_search_dialog.dart';
import 'package:checkupplus_capstone/widgets/speciality_grid.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../widgets/ai_cta_card.dart';
import '../widgets/clinic_card.dart';
import '../services/firebase_service.dart';
import 'doctor_list_screen.dart';
import '../models/clinic_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  String _currentAddress = "Sheridan College - Davis Campus, Brampton";
  LatLng _userLocation = const LatLng(43.6560, -79.7387);
  List<Clinic> _nearbyClinics = [];
  bool _isLoadingClinics = true;

  @override
  void initState() {
    super.initState();
    _initializeUserAndData();
  }

  Future<void> _initializeUserAndData() async {
    await _authenticateUser();
    await _loadUserData();
    await _loadNearbyClinics();
  }

  Future<void> _authenticateUser() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      await FirebaseAuth.instance.signInAnonymously();
    }
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();

    if (doc.exists) {
      final data = doc.data();
      final address = data?['address'];
      final location = data?['location']; // expected {lat, lng} or GeoPoint

      if (address != null && address.isNotEmpty) {
        _currentAddress = address;
      }

      if (location != null) {
        if (location is GeoPoint) {
          _userLocation = LatLng(location.latitude, location.longitude);
        } else if (location is Map) {
          _userLocation = LatLng(
            (location['lat'] ?? 43.6709).toDouble(),
            (location['lng'] ?? -79.7396).toDouble(),
          );
        }
      }
    }
  }

  Future<void> _loadNearbyClinics() async {
    setState(() => _isLoadingClinics = true);

    try {
      final nearbyItems = await _firebaseService.getNearbyClinics(
        _userLocation,
        5,
      );

      _nearbyClinics = nearbyItems
          .map((item) => item['clinic'] as Clinic)
          .toList();
    } catch (e) {
      debugPrint("Error loading nearby clinics: $e");
    }

    setState(() => _isLoadingClinics = false);
  }

  Future<void> _updateAddress(String address) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
      'address': address,
    }, SetOptions(merge: true));

    setState(() => _currentAddress = address);
  }

  Future<void> _openAddressDialog() async {
    final selectedAddress = await showDialog<String>(
      context: context,
      builder: (context) => const AddressSearchDialog(),
    );

    if (selectedAddress != null) {
      await _updateAddress(selectedAddress);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Address updated to "$selectedAddress"')),
      );
      await _loadNearbyClinics();
    }
  }

  @override
  Widget build(BuildContext context) {
    const double padding = 16.0;

    return Scaffold(
      appBar: AppBar(toolbarHeight: 0),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ---------------- Current Location ----------------
            GestureDetector(
              onTap: _openAddressDialog,
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Current Location: $_currentAddress',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const Icon(Icons.edit, size: 16),
                ],
              ),
            ),
            const SizedBox(height: padding),

            // ---------------- Search Bar ----------------
            _buildSearchBar(context),
            const SizedBox(height: padding),

            // ---------------- AI CTA Card ----------------
            AiCtaCard(
              onStartChatTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ChatScreen()),
              ),
            ),
            const SizedBox(height: padding),

            // ---------------- Doctor Speciality ----------------
            const Text(
              'Doctor Speciality',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SpecialtyGrid(
              onCategoryTap: (category) => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DoctorListScreen(category: category),
                ),
              ),
            ),
            const SizedBox(height: padding),

            // ---------------- Nearby Clinics ----------------
            _buildNearbyClinicsHeader(context),
            const SizedBox(height: 8),
            if (_isLoadingClinics)
              const Center(child: CircularProgressIndicator())
            else if (_nearbyClinics.isEmpty)
              const Text('No clinics found within 5 km.')
            else
              Column(
                children: _nearbyClinics.map((clinic) {
                  final distance = _firebaseService.calculateDistanceKm(
                    _userLocation,
                    LatLng(clinic.lat, clinic.lng),
                  );

                  return ClinicCard(clinic: clinic, distanceKm: distance);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Search screen navigation placeholder.'),
          ),
        );
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.centerLeft,
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.grey),
            SizedBox(width: 8),
            Text(
              'Search for nearest clinic based on the location',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNearbyClinicsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Nearby Clinics (within 5 km)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        TextButton(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NearbyClinicsMapScreen()),
          ),
          child: const Text(
            'See All',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}
