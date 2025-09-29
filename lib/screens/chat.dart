import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:checkupplus_capstone/authentication/chat_controller.dart'; 
import 'package:iconsax/iconsax.dart'; 

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize the Chat Controller
    final controller = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("AI Assistant Chat"), // Appropriate title
        actions: [
          // View Chat History Button 
          IconButton(
            icon: const Icon(Iconsax.clock),
            onPressed: () {
              // TODO: Implement navigation to a new subpage for chat history
              Get.snackbar("Feature", "Chat History subpage navigation pending.");
            },
          ),
        ],
      ),
      
      body: Column(
        children: [
          // Message List View (Reactive with Obx)
          Expanded(
            child: Obx(
              () => ListView.builder(
                // Use reverse to keep the input field visible at the bottom
                reverse: true, 
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  // Index calculation for reverse list view
                  final message = controller.messages[controller.messages.length - 1 - index];
                  return ChatBubble(message: message);
                },
              ),
            ),
          ),
          
          // Input Field and Send Button Row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
            child: Row(
              children: [
                // Mic Icon (Functional and reactive with Obx)
                Obx(
                  () => IconButton(
                    icon: Icon(
                      controller.isListening.value
                          ? Iconsax.microphone_25 // Different icon when listening
                          : Iconsax.microphone_2,
                      // Mic button turns red when listening
                      color: controller.isListening.value ? Colors.red : Colors.grey, 
                    ),
                    onPressed: () {
                      if (controller.isListening.value) {
                        // Tapping while listening stops and attempts to send
                        controller.sendMessage(); 
                      } else {
                        // Tapping while idle starts listening
                        controller.startListening();
                      }
                    },
                  ),
                ),
                
                // Text Input Box
                Expanded(
                  child: TextFormField(
                    controller: controller.textController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onFieldSubmitted: (_) => controller.sendMessage(), // Send on enter key
                  ),
                ),
                
                // Send Icon/Button
                IconButton(
                  icon: const Icon(Iconsax.send_1, color: Colors.blue),
                  onPressed: controller.sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Message Bubble Widget ---

class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isBot = message.sender == MessageSender.bot;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        // Aligns bot messages left, user messages right
        mainAxisAlignment: isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bot Profile Picture (Left-aligned)
          if (isBot) ...[
            const CircleAvatar(
              radius: 16,
              backgroundImage: AssetImage('assets/images/bot_profile.png'), // Placeholder
              backgroundColor: Colors.blueGrey,
            ),
            const SizedBox(width: 8),
          ],
          
          // The actual message bubble
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(top: 4, bottom: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                // Different colors for different senders
                color: isBot ? Colors.grey.shade200 : Colors.blue,
                borderRadius: BorderRadius.only(
                  // Rounded corners based on alignment
                  topLeft: Radius.circular(isBot ? 0 : 12),
                  topRight: Radius.circular(isBot ? 12 : 0),
                  bottomLeft: const Radius.circular(12),
                  bottomRight: const Radius.circular(12),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isBot ? Colors.black : Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}