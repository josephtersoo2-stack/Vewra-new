/// Model representing user KYC verification status and document details.
class VerificationStatusModel {
  final int id;
  final String country;
  final String verificationLevel;
  final String status;
  final String documentType;
  final String documentReference;
  final DateTime? submittedAt;
  final DateTime? reviewedAt;
  final DateTime? approvedAt;
  final String? rejectionReason;

  const VerificationStatusModel({
    required this.id,
    this.country = 'Global',
    this.verificationLevel = 'BASIC',
    this.status = 'NOT_STARTED',
    this.documentType = 'NATIONAL_ID',
    this.documentReference = '',
    this.submittedAt,
    this.reviewedAt,
    this.approvedAt,
    this.rejectionReason,
  });

  factory VerificationStatusModel.fromJson(Map<String, dynamic> json) {
    return VerificationStatusModel(
      id: (json['id'] as num?)?.toInt() ?? 0,
      country: json['country']?.toString() ?? 'Global',
      verificationLevel: json['verification_level']?.toString() ?? 'BASIC',
      status: json['status']?.toString() ??
          (json['document_status']?.toString() ?? 'NOT_STARTED'),
      documentType: json['document_type']?.toString() ?? 'NATIONAL_ID',
      documentReference: json['document_reference']?.toString() ?? '',
      submittedAt: json['submitted_at'] != null
          ? DateTime.tryParse(json['submitted_at'].toString())
          : null,
      reviewedAt: json['reviewed_at'] != null
          ? DateTime.tryParse(json['reviewed_at'].toString())
          : null,
      approvedAt: json['approved_at'] != null
          ? DateTime.tryParse(json['approved_at'].toString())
          : null,
      rejectionReason: json['rejection_reason']?.toString(),
    );
  }

  bool get isApproved => status == 'APPROVED' || status == 'VERIFIED';
  bool get isPending => status == 'PENDING';
  bool get isRejected => status == 'REJECTED';
  bool get isNotStarted => status == 'NOT_STARTED' || status == 'BASIC';
}
