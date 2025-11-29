class LanzouDirectLinkRequest {
  const LanzouDirectLinkRequest({required this.shareUrl, this.password});

  final String shareUrl;
  final String? password;
}

class LanzouDirectLinkContext {
  const LanzouDirectLinkContext({
    required this.originalUrl,
    required this.formattedUrl,
    required this.rawContent,
    required this.fileInfo,
    required this.needsPassword,
  });

  final String originalUrl;
  final String formattedUrl;
  final String rawContent;
  final LanzouDirectLinkFileInfo fileInfo;
  final bool needsPassword;
}

class LanzouDirectLinkFileInfo {
  const LanzouDirectLinkFileInfo({
    required this.name,
    required this.size,
    required this.time,
  });

  final String name;
  final String size;
  final String time;
}

class LanzouDirectLinkResult {
  LanzouDirectLinkResult({
    required this.name,
    required this.size,
    required this.time,
    required this.directLink,
    required this.originalUrl,
  });

  final String name;
  final String size;
  final String time;
  final String directLink;
  final String originalUrl;

  Map<String, dynamic> toMap() => {
    'name': name,
    'size': size,
    'time': time,
    'directLink': directLink,
    'originalUrl': originalUrl,
  };
}
