class Model {
  final String order;
  final String md5sum;
  final String name;
  final String filename;
  final String filesize;
  final String ramrequired;
  final String parameters;
  final String quant;
  final String type;
  final String systemPrompt;
  final String description;

  Model({
    required this.order,
    required this.md5sum,
    required this.name,
    required this.filename,
    required this.filesize,
    required this.ramrequired,
    required this.parameters,
    required this.quant,
    required this.type,
    required this.systemPrompt,
    required this.description,
  });

  factory Model.fromJson(Map<String, dynamic> json) {
    return Model(
      order: json['order'],
      md5sum: json['md5sum'],
      name: json['name'],
      filename: json['filename'],
      filesize: json['filesize'],
      ramrequired: json['ramrequired'],
      parameters: json['parameters'],
      quant: json['quant'],
      type: json['type'],
      systemPrompt: json['systemPrompt'],
      description: json['description'],
    );
  }
}
