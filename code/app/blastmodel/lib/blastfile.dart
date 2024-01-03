class BlastFile {
  final String cloudName;
  final String fileName;
  final String filePath;

  BlastFile(
      {required this.cloudName,
      required this.fileName,
      required this.filePath});

  BlastFile.fromJson(Map<String, dynamic> json)
      : cloudName = json['cloudName'],
        fileName = json['fileName'],
        filePath = json['filePath'];

  Map<String, dynamic> toJson() => {
        'cloudName': cloudName,
        'fileName': fileName,
        'filePath': filePath,
      };
}
