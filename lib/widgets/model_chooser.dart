import 'package:beamer/beamer.dart';
import 'package:flutter/material.dart';
import 'package:gpt4client/api/client_api.dart';
import 'package:gpt4client/data/model.dart';

class ModelChooser extends StatefulWidget {
  final BeamerDelegate beamer;
  final Function(Model model) onChoose;
  final String? modelPreset;
  const ModelChooser({super.key, required this.beamer, required this.onChoose, this.modelPreset});

  @override
  ModelChooserState createState() => ModelChooserState();
}

class ModelChooserState extends State<ModelChooser> {
  List<Model>? models;

  Model? _selectedModel;

  @override
  Widget build(BuildContext context) {
    if (models == null) {
      refresh(context);
    }
    if (models != null) {
      return DropdownButton<Model>(
        hint: const Text('Select a model'),
        value: _selectedModel, // Assign the selected model to this value
        onChanged: (Model? selectedModel) {
          if(selectedModel != null){
            setState(() {
              _selectedModel = selectedModel;
            });
            widget.onChoose(selectedModel);
          }
        },
        items: models?.map<DropdownMenuItem<Model>>((Model model) {
          return DropdownMenuItem<Model>(
            value: model,
            child: Text(model.name),
          );
        }).toList(),
      );
    } else {
      return const CircularProgressIndicator();
    }
  }

  void refresh(BuildContext context) async {
    try {
      await ClientAPI().fetchModelList().then((value) => setState(() {
        if(widget.modelPreset != null){
          _selectedModel = value.firstWhere((element) => element.filename == widget.modelPreset);
          if(_selectedModel != null) {
            widget.onChoose(_selectedModel!);
          }
        }
            models = value;
          }));
    } catch (ex) {
      widget.beamer.beamToNamed("/login");
    }
  }
}
