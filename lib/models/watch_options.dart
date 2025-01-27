class WatchOption {
  final String serviceName;
  final String serviceType;
  final String iconPath;

  WatchOption({
    required this.serviceName,
    required this.serviceType,
    required this.iconPath,
  });

  factory WatchOption.fromJson(Map<String, dynamic> json) {
    var serviceName = json['service']['id'];
    var iconPath;
    switch (serviceName) {
      case 'apple':
        iconPath = 'assets/icons/apple.png';
      case 'disney':
        iconPath = 'assets/icons/disney.png';
      case 'prime':
        iconPath = 'assets/icons/prime.png';
      case 'netflix':
        iconPath = 'assets/icons/netflix.png';
      case 'hulu':
        iconPath = 'assets/icons/hulu.png';
      case 'hbo':
        iconPath = 'assets/icons/max.png';
      case 'paramount':
        iconPath = 'assets/icons/paramount.png';
      case 'peacock':
        iconPath = 'assets/icons/peacock.png';
      case 'tubi':
        iconPath = 'assets/icons/tubi.png';
      default:
        iconPath = 'assets/movieDate.png';
    }
    return WatchOption(
      serviceName: json['service']['id'],
      serviceType: json['type'],
      iconPath: iconPath,
    );
  }
}
