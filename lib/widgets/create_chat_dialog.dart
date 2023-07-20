import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:gpt4client/api/client_api.dart';
import 'package:gpt4client/data/chat.dart';
import 'package:gpt4client/data/model.dart';
import 'package:gpt4client/widgets/model_chooser.dart';

class CreateChatDialog extends StatefulWidget {
  final BeamerDelegate beamer;
  const CreateChatDialog({super.key, required this.beamer});

  @override
  CreateChatDialogState createState() => CreateChatDialogState();
}

class CreateChatDialogState extends State<CreateChatDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _chatName;
  Model? _selectedModel;
  TextEditingController tempController = TextEditingController(text: '0.7');
  TextEditingController topKController = TextEditingController(text: '40');
  TextEditingController topPController = TextEditingController(text: '0.1');
  TextEditingController repeatPenaltyController = TextEditingController(text: '1.18');
  TextEditingController repeatLastNController = TextEditingController(text: '64');
  TextEditingController nBatchController = TextEditingController(text: '8');
  TextEditingController nPredictController = TextEditingController(text: '200');

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                decoration: const InputDecoration(labelText: 'Chat Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a chat name.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _chatName = value;
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Select Model'),
              ModelChooser(
                  beamer: widget.beamer,
                  onChoose: (model) => setState(() {
                        _selectedModel = model;
                      })),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: tempController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Temperature'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Temperature is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: topKController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Top K'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Top K is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: topPController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Top P'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Top P is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: repeatPenaltyController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Repeat Penalty'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Repeat Penalty is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: repeatLastNController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Repeat Last N'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Repeat Last N is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: nBatchController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'N Batch'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'N Batch is required';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: nPredictController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'N Predict'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'N Predict is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();
                    double temp = double.parse(tempController.text);
                    int topK = int.parse(topKController.text);
                    double topP = double.parse(topPController.text);
                    double repeatPenalty = double.parse(repeatPenaltyController.text);
                    int repeatLastN = int.parse(repeatLastNController.text);
                    int nBatch = int.parse(nBatchController.text);
                    int nPredict = int.parse(nPredictController.text);

                    ClientAPI()
                        .createChat(Chat(
                            id: 0,
                            userId: 0,
                            name: _chatName!,
                            model: _selectedModel!.filename,
                            properties: ModelSettings(
                                temp: temp,
                                topK: topK,
                                topP: topP,
                                repeatPenalty: repeatPenalty,
                                repeatLastN: repeatLastN,
                                nBatch: nBatch,
                                nPredict: nPredict)))
                        .then((value) => {Navigator.pop(context, value)});
                  }
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
