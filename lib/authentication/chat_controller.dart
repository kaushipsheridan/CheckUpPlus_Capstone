import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:checkupplus_capstone/services/api_service.dart';

// 1. Message Model
enum MessageSender { user, bot }

class Message {
  final String text;
  final MessageSender sender;
  Message(this.text, this.sender);
}

// 2. The Chat Controller
class ChatController extends GetxController {
  final ApiService _apiService = ApiService();
  final RxBool isLoading = false.obs;
  final RxBool interviewActive = false.obs;
  
  final RxList<Map<String, dynamic>> evidenceHistory = <Map<String, dynamic>>[].obs;
  
  final Rx<Map<String, dynamic>?> currentQuestion = Rx(null);

  // --- Dynamic User Info ---
  final Rx<int?> userAge = Rx(null);
  final Rx<String?> userSex = Rx(null);

  // --- UI State ---
  final RxList<Message> messages = <Message>[].obs;
  final TextEditingController textController = TextEditingController();
  final TextEditingController responseInputController = TextEditingController();
  final RxSet<String> selectedItemIds = <String>{}.obs;

  // --- Speech-to-Text ---
  final SpeechToText _speechToText = SpeechToText();
  final RxBool isListening = false.obs;
  final RxBool speechEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
    
    _speechToText.statusListener = (status) {
      if (status == SpeechToText.notListeningStatus || status == SpeechToText.doneStatus) {
        if (isListening.value) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (isListening.value) {
              startListening();
            }
          });
        } else {
          isListening.value = false;
        }
      }
    };
    
    _sendBotMessage(
      "Hello! To provide the most accurate assessment, I need your age and sex. Please provide them in this format: age, sex.",
    );
  }

  // --- Speech-to-Text Methods ---
  void _initSpeech() async {
    speechEnabled.value = await _speechToText.initialize();
  }

  void startListening() async {
    if (!speechEnabled.value) return;
    if (!_speechToText.isListening) {
      isListening.value = true;
      try {
        await _speechToText.listen(
          onResult: (result) {
            textController.text = result.recognizedWords;
            textController.selection = TextSelection.fromPosition(
              TextPosition(offset: textController.text.length),
            );
          },
          listenFor: const Duration(seconds: 30),
        );
      } catch (e) {
        isListening.value = false;
      }
    }
  }

  void stopListening() async {
    isListening.value = false;
    if (_speechToText.isListening) {
      await _speechToText.stop();
    }
  }

  // --- Message Sending Logic ---
  
  void _sendBotMessage(String text) {
    messages.add(Message(text, MessageSender.bot));
  }

  void _addUserMessage(String text) {
    messages.add(Message(text, MessageSender.user));
  }

  void sendUserInput() {
    if (isListening.value) {
      stopListening();
    }
    final text = textController.text.trim();
    if (text.isEmpty) return;

    _addUserMessage(text);
    textController.clear();
    isLoading.value = true;

    if (userAge.value == null || userSex.value == null) {
      _parseAgeSex(text);
    } else {
      _startInterview(text);
    }
  }

  void _parseAgeSex(String text) {
    try {
      final parts = text.split(',');
      if (parts.length != 2) throw Exception("Invalid format");

      final age = int.tryParse(parts[0].trim());
      final sex = parts[1].trim().toLowerCase();

      if (age == null) throw Exception("Invalid age");
      if (sex != 'male' && sex != 'female') throw Exception("Invalid sex (must be 'male' or 'female')");

      userAge.value = age;
      userSex.value = sex;
      _sendBotMessage("Thank you. Now, please describe your main symptom to begin.");
    } catch (e) {
      _sendBotMessage("I'm sorry, I didn't understand that. Please use the format: age, sex (e.g., 30, male)");
    } finally {
      isLoading.value = false;
    }
  }


  void _startInterview(String symptomText) async {
    try {
      
      final parsed = await _apiService.parseSymptom(symptomText, userAge.value!, userSex.value!);
      
      final List<Map<String, dynamic>> initialEvidence = (parsed['mentions'] as List)
          .map((m) => {
                'id': m['id'],
                'choice_id': m['choice_id'],
                'source': 'initial'
              })
          .toList();

      if (initialEvidence.isEmpty) {
        _sendBotMessage("Sorry, I didn't recognize any symptoms in that description. Can you please try again?");
        isLoading.value = false;
        return;
      }
      
      evidenceHistory.addAll(initialEvidence);

      _callDiagnosis();

    } catch (e) {
      _sendBotMessage("Sorry, an error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void answerSingleChoice(Map<String, dynamic> choice) {
    final evidence = {
      'id': currentQuestion.value!['items'][0]['id'],
      'choice_id': choice['id'],
    };
    
    evidenceHistory.add(evidence);
    _addUserMessage(choice['label']);
    _callDiagnosis();
  }


  void answerGroupSingleChoice(Map<String, dynamic> item) {
   
    final evidence = {
      'id': item['id'],
      'choice_id': 'present', 
    };
    
    evidenceHistory.add(evidence);
    _addUserMessage(item['name']); 
    _callDiagnosis();
  }

  void answerMultipleChoice() {
    if (selectedItemIds.isEmpty) {
      evidenceHistory.add({
        'id': currentQuestion.value!['items'][0]['id'],
        'choice_id': 'absent',
      });
      _addUserMessage("None of the above");
    } else {
      final List<Map<String, dynamic>> newEvidence = selectedItemIds.map((id) {
         return {
          'id': id, 
          'choice_id': 'present',
         };
      }).toList();
      evidenceHistory.addAll(newEvidence);
      _addUserMessage("${selectedItemIds.length} items selected");
    }
    
    _callDiagnosis();
  }

  void answerGeneralInput(String questionType) {
    final text = responseInputController.text.trim();
    if (text.isEmpty) return;

    dynamic value;
    
    if (questionType == 'number' || questionType == 'float' || questionType == 'integer') {
      value = double.tryParse(text);
      if (value == null) {
        Get.snackbar("Invalid Input", "Please enter a valid number.");
        return;
      }
    } else {
      value = text;
    }
    
    evidenceHistory.add({
      'id': currentQuestion.value!['items'][0]['id'],
      'choice_id': 'present',
      'value': value,
    });

    _addUserMessage(text);
    responseInputController.clear();
    _callDiagnosis();
  }

  void _callDiagnosis() async {
    isLoading.value = true;
    
    selectedItemIds.clear();
    responseInputController.clear();
    
    try {
      final response = await _apiService.getDiagnosis(evidenceHistory, userAge.value!, userSex.value!);

      if (response['should_stop'] == true) {
        _sendBotMessage("Thank you. I have enough information. Analyzing your case...");
        _fetchFinalResults(response['conditions'] as List?);
        return;
      }
      
      currentQuestion.value = response['question'];
      _sendBotMessage(currentQuestion.value!['text']);
      interviewActive.value = true;

    } catch(e) {
      _sendBotMessage("Sorry, an error occurred: $e");
    } finally {
      isLoading.value = false;
    }
  }

  // --- Helper function for recommendation text ---
  String _getRecommendationText(String triageLevel) {
    switch (triageLevel) {
      case 'emergency_ambulance':
        return "Your symptoms are very serious. You should call an ambulance right now.";
      case 'emergency':
        return "Your symptoms appear serious. You should go to an emergency department immediately.";
      case 'consultation_24':
        return "You should see a doctor within 24 hours. If your symptoms get worse, go to an emergency department.";
      case 'consultation':
        return "You may need a medical evaluation. Please schedule an appointment with a doctor.";
      case 'self_care':
        return "Your symptoms may not require a medical evaluation and can likely be treated with self-care. Observe your symptoms and consult a doctor if they get worse.";
      default:
        return "Please follow standard medical advice.";
    }
  }

  /// Helper to get final results
  void _fetchFinalResults(List<dynamic>? conditions) async { 
    isLoading.value = true;
    try {
      final results = await _apiService.getTriage(evidenceHistory, userAge.value!, userSex.value!);
      
      String triageLevel = results['triage_level'] ?? 'N/A';
      String description = _getRecommendationText(triageLevel);
      
      String resultText = "--- Triage Result ---\n\n";
      resultText += "Urgency: $triageLevel\n";
      resultText += "Recommendation: $description\n";

      if (conditions != null && conditions.isNotEmpty) {
        resultText += "\nPossible Conditions:\n";
        var topConditions = conditions.take(3);
        for (var condition in topConditions) {
          double probability = (condition['probability'] ?? 0.0) * 100;
          resultText += "- ${condition['common_name']} (${probability.toStringAsFixed(0)}% chance)\n";
        }
      }

      final specialist = results['specialist'];
      if (specialist != null && specialist['name'] != null) {
        resultText += "\nRecommended Specialist: ${specialist['name']}";
      }
      
      _sendBotMessage(resultText.trim()); 
    } catch (e) {
       _sendBotMessage("Sorry, an error occurred while fetching results: $e");
    } finally {
      // Reset for a new interview
      isLoading.value = false;
      interviewActive.value = false;
      currentQuestion.value = null;
      evidenceHistory.clear();
      userAge.value = null;
      userSex.value = null;
      _sendBotMessage("Interview complete. To start a new one, please provide your age and sex (e.g., 30, male).");
    }
  }

  @override
  void onClose() {
    _speechToText.stop();
    textController.dispose();
    responseInputController.dispose();
    super.onClose();
  }
}