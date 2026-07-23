class Pt10PrinterParams {
  String date;
  String time;
  int baudRate;
  int paperType;
  int paperTake;
  int speed;
  int density;
  int coverFeed;
  int powerFeed;
  int language;
  int autoPaper;
  int beep;
  String parity;
  String protocol;

  Pt10PrinterParams({
    this.date = '2026-07-29',
    this.time = '12:20:14',
    this.baudRate = 1,
    this.paperType = 1,
    this.paperTake = 1,
    this.speed = 2,
    this.density = 2,
    this.coverFeed = 1,
    this.powerFeed = 0,
    this.language = 1,
    this.autoPaper = 0,
    this.beep = 1,
    this.parity = 'None',
    this.protocol = 'LP50',
  });

  factory Pt10PrinterParams.fromJson(Map<String, dynamic> json) {
    return Pt10PrinterParams(
      date: json['date'] ?? '2026-07-29',
      time: json['time'] ?? '12:20:14',
      baudRate: json['baud_rate'] ?? 1,
      paperType: json['paper_type'] ?? 1,
      paperTake: json['paper_take'] ?? 1,
      speed: json['speed'] ?? 2,
      density: json['density'] ?? 2,
      coverFeed: json['cover_feed'] ?? 1,
      powerFeed: json['power_feed'] ?? 0,
      language: json['language'] ?? 1,
      autoPaper: json['auto_paper'] ?? 0,
      beep: json['beep'] ?? 1,
      parity: json['parity'] ?? 'None',
      protocol: json['protocol'] ?? 'LP50',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'time': time,
      'baud_rate': baudRate,
      'paper_type': paperType,
      'paper_take': paperTake,
      'speed': speed,
      'density': density,
      'cover_feed': coverFeed,
      'power_feed': powerFeed,
      'language': language,
      'auto_paper': autoPaper,
      'beep': beep,
      'parity': parity,
      'protocol': protocol,
    };
  }
}

class EventPt10ConnectResult {
  final bool success;
  final String message;
  EventPt10ConnectResult({required this.success, required this.message});
}

class EventPt10ParamsLoaded {
  final Pt10PrinterParams params;
  EventPt10ParamsLoaded(this.params);
}

class EventPt10WriteResult {
  final bool success;
  final String message;
  EventPt10WriteResult({required this.success, required this.message});
}
