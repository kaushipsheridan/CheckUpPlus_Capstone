import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:speech_to_text/speech_to_text.dart'; 

// 1. Message Model (Defines the structure of a single message)
enum MessageSender { user, bot }

class Message {
  final String text;
  final MessageSender sender;
  
  Message(this.text, this.sender);
}

// 2. The Chat Controller (Handles all the logic)
class ChatController extends GetxController {
  // Use RxList to make the list reactive
  final RxList<Message> messages = <Message>[].obs;
  
  // Controller for the text input field
  final TextEditingController textController = TextEditingController();

  // --- Speech-to-Text Variables ---
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
      print("Native service stopped, restarting for continuity...");
      
      // *** THE CRITICAL CHANGE: Increase the delay to 500ms or 1 second ***
      // We need to give the native service time to clean up its resources.
      Future.delayed(const Duration(milliseconds: 500), () { 
          // Only restart if still in listening mode (user hasn't tapped stop yet)
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
    "Hello! I am your AI assistant. How can I help you today?",
  );
}

  // --- Speech-to-Text Methods ---

  /// Initializes the speech recognition service
  void _initSpeech() async {
    speechEnabled.value = await _speechToText.initialize();
  }

  void startListening() async {
  if (!speechEnabled.value) {
    Get.snackbar("Error", "Speech recognition is not available.");
    return;
  }
  
  // Only start listening if the native service is NOT currently running
  if (!_speechToText.isListening) {
    isListening.value = true;
    
    try {
      await _speechToText.listen(
        onResult: (result) {
          print("Recognition result: ${result.recognizedWords}, final: ${result.finalResult}");
          textController.text = result.recognizedWords;
          textController.selection = TextSelection.fromPosition(
          TextPosition(offset: textController.text.length),
        );
        },
        // We rely on the global listener/restart logic for continuity,
        // so we don't need a massive listenFor duration here.
        listenFor: const Duration(seconds: 30), 
      );
    } catch (e) {
      print("Error during speech recognition session: $e");
      isListening.value = false;
    }
  }
}

void stopListening() async {
  // This is the flag that breaks the while(isListening.value) loop
  isListening.value = false; 
  if (_speechToText.isListening) {
    await _speechToText.stop();
  }
}

  // --- Message Sending Logic ---
  
  // Helper method for the bot to send messages
  void _sendBotMessage(String text) {
    messages.add(Message(text, MessageSender.bot));
  }
  
  // Method called when the user taps the send button
  void sendMessage() {
    // If mic was active, stop it before sending
    if (isListening.value) {
      stopListening();
    }

    final text = textController.text.trim();
    if (text.isNotEmpty) {
      // Add the user message to the list
      messages.add(Message(text, MessageSender.user));
      
      // Clear the text field
      textController.clear();
      
      // Simulate a bot response (Replace this with FastAPI call later)
      Future.delayed(const Duration(milliseconds: 500), () {
        _sendBotMessage("Got it! You said: '$text'");
      });
    }
  }

  @override
  void onClose() {
    _speechToText.stop(); // Stop listening when the controller is closed
    textController.dispose();
    super.onClose();
  }
}