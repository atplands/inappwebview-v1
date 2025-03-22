class Slide {
  final String imageUrl;
  final String title;
  final String description;

  Slide({
    required this.imageUrl,
    required this.title,
    required this.description,
  });
}

final slideList = [
  Slide(
      imageUrl: 'https://cloudaiorg.com/static/assets2/images/1.jpg',
      title: 'A Cool Way to Referrence',
      description:
          'Elevate your IT career with Referrals: Connect top talent with ideal tech roles and earn rewards.'),
  Slide(
      imageUrl: 'https://cloudaiorg.com/static/assets2/images/2.jpeg',
      title: 'Certfications Dashboard ',
      description:
          '"Master global IT Cert: From Azure to AWS, GCP to Oracle – elevate your expertise and career potential.'),
  Slide(
      imageUrl: 'https://cloudaiorg.com/static/assets2/images/3.jpeg',
      title: 'Mock Interviews Program',
      description:
          'Comprehensive IT IQ with MockIQ: Ace your interviews with realistic mock sessions led by industry experts.'),
  Slide(
      imageUrl: 'https://cloudaiorg.com/static/assets2/images/4.jpeg',
      title: 'Job Support Program ',
      description:
          '"Master Skills with JobSP: Boost your career with job support for all entry level freebies to experienced levels resources.'),
  Slide(
      imageUrl: 'https://cloudaiorg.com/static/assets2/images/5.jpeg',
      title: 'Addons Video Dashboard',
      description:
          'Comprehensive IT career support: From resume building to Career Guidance planning – your one-stop app for professional growth.'),
];
