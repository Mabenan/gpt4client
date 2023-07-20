import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:gpt4client/api/client_api.dart';
import 'package:gpt4client/data/chat.dart';
import 'package:gpt4client/data/model.dart';
import 'package:gpt4client/widgets/model_chooser.dart';

class EditChatDialog extends StatefulWidget {
  final BeamerDelegate beamer;
  final Chat chat;
  const EditChatDialog({super.key, required this.beamer, required this.chat});

  @override
  EditChatDialogState createState() => EditChatDialogState();
}

class EditChatDialogState extends State<EditChatDialog> {
  final _formKey = GlobalKey<FormState>();
  String? _chatName;
  Model? _selectedModel;

  TextEditingController? tempController;
  TextEditingController? topKController;
  TextEditingController? topPController;
  TextEditingController? repeatPenaltyController;
  TextEditingController? repeatLastNController;
  TextEditingController? nBatchController;
  TextEditingController? nPredictController;

  @override
  void initState() {
    super.initState();
    // Set default values for the properties
    _chatName = widget.chat.name;
    tempController = TextEditingController(text: widget.chat.properties.temp.toString());
    topKController = TextEditingController(text: widget.chat.properties.topK.toString());
    topPController = TextEditingController(text: widget.chat.properties.topP.toString());
    repeatPenaltyController = TextEditingController(text: widget.chat.properties.repeatPenalty.toString());
    repeatLastNController = TextEditingController(text: widget.chat.properties.repeatLastN.toString());
    nBatchController = TextEditingController(text: widget.chat.properties.nBatch.toString());
    nPredictController = TextEditingController(text: widget.chat.properties.nPredict.toString());
  }

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
                initialValue: _chatName,
                validator: (value) {
                  return null;
                },
                onSaved: (value) {
                  _chatName = value;
                },
                enabled: false,
              ),
              const SizedBox(height: 16.0),
              const Text('Select Model'),
              ModelChooser(
                  beamer: widget.beamer,
                  modelPreset: widget.chat.model,
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
                    double temp = double.parse(tempController!.text);
                    int topK = int.parse(topKController!.text);
                    double topP = double.parse(topPController!.text);
                    double repeatPenalty = double.parse(repeatPenaltyController!.text);
                    int repeatLastN = int.parse(repeatLastNController!.text);
                    int nBatch = int.parse(nBatchController!.text);
                    int nPredict = int.parse(nPredictController!.text);

                    ClientAPI()
                        .updateChat(widget.chat.id, Chat(
                            id: widget.chat.id,
                            userId: widget.chat.userId,
                            name: widget.chat.name,
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
