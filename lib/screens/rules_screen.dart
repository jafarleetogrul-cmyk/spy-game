import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../providers/game_provider.dart';
import '../theme/app_theme.dart';
import '../l10n/strings.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lang = context.watch<GameProvider>().language;
    final sections = _getSections(lang);
    final title = lang == 'ru' ? 'Правила игры' : lang == 'en' ? 'Game Rules' : 'Oyun Qaydaları';

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.bgGrad),
        child: SafeArea(child: CustomScrollView(slivers: [
          SliverAppBar(backgroundColor: Colors.transparent, floating: true,
            leading: IconButton(icon: const Icon(Icons.arrow_back_ios), onPressed: () => Navigator.pop(context)),
            title: Text(title)),
          SliverToBoxAdapter(child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 0),
            child: Column(children: [
              Container(width: 80, height: 80,
                decoration: BoxDecoration(shape: BoxShape.circle, gradient: AppTheme.primaryGrad,
                  boxShadow: [BoxShadow(color: AppTheme.primary.withOpacity(0.4), blurRadius: 30)]),
                child: const Icon(Icons.menu_book, color: Colors.white, size: 44),
              ).animate().scale(begin: const Offset(0,0), duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 20),
            ]),
          )),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            sliver: SliverList(delegate: SliverChildBuilderDelegate(
              (ctx, i) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(color: AppTheme.card, borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white.withOpacity(0.06))),
                child: Theme(
                  data: Theme.of(ctx).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    initiallyExpanded: i == 0,
                    title: Text(sections[i][0], style: const TextStyle(color: AppTheme.textMain, fontWeight: FontWeight.w700, fontSize: 15)),
                    iconColor: AppTheme.primary, collapsedIconColor: AppTheme.textSub,
                    children: [Padding(padding: const EdgeInsets.fromLTRB(16,0,16,16),
                      child: Text(sections[i][1], style: const TextStyle(color: AppTheme.textSub, fontSize: 13, height: 1.7)))],
                  ),
                ),
              ).animate().fadeIn(delay: (i*60).ms),
              childCount: sections.length,
            )),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ])),
      ),
    );
  }

  List<List<String>> _getSections(String lang) {
    if (lang == 'ru') return [
      ['🎯 Что это?', 'Найди шпиона — психологическая игра на наблюдательность. Рекомендуется 4–8 игроков. Все должны собраться вместе в реальном мире.'],
      ['📋 Начало игры', '1. Создайте игру — вы становитесь хостом.\n2. Остальные сканируют QR-код и присоединяются.\n3. Когда все вошли, хост начинает раунд.'],
      ['🃏 Как проходит раунд?', 'Каждый игрок получает тайную карту. Мирные видят название места (напр. "Космическая станция"), шпион видит только "Ты шпион!".\n\nИгроки по очереди задают вопросы. Вопросы не должны слишком явно раскрывать место.'],
      ['👥 Задача мирных', 'Найдите шпиона через вопросы. Предложите голосование если есть подозреваемый.\n\n✅ Шпион найден → каждый мирный получает 1 очко.\n❌ Обвинён невиновный → шпион получает 2 очка.'],
      ['🕵️ Задача шпиона', 'Победить двумя способами:\n\n1. Пусть мирные обвинят другого мирного.\n2. Угадай место сам и объяви (только 1 попытка!).\n\n⚠️ Когда время истекает — объявлять место нельзя.'],
      ['⏱ Конец раунда', 'По истечении времени — голосование. Игрок с наибольшим числом голосов раскрывает роль.\n\nПобеждает тот, кто набрал больше всего очков!'],
      ['💡 Советы', '• Вопросы — не слишком очевидные и не слишком общие\n• Если шпион — ведите себя как мирный\n• Наблюдайте за языком тела!'],
    ];
    if (lang == 'en') return [
      ['🎯 What is this?', 'Spy Hunt is a social deduction game. Best played with 4–8 players gathered together in real life.'],
      ['📋 Starting the game', '1. Create a game — you become the host.\n2. Others scan the QR code to join.\n3. Once everyone joins, the host starts the round.'],
      ['🃏 How does a round work?', 'Each player gets a secret card. Civilians see the location (e.g. "Space Station"), the spy only sees "You are the spy!".\n\nPlayers take turns asking questions. Questions must not reveal the location too obviously.'],
      ['👥 Civilians goal', 'Find the spy through questions. Call a vote if someone is suspicious.\n\n✅ Spy found — each civilian gets 1 point.\n❌ Innocent accused — spy gets 2 points.'],
      ['🕵️ Spy goal', 'Win in two ways:\n\n1. Let civilians accuse another civilian.\n2. Guess the location yourself (only 1 attempt!).\n\nOnce time runs out, you cannot announce the location.'],
      ['⏱ End of round', 'When time is up, players must vote. The player with most votes reveals their role.\n\nThe player with the most points at the end wins!'],
      ['💡 Tips', '• Questions should be neither obvious nor too vague\n• If you are the spy, act natural\n• Observe body language — it reveals a lot!'],
    ];
    return [
      ['🎯 Bu nədir?', 'Casus Tap — casusu tapmaq məqsədi daşıyan psixoloji oyundur. 4–8 nəfərlik qrupla oynamaq məsləhətdir. Hamı real dünyada bir araya gəlməlidir.'],
      ['📋 Oyuna başlamaq', '1. Oyun yaradın — host olaraq oyunu başladın.\n2. Digər oyunçular QR kodu skan edərək qoşulsun.\n3. Hamı qoşulanda host raundu başladır.'],
      ['🃏 Raund necə keçir?', 'Hər raundda oyunçulara gizli kart verilir. Mülki şəxslər yer adını görür (məs. "Kosmos gəmisi"), casus isə yalnız "Sən casussan!" yazısını görür.\n\nOyunçular növbə ilə bir-birinə sual verir. Suallar yeri çox açıq şəkildə ifşa etməməlidir.'],
      ['👥 Mülki şəxsin vəzifəsi', 'Suallar vasitəsilə casusu tapın. Şübhəli biri varsa səsvermə təklif edin.\n\n✅ Casus tapılsa — hər mülki şəxs 1 xal alır.\n❌ Günahsız biri ittiham olunarsa — casus 2 xal alır.'],
      ['🕵️ Casusun vəzifəsi', 'İki yolla qazan:\n\n1. Digər oyunçular mülki şəxsi ittiham etsin.\n2. Yeri özün tap və elan et (yalnız 1 cəhd!).\n\nVaxt bitdikdə yeri elan etmək hüququ yoxdur.'],
      ['⏱ Raundun sonu', 'Vaxt bitdikdə oyunçular mütləq səsvermə keçirməlidir. Ən çox səs alan oyunçu rolunu açıqlayır.\n\nBütün raundlar bitdikdə ən çox xalı olan oyunçu qalib gəlir!'],
      ['💡 Məsləhətlər', '• Suallarınız nə çox açıq, nə çox ümumi olsun\n• Casussunuzsa, güvənilən kimi davranın\n• Müşahidəçi olun — bədən dili çox şey deyir!'],
    ];
  }
}
