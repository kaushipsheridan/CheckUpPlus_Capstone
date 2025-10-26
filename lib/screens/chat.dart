import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:checkupplus_capstone/authentication/chat_controller.dart';
import 'package:iconsax/iconsax.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(ChatController());

    return Scaffold(
      appBar: AppBar(
        title: const Text("Symptom Checker"),
        actions: [
          IconButton(
            icon: const Icon(Iconsax.clock),
            onPressed: () {
              Get.snackbar(
                "Feature",
                "Chat History subpage navigation pending.",
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          
          Expanded(
            child: Obx(
              () => ListView.builder(
                reverse: true,
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller
                      .messages[controller.messages.length - 1 - index];
                  return ChatBubble(message: message);
                },
              ),
            ),
          ),

          // --- DYNAMIC INPUT AREA ---
          Obx(() {
            if (controller.isLoading.value) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (controller.interviewActive.value && controller.currentQuestion.value != null) {
              return _buildQuestionUI(controller);
            } else {
              return _buildTextInput(controller);
            }
          }),
        ],
      ),
    );
  }

  Widget _buildTextInput(ChatController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8.0,
        vertical: 12.0,
      ),
      child: Row(
        children: [
          // Mic Icon
          Obx(
            () => IconButton(
              icon: Icon(
                controller.isListening.value
                    ? Iconsax.microphone_25
                    : Iconsax.microphone_2,
                color: controller.isListening.value ? Colors.red : Colors.grey,
              ),
              onPressed: () {
                if (controller.isListening.value) {
                  controller.stopListening();
                } else {
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
                hintText: controller.userAge.value == null 
                  ? 'Describe your symptom...' 
                  : 'Describe your symptom...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
              onFieldSubmitted: (_) => controller.sendUserInput(),
            ),
          ),

          // Send Icon
          IconButton(
            icon: const Icon(Iconsax.send_1, color: Colors.blue),
            onPressed: controller.sendUserInput,
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionUI(ChatController controller) {
    final question = controller.currentQuestion.value;
    if (question == null) return const SizedBox.shrink();

    String type = question['type'];

    if (type == 'single') {
      List<dynamic> choices = question['items'][0]['choices'];
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.center,
          children: choices.map((choice) {
            return ElevatedButton(
              child: Text(choice['label']),
              onPressed: () => controller.answerSingleChoice(choice),
            );
          }).toList(),
        ),
      );
    }


    if (type == 'group_single') {
      List<dynamic> items = question['items']; // These are the choices
      
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 8.0,
          runSpacing: 4.0,
          alignment: WrapAlignment.center,
          // We map over the 'items' directly
          children: items.map((item) {
            return ElevatedButton(
              child: Text(item['name']), // Use 'name' as the label
              onPressed: () => controller.answerGroupSingleChoice(item),
            );
          }).toList(),
        ),
      );
    }
    
    // --- Type: 'group_multiple' (e.g., Select all that apply) ---
    if (type == 'group_multiple') {
      List<dynamic> items = question['items'];
      return Container(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // List of checkboxes
            ...items.map((item) {
              return Obx(() => CheckboxListTile(
                    title: Text(item['name']),
                    value: controller.selectedItemIds.contains(item['id']),
                    onChanged: (bool? value) {
                      if (value == true) {
                        controller.selectedItemIds.add(item['id']);
                      } else {
                        controller.selectedItemIds.remove(item['id']);
                      }
                    },
                  ));
            }).toList(),
            // Submit button
            ElevatedButton(
              child: const Text("Submit"),
              onPressed: controller.answerMultipleChoice,
            ),
          ],
        ),
      );
    }
    
    // --- Type: 'integer' or 'string' (e.g., "What is your temperature?") ---
    if (type == 'integer' || type == 'string' || type == 'float') {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: controller.responseInputController,
                keyboardType: (type == 'integer' || type == 'float')
                  ? TextInputType.number 
                  : TextInputType.text,
                decoration: InputDecoration(
                  hintText: 'Type your answer...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                ),
                onFieldSubmitted: (_) => controller.answerGeneralInput(type),
              ),
            ),
            IconButton(
              icon: const Icon(Iconsax.send_1, color: Colors.blue),
              onPressed: () => controller.answerGeneralInput(type),
            ),
          ],
        ),
      );
    }
    
    // Fallback for any other question type
    return Text("Unknown question type: $type");
  }
}

// --- Message Bubble Widget (UNMODIFIED) ---
// (Your existing ChatBubble class goes here)
class ChatBubble extends StatelessWidget {
  final Message message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final isBot = message.sender == MessageSender.bot;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisAlignment:
            isBot ? MainAxisAlignment.start : MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isBot) ...[
            const CircleAvatar(
              radius: 16,
              // Make sure this asset exists in your project
              backgroundImage: AssetImage('assets/images/bot_profile.png'), 
              backgroundColor: Colors.blueGrey,
              //child: Icon(Iconsax.health, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              margin: const EdgeInsets.only(top: 4, bottom: 4),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isBot ? Colors.grey.shade200 : Colors.blue,
                borderRadius: BorderRadius.only(
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