import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_google_places_sdk/flutter_google_places_sdk.dart';
import 'package:checkupplus_capstone/services/api_service.dart';

class AddressSearchDialog extends StatefulWidget {
  const AddressSearchDialog({super.key});

  @override
  State<AddressSearchDialog> createState() => _AddressSearchDialogState();
}

class _AddressSearchDialogState extends State<AddressSearchDialog> {
  FlutterGooglePlacesSdk? _places;
  List<AutocompletePrediction> predictions = [];
  String input = '';
  bool _loading = false;
  bool _initialized = false;

  Timer? _debounce;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initPlaces();
  }

  Future<void> _initPlaces() async {
    try {
      final apiKey = await ApiService.getApiKey();
      setState(() {
        _places = FlutterGooglePlacesSdk(apiKey);
        _initialized = true;
      });
    } catch (e) {
      debugPrint("Failed to get Maps API key: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Maps API key unavailable")));
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTextChanged(String value) {
    input = value;
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _searchPlaces(value);
    });
  }

  Future<void> _searchPlaces(String value) async {
    if (!_initialized || _places == null) return;

    if (value.isEmpty) {
      setState(() {
        predictions = [];
        _loading = false;
      });
      return;
    }

    setState(() => _loading = true);

    try {
      final result = await _places!.findAutocompletePredictions(value);
      setState(() {
        predictions = result.predictions;
        _loading = false;
      });
    } catch (e) {
      debugPrint("Autocomplete error: $e");
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Enter your address"),
      content: SizedBox(
        width: MediaQuery.of(context).size.width * 0.9,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _controller,
                onChanged: _onTextChanged,
                decoration: const InputDecoration(
                  hintText: "Start typing your address...",
                ),
              ),
              const SizedBox(height: 8),
              Flexible(
                child: _loading
                    ? const Center(child: CircularProgressIndicator())
                    : predictions.isEmpty && input.isNotEmpty
                    ? const Center(child: Text("No results"))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: predictions.length,
                        itemBuilder: (context, index) {
                          final pred = predictions[index];
                          return ListTile(
                            title: Text(pred.fullText),
                            onTap: () {
                              Navigator.of(context).pop(pred.fullText);
                            },
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text("Cancel"),
        ),
      ],
    );
  }
}
