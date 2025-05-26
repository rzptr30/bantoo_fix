class Donasi {
  final int? id;
  final String? nama;
  final String? title;
  final String? description;
  final double? targetAmount;
  final double? collectedAmount;
  final String? deadline;
  final int? createdBy;
  final String? createdAt;
  final String? foto;         // Properti foto tetap ada
  final String? imageUrl;     // Tambahkan properti imageUrl
  final double? nominal;
  final String? pesan;
  final double? progress;
  final bool? isEmergency;
  final double? target;       // Tambahkan properti target
  final double? current;      // Tambahkan properti current

  // Tambahkan getter untuk menghitung persentase progres jika tidak ada nilai progress
  double? get progressPercentage {
    // Gunakan progress jika sudah ada
    if (progress != null) {
      return progress;
    }
    // Hitung dari targetAmount dan collectedAmount jika keduanya tersedia
    if (targetAmount == null || targetAmount == 0 || collectedAmount == null) {
      return 0.0;
    }
    final percentage = collectedAmount! / targetAmount!;
    return percentage > 1 ? 1.0 : percentage;
  }

  Donasi({
    this.id,
    this.nama,
    this.title,
    this.description,
    this.targetAmount,
    this.collectedAmount,
    this.deadline,
    this.createdBy,
    this.createdAt,
    this.foto,
    this.imageUrl,  // Tambahkan ke constructor
    this.nominal,
    this.pesan,
    this.progress,
    this.isEmergency,
    this.target,     // Tambahkan ke constructor
    this.current,    // Tambahkan ke constructor
  });

  factory Donasi.fromJson(Map<String, dynamic> json) {
    return Donasi(
      id: json['id'] != null ? int.tryParse(json['id'].toString()) : null,
      nama: json['nama'],
      title: json['title'],
      description: json['description'],
      targetAmount: json['target_amount'] != null ? double.tryParse(json['target_amount'].toString()) : null,
      collectedAmount: json['collected_amount'] != null ? double.tryParse(json['collected_amount'].toString()) : null,
      deadline: json['deadline'],
      createdBy: json['created_by'] != null ? int.tryParse(json['created_by'].toString()) : null,
      createdAt: json['created_at'],
      foto: json['foto'],
      imageUrl: json['image_url'],  // Tambahkan di fromJson
      nominal: json['nominal'] != null ? double.tryParse(json['nominal'].toString()) : null,
      pesan: json['pesan'],
      progress: json['progress'] != null ? double.tryParse(json['progress'].toString()) : null,
      isEmergency: json['is_emergency'] == 1 || json['is_emergency'] == true,
      target: json['target'] != null ? double.tryParse(json['target'].toString()) : null,
      current: json['current'] != null ? double.tryParse(json['current'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'title': title,
      'description': description,
      'target_amount': targetAmount,
      'collected_amount': collectedAmount,
      'deadline': deadline,
      'created_by': createdBy,
      'created_at': createdAt,
      'foto': foto,
      'image_url': imageUrl,  // Tambahkan di toJson
      'nominal': nominal,
      'pesan': pesan,
      'progress': progress,
      'is_emergency': isEmergency,
      'target': target,
      'current': current,
    };
  }
}