/// File: mypage_main.dart
/// Purpose: 마이페이지 화면 구현
/// Author: 박민준
/// Created: 2025-01-02
/// Last Modified: 2025-02-12 by 윤은서
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:readventure/view/components/custom_app_bar.dart';
import 'package:readventure/view/components/custom_navigation_bar.dart';
import '../../theme/font.dart';
import '../../theme/theme.dart';
import '../../viewmodel/badge_provider.dart';
import '../../viewmodel/badge_service.dart';
import '../../viewmodel/custom_colors_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../viewmodel/user_photo_url_provider.dart';
import '../../viewmodel/user_service.dart';
import '../community/Ranking/ranking_component.dart';
import '../widgets/DoubleBackToExitWrapper.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// 마이페이지 메인 화면 위젯
/// - 상단 앱바, 하단 네비게이션 바, 컨텐츠
class MyPageMain extends ConsumerWidget {
  const MyPageMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = ref.watch(customColorsProvider);
    final userName = ref.watch(userNameProvider) ?? 'null'; // 사용자 이름 상태 구독

    return DoubleBackToExitWrapper(
      child: Scaffold(
        appBar: CustomAppBar_MyPage(),
        body: SafeArea(
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  customColors.neutral100 ?? Colors.white, // 위쪽 흰색
                  customColors.neutral90 ?? Colors.grey[300]!, // 아래쪽 회색
                ],
              ),
            ),
            child: MyPageContent(name: userName), // 실제 화면 컨텐츠에 이름 전달
          ),
        ),
        bottomNavigationBar: CustomNavigationBar(),
      ),
    );
  }
}

/// 마이페이지의 컨텐츠 본문
class MyPageContent extends StatelessWidget {
  final String name;
  const MyPageContent({super.key, required this.name});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            UserProfileSection(name: name), // 사용자 프로필 섹션에 이름 전달
            const SizedBox(height: 40),
            const UserStatsSection(), // 사용자 경험치, 코스, 랭킹 표시
            const SizedBox(height: 24),
            InfoCard(
              titleKey: 'my_page.stat_title',  // '학습 통계'
              descriptionKey: 'my_page.stat_desc',
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/statistics');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              titleKey: 'my_page.badge',
              child: BadgeRow(), // 수정: const 제거
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/badge');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              leadingIcon: Icons.article_rounded,
              titleKey: 'my_page.community_post',
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/mycommunitypost');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              leadingIcon: Icons.bookmark_rounded,
              titleKey: 'my_page.memo',
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/memo');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              leadingIcon: Icons.bookmark_rounded,
              titleKey: 'my_page.interpretation',
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/interpretation');
              },
            ),
            const SizedBox(height: 16),
            InfoCard(
              leadingIcon: Icons.book,
              titleKey: 'my_page.learning_history',
              trailingIcon: Icons.arrow_forward_ios,
              onTap: () {
                Navigator.pushNamed(context, '/mypage/info/history');
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// 사용자 프로필 섹션 (Firebase 사용자 프로필 사진 표시)
class UserProfileSection extends ConsumerWidget {
  final String name;
  const UserProfileSection({super.key, required this.name});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customColors = Theme.of(context).extension<CustomColors>()!;
    final photoUrl = ref.watch(userPhotoUrlProvider);
    return Row(
      children: [
        Container(
          width: 100,
          height: 100,
          decoration: ShapeDecoration(
            shape: CircleBorder(
              side: BorderSide(
                width: 3,
                color: customColors.neutral90 ?? Colors.grey[300]!,
              ),
            ),
          ),
          child: ClipOval(
            child: photoUrl != null
                ? Image.network(
              photoUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Image.asset('assets/images/default_avatar.png', fit: BoxFit.cover);
              },
            )
                : Image.asset('assets/images/default_avatar.png', fit: BoxFit.cover),
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: heading_small(context)),
              const SizedBox(height: 12),
              InkWell(
                onTap: () {
                  Navigator.pushNamed(context, '/mypage/edit_profile');
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: customColors.neutral90,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'my_page.edit_info'.tr(),  // '내 정보 수정'
                    style: pretendardMedium(context).copyWith(
                      fontSize: 14,
                      color: customColors.neutral30,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 상단 import 구문 아래에 provider 추가
final myRankingProvider = FutureProvider<int>((ref) async {
  final rankings = await getRankings();
  // 사용자 이름은 userNameProvider로부터 가져옵니다.
  final userName = ref.watch(userNameProvider) ?? '';
  // 랭킹 리스트에서 사용자 이름과 일치하는 항목의 인덱스를 찾습니다.
  final index = rankings.indexWhere((user) => user['name'] == userName);
  // 인덱스는 0부터 시작하므로 +1 해서 랭킹으로 표시 (만약 찾지 못하면 0)
  return index == -1 ? 0 : index + 1;
});

/// 사용자 경험치, 코스, 랭킹 통계 표시 섹션
class UserStatsSection extends ConsumerWidget {
  const UserStatsSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final xpAsyncValue = ref.watch(userXPProvider); // 경험치
    final courseAsyncValue = ref.watch(userCourseProvider); // 코스
    final rankingAsyncValue = ref.watch(myRankingProvider); // 내 랭킹
    final customColors = ref.watch(customColorsProvider);

    return SizedBox(
      height: 50,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: xpAsyncValue.when(
              data: (xp) => StatBox(value: xp.toString(), label: 'my_page.xp'.tr()),
              loading: () => const StatBox(value: '...', label: '경험치'),
              error: (_, __) => const StatBox(value: '오류', label: '경험치'),
            ),
          ),
          VerticalDivider(color: customColors.neutral80),
          Expanded(
            child: courseAsyncValue.when(
              data: (course) => StatBox(value: course, label: 'my_page.course'.tr()),
              loading: () => const StatBox(value: '...', label: '코스'),
              error: (_, __) => const StatBox(value: '오류', label: '코스'),
            ),
          ),
          VerticalDivider(color: customColors.neutral80),
          Expanded(
            child: rankingAsyncValue.when(
              data: (rank) => StatBox(value: '$rank위', label: 'my_page.ranking'.tr()),
              loading: () => const StatBox(value: '...', label: '랭킹'),
              error: (_, __) => const StatBox(value: '오류', label: '랭킹'),
            ),
          ),
        ],
      ),
    );
  }
}



/// 학습 통계 그래프 위젯
/*
class ProgressChart extends StatelessWidget {
  const ProgressChart({super.key});

  @override
  Widget build(BuildContext context) {
    List<TimeData> series1 = [
      TimeData(domain: DateTime(2025, 1, 6), measure: 7),
      TimeData(domain: DateTime(2025, 1, 7), measure: 5),
      TimeData(domain: DateTime(2025, 1, 8), measure: 9),
      TimeData(domain: DateTime(2025, 1, 9), measure: 10),
      TimeData(domain: DateTime(2025, 1, 10), measure: 6),
      TimeData(domain: DateTime(2025, 1, 11), measure: 1),
      TimeData(domain: DateTime(2025, 1, 12), measure: 8),
    ];

    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/mypage/info/statistics');
      },
      child: AbsorbPointer( // 내부 그래프 터치 이벤트를 무시하고 InfoCard의 onTap 동작
        child: SizedBox(
          height: 200,
          child: DChartBarT(
            fillColor: (group, timeData, index) {
              String day = DateFormat.E('ko').format(timeData.domain).substring(0, 1);
              return Theme.of(context).extension<CustomColors>()?.primary;
            },
            configRenderBar: ConfigRenderBar(
              barGroupInnerPaddingPx: 10,
              radius: 12,
            ),
            domainAxis: DomainAxis(
              showLine: true,
              tickLength: 0,
              gapAxisToLabel: 12,
              labelStyle: LabelStyle(
                color: Theme.of(context).colorScheme.onSurface,
              ),
              tickLabelFormatterT: (domain) {
                return DateFormat.E('ko').format(domain).substring(0, 1);
              },
            ),
            measureAxis: const MeasureAxis(
              showLine: true,
            ),
            groupList: [
              TimeGroup(
                id: '1',
                data: series1.map((e) => TimeData(
                  domain: e.domain,
                  measure: e.measure,
                )).toList(),
                color: Colors.transparent,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
*/

/// 수정된 BadgeBox 위젯
class BadgeBox extends StatelessWidget {
  final String label;
  final bool isUnlocked;
  final String? imageUrl; // 배지 이미지 URL 추가

  const BadgeBox({
    required this.label,
    required this.isUnlocked,
    this.imageUrl,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Column(
      children: [
        Container(
          width: screenWidth * 0.18,
          height: screenWidth * 0.18,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isUnlocked
                ? (customColors.neutral60 ?? Colors.indigoAccent)
                : (customColors.primary ?? Colors.grey),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: imageUrl != null
                ? Image.asset(
              imageUrl!,
              fit: BoxFit.contain,
            )
                : Icon(
              Icons.star,
              size: screenWidth * 0.10,
              color: isUnlocked
                  ? (customColors.neutral80 ?? Colors.white)
                  : (customColors.neutral100 ?? Colors.black26),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: body_small_semi(context),
        ),
      ],
    );
  }
}

class BadgeRow extends ConsumerWidget {
  const BadgeRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final badgesAsync = ref.watch(badgesProvider);

    return badgesAsync.when(
      data: (badges) {
        // 전체 배지 컬렉션에서 3개만 표시
        final displayBadges = badges.take(3).toList();
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: displayBadges.map((badge) {
            return Flexible(
              child: BadgeBox(
                label: badge.name,
                isUnlocked: true, // earned 여부와 관계없이 unlocked 상태로 표시
                imageUrl: badge.imageUrl,
              ),
            );
          }).toList(),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stackTrace) =>
          Center(child: Text('my_page.loading_error'.tr())),

    );
  }
}


/// 사용자 통계 박스 위젯
class StatBox extends StatelessWidget {
  final String value;
  final String label;

  const StatBox({
    required this.value,
    required this.label,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: pretendardSemiBold(context).copyWith(fontSize: 20)),
        const SizedBox(height: 4),
        Text(label, style: pretendardRegular(context).copyWith(fontSize: 12)),
      ],
    );
  }
}

/// 정보 카드 위젯
class InfoCard extends StatelessWidget {
  final String titleKey;
  final String? descriptionKey;
  final IconData? leadingIcon;
  final Widget? child;
  final IconData? trailingIcon;
  final VoidCallback? onTap;

  const InfoCard({
    required this.titleKey,
    this.descriptionKey,
    this.leadingIcon,
    this.child,
    this.trailingIcon,
    this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final String title = titleKey.tr();
    final String? description = descriptionKey?.tr();
    final bool isDisabled = titleKey == 'my_page.stat_title' || titleKey == 'my_page.learning_history';

    return InkWell(
      onTap: isDisabled ? null : onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDisabled ? Colors.black.withOpacity(0.05) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isDisabled
              ? []
              : [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 2, offset: const Offset(0, 1))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    if (leadingIcon != null) ...[
                      Icon(leadingIcon, size: 24, color: Colors.black54),
                      const SizedBox(width: 12),
                    ],
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: pretendardSemiBold(context).copyWith(fontSize: 18)),
                        if (description != null) ...[
                          const SizedBox(height: 4),
                          Text(description, style: pretendardRegular(context).copyWith(fontSize: 16, color: Colors.black54)),
                        ],
                      ],
                    ),
                  ],
                ),
                if (trailingIcon != null)
                  Icon(
                    isDisabled ? Icons.lock : trailingIcon,
                    size: 20,
                    color: isDisabled ? Colors.grey : Colors.black54,
                  ),
              ],
            ),
            if (child != null && !isDisabled) ...[
              const SizedBox(height: 16),
              child!,
            ],
          ],
        ),
      ),
    );
  }
}
