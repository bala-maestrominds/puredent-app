// lib/features/services/models/service_model.dart
class ServiceModel {
  const ServiceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.imageUrl,
    required this.highlights,
    required this.overview,
    required this.processSteps,
    this.rating = 4.8,
    this.reviewCount = 120,
    this.durationMinutes = 45,
    this.iconName = 'medical_services',
    this.badge = '',
    this.badgeColor = 'primary',
  });

  final String id;
  final String name;
  final String category; // Preventive / Restorative / Cosmetic / Orthodontics
  final double price;
  final String imageUrl;
  final List<String> highlights; // bullet points shown on the list card
  final String overview; // long description on the detail page
  final List<ProcessStep> processSteps; // "The Process" timeline
  
  // Additional properties for detail page
  final double rating;
  final int reviewCount;
  final int durationMinutes;
  final String iconName;
  final String badge;
  final String badgeColor;
}

class ProcessStep {
  const ProcessStep({required this.title, required this.description});
  final String title;
  final String description;
}

/// Sample data mirroring the 4 cards in service-list.html.
final List<ServiceModel> demoServices = [
  const ServiceModel(
    id: 'checkup',
    name: 'Regular Checkup',
    category: 'Preventive',
    price: 45,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuBqWcqUwsc4n9f4fEF4JOhSrR0wqOummLn2z_GYYAn-8eAAbRhpDib7eP6iWg5OyyiZYRdFgldOjQ-wdORGaxERoldz3V7kWgRKU70ADoUmw3bxnZiJiS6JFm_a9dAIQM3FEecuhuNYq0O5fO_wLKSTqQihJivrg8mtgD3joSm6I223IwVhbC6OGH0LqBpASMMeLQ5RWp42ZK288ljfvCoa-RxS9ANScdyryiwPFxaRP4ua49lB3Tsl',
    highlights: ['Professional cleaning', 'X-rays', 'Comprehensive exam'],
    overview: 'A routine visit to keep your teeth and gums healthy, catching issues early before they become bigger problems.',
    processSteps: [
      ProcessStep(title: 'Consultation', description: 'Discuss symptoms and dental history.'),
      ProcessStep(title: 'Examination', description: 'Full mouth exam and X-rays if needed.'),
      ProcessStep(title: 'Cleaning', description: 'Professional scale and polish.'),
    ],
    rating: 4.9,
    reviewCount: 156,
    durationMinutes: 45,
    badge: 'Best Seller',
  ),
  const ServiceModel(
    id: 'implants',
    name: 'Dental Implants',
    category: 'Restorative',
    price: 1200,
    imageUrl: 'https://lh3.googleusercontent.com/aida/AP1WRLvJX0UMzZ2DQeDzblS-3ZN-iNyeldGc16PhHmdLiEUkUQyEImkiklHvq-YItUo7ERebYDUnYHVyt9FNjdraZOdFeepqqurFo11jnjIK2OwzY577Wvsj_07C77IMX6El031YPHijSGQBjYlx6moMt9EKcHqQlsMHX3dOjzOWw-8s3uMzrOu_pF-dZLkyw-LsdOGERwuN26Z4MDks5vH0hoAUduIw_btqpAtYL2GHtnnORQ7dRl_5oaauxDQ',
    highlights: ['Permanent tooth replacement', 'Natural look', 'Lifetime durability'],
    overview: 'A permanent solution for missing teeth. Our high-grade titanium implants look and feel like natural teeth, restoring both your smile and dental function with clinical precision.',
    processSteps: [
      ProcessStep(title: 'Consultation', description: 'Detailed imaging and treatment planning.'),
      ProcessStep(title: 'Placement', description: 'Surgical insertion of titanium post.'),
      ProcessStep(title: 'Recovery', description: 'Final crown fitting and full smile restoration.'),
    ],
    rating: 4.7,
    reviewCount: 89,
    durationMinutes: 90,
  ),
  const ServiceModel(
    id: 'whitening',
    name: 'Teeth Whitening',
    category: 'Cosmetic',
    price: 250,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuCZZTa4G2vuEEe2LyGFSpo3brh3cDnQVGXR2mKVyRo1Kj47_onZMqp-qbwNqDMcaKzE2MvyxBFWqWRm3nF0BAKFBYR5aRtJCLry0BfY8Klu5o0fFbQ6_hAm-5c2Gg2eYgXjPJX-OXSN3OEHpIgFvCvHgtXoY2z9cutMBTgUj0w9Nr7C8kTJmYEUCCn2q1bD5OA9CGh8CJB2qt2CLIFUXOzIkX_qvGM__0iSlz6Q9ucJDqGJyJ1ME0dm',
    highlights: ['Laser technology', 'Immediate results', 'Safe & pain-free'],
    overview: 'Brighten your smile in a single visit with our in-office laser whitening treatment — safe, fast, and effective.',
    processSteps: [
      ProcessStep(title: 'Shade check', description: 'Assess current shade and set expectations.'),
      ProcessStep(title: 'Whitening', description: 'Laser-activated gel applied in sessions.'),
      ProcessStep(title: 'Aftercare', description: 'Sensitivity guidance and maintenance tips.'),
    ],
    rating: 4.9,
    reviewCount: 210,
    durationMinutes: 60,
    badge: 'Popular',
  ),
  const ServiceModel(
    id: 'invisalign',
    name: 'Invisalign',
    category: 'Orthodontics',
    price: 3500,
    imageUrl: 'https://lh3.googleusercontent.com/aida-public/AB6AXuD3k2LlF8vxth_sB2wvVgwPWpCi0kn1lF-lQihn2howEV4LgYv0VXALUC3HRtyejQ5WZzVHlhljhGJ9cgUbjUTXQb5iOhz-8JkMdagCZxJhcEYUQzJngyOAaZBeZGjRxCKZraWlTxyG22da_AhLnpitTkN8OKvPY1zRrlddBpMTQx6tXvxEiID1_5Cd4weCRkmsBAMYOk3EOdM6d_3-FjNQHQMGReSay6TAbyqaf5gYAI8FAykNTOqa',
    highlights: ['Clear aligners', 'Removable', 'Faster results'],
    overview: 'Straighten your teeth discreetly with a custom series of clear, removable aligners — no metal brackets required.',
    processSteps: [
      ProcessStep(title: 'Scan', description: '3D digital scan of your bite.'),
      ProcessStep(title: 'Aligner plan', description: 'Custom aligner series designed for your case.'),
      ProcessStep(title: 'Check-ins', description: 'Periodic progress reviews every few weeks.'),
    ],
    rating: 4.8,
    reviewCount: 178,
    durationMinutes: 45,
    badge: 'Premium',
  ),
];