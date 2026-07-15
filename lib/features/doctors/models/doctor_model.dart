class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.yearsExperience,
    required this.rating,
    required this.reviewCount,
    required this.fee,
    required this.imageUrl,
    required this.about,
  });

  final String id;
  final String name;
  final String specialty;
  final int yearsExperience;
  final double rating;
  final int reviewCount;
  final double fee;
  final String imageUrl;
  final String about;
}

/// Sample data mirroring the 4 cards in doctor-list.html.
final List<DoctorModel> demoDoctors = [
  const DoctorModel(
    id: 'hamza-tariq',
    name: 'Dr. Hamza Tariq',
    specialty: 'Senior Surgeon',
    yearsExperience: 12,
    rating: 4.9,
    reviewCount: 120,
    fee: 45,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBx52-2PLnAq4Idi9Xq_15azEVBcbE5yWcytJ7FM3eXKF_x35F652fQjbOmP-30z0Xns5D0ejpjnoF5cYuj3bwxPNFH4hcp9LAu-WtQr8ZjCV_9tmS0Qp-2_fHfb2eOGHe0q9jceUzq6c8NCj52jrjsd3GpBP0y_OwQrxTpZSGuIlBhsWVmYxNO07cvy_wkPq4zQlrKJHjDuWDHCG36rkPKNszPds6kGg7gHDXZ6HyYr6PmUBhWwvy9',
    about:
        'Dr. Hamza Tariq is a senior oral surgeon with over a decade of experience in complex extractions and implant surgery.',
  ),
  const DoctorModel(
    id: 'alina-fatima',
    name: 'Dr. Alina Fatima',
    specialty: 'Orthodontist',
    yearsExperience: 8,
    rating: 5.0,
    reviewCount: 98,
    fee: 35,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDvmnqFYLTbt_I7ol9MSoME595nK87QKfOefJlyXs7Q6CWFGpbEldzK_f1w89SggNEG4BmVOidfAm1qGtMoF2di2sNJsENclIVpQN30x9ruGi-WPdMvU7_goDg9tUJCMvuZP2Cfyk3GMClwzN3BbJ7ehI8RqYLMNUj8aW8XVfR1GqBentrJbSD2UOT0gHb9z_FPigcEcgRC7XWCtwV0EM9HKbC_Tf5i5IUfRRDbgG2qrj8kflWxp1uL',
    about:
        'Dr. Alina Fatima specializes in Invisalign and modern orthodontic care, helping patients achieve confident smiles.',
  ),
  const DoctorModel(
    id: 'ali-uzair',
    name: 'Dr. Ali Uzair',
    specialty: 'Periodontist',
    yearsExperience: 15,
    rating: 4.8,
    reviewCount: 156,
    fee: 55,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuBEU6UTF9D1JUHy6RnAWRUi_x1Sc-dYw1Cv5YFYbsBAPCx0iKXJ3LpT9uTsK1A2IH7pHMysS0PmPtNzI2drB0r9dCtItU8r5RcUKzAfppoUQVqZXPYn_C2TL5OpDezTREnhOxZemcI5lJq-7duIFwIVN2hni4c-qa939IxFdhW_BD5bhSKoPFntFDefcLEOKdW4Rp9tIpybHtFHQB5p03ruFjrgeOR3PJL1V-D4pk1QZM0jikeHScVD',
    about: 'Dr. Ali Uzair focuses on gum health and advanced periodontal treatments for long-term dental wellness.',
  ),
  const DoctorModel(
    id: 'sarah-chen',
    name: 'Dr. Sarah Chen',
    specialty: 'Pediatric Dentist',
    yearsExperience: 6,
    rating: 4.9,
    reviewCount: 74,
    fee: 30,
    imageUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuA6hF_NSCLJItbKS07iiMKlqfSc3iNfXLcgd2VHt8PZ8DabMLMXKI9vhjO0YNnTV0vK-yqhF3w9blOggiAkyGoDiYts79UXwFwBoG92yHoq1lU5XpAMGWJncFL0MSuZptdi4fvtrXaMkbrEi6fLqdtiXYm4U4Z27LePT14lOarx8S5pXoDg_uop0lGE9wjVygBFam35JWM07iALT_iyFOAPW-osQECBT1ceHPA7s3LE8tJu-053pP4H',
    about: 'Dr. Sarah Chen creates a calm, welcoming environment for young patients starting their dental journey.',
  ),
];
