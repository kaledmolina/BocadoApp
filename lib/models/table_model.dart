class TableModel {
  final int id;
  final String number;
  final String qrCodeToken;
  final String status; // 'free', 'occupied', 'payment_pending'
  final bool isActiveForOrder;

  TableModel({
    required this.id,
    required this.number,
    required this.qrCodeToken,
    required this.status,
    required this.isActiveForOrder,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'],
      number: json['number'] ?? '',
      qrCodeToken: json['qr_code_token'] ?? '',
      status: json['status'] ?? 'free',
      isActiveForOrder: json['is_active_for_order'] == 1 || json['is_active_for_order'] == true,
    );
  }
}
