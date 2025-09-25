import 'dart:io';
import 'dart:math';
import 'package:ai_poetry_card/models/poetry_card.dart';

class AIPoetryService {
  // 模拟AI文案生成服务
  // 在实际应用中，这里会调用真实的AI API

  Future<String> generatePoetry(File image, PoetryStyle style,
      {String? userDescription, String? userProfile}) async {
    // 模拟网络延迟
    await Future.delayed(const Duration(seconds: 2));

    // 只使用用户描述生成文案，用户信息仅用于背景选择
    final context = _buildUserContext(userDescription, null);

    // 根据用户描述和风格生成文案
    return _generatePoetryWithContext(context, style);
  }

  String _buildUserContext(String? userDescription, String? userProfile) {
    final parts = <String>[];

    // 只使用用户描述，不显示用户信息
    if (userDescription != null && userDescription.isNotEmpty) {
      parts.add('当前描述：$userDescription');
    }

    return parts.join('，');
  }

  String _generatePoetryWithContext(String context, PoetryStyle style) {
    // 如果有用户上下文，优先使用上下文生成文案
    if (context.isNotEmpty) {
      return _generatePoetryFromContext(context, style);
    }

    // 根据风格返回不同的文案
    return _getRandomPoetry(style);
  }

  String _generatePoetryFromContext(String context, PoetryStyle style) {
    final random = Random();

    switch (style) {
      case PoetryStyle.modernPoetic:
        final modernTemplates = [
          '在$context中寻找诗意',
          '$context让生活更美好',
          '感受$context的魅力',
          '$context如诗如画',
          '关于$context的诗意瞬间',
        ];
        return modernTemplates[random.nextInt(modernTemplates.length)];

      case PoetryStyle.classicalElegant:
        final classicalTemplates = [
          '关于$context的古韵',
          '$context如诗如画',
          '品味$context的意境',
          '$context传千古',
          '$context的诗意传承',
        ];
        return classicalTemplates[random.nextInt(classicalTemplates.length)];

      case PoetryStyle.humorousPlayful:
        final playfulTemplates = [
          '$context真有趣！',
          '关于$context的小确幸',
          '$context让心情变好',
          '今天也要$context鸭！',
          '$context的快乐时光',
        ];
        return playfulTemplates[random.nextInt(playfulTemplates.length)];

      case PoetryStyle.warmLiterary:
        final warmTemplates = [
          '$context如诗如画',
          '关于$context的温暖',
          '$context让心更温暖',
          '感受$context的美好',
          '$context的温馨时刻',
        ];
        return warmTemplates[random.nextInt(warmTemplates.length)];

      case PoetryStyle.minimalTags:
        return '#$context';

      case PoetryStyle.sciFiImagination:
        final sciFiTemplates = [
          '$context的量子态',
          '在$context中发现未来',
          '$context的时空坐标',
          '探索$context的维度',
          '$context的科幻想象',
        ];
        return sciFiTemplates[random.nextInt(sciFiTemplates.length)];

      case PoetryStyle.deepPhilosophical:
        final philosophicalTemplates = [
          '关于$context的思考',
          '$context的哲学意义',
          '从$context中感悟',
          '$context的智慧',
          '$context的人生哲理',
        ];
        return philosophicalTemplates[
            random.nextInt(philosophicalTemplates.length)];

      case PoetryStyle.blindBox:
        // 盲盒模式：随机选择所有风格中的一句
        final allTemplates = [
          '在$context中寻找诗意',
          '$context如诗如画',
          '$context真有趣！',
          '$context让心更温暖',
          '$context的哲学意义',
          '#$context',
          '$context的量子态',
        ];
        return allTemplates[random.nextInt(allTemplates.length)];
    }
  }

  String _getRandomPoetry(PoetryStyle style) {
    final random = Random();

    switch (style) {
      case PoetryStyle.modernPoetic:
        final modernPoems = [
          '落日熔金，潮汐私语，世界沉入温柔的尾声',
          '时光如诗，岁月如歌',
          '在平凡中寻找不平凡',
          '每一个瞬间都值得被记录',
          '生活如诗，诗意如画',
          '用心感受，用爱记录',
          '在喧嚣中寻找宁静',
          '美好就在身边',
          '时光荏苒，记忆永恒',
          '简单的生活，诗意的人生',
        ];
        return modernPoems[random.nextInt(modernPoems.length)];

      case PoetryStyle.classicalElegant:
        final classicalPoems = [
          '碧海衔落日，余晖镀金波。孤云随雁远，心共晚风和',
          '山重水复疑无路，柳暗花明又一村',
          '落红不是无情物，化作春泥更护花',
          '采菊东篱下，悠然见南山',
          '海内存知己，天涯若比邻',
          '会当凌绝顶，一览众山小',
          '长风破浪会有时，直挂云帆济沧海',
          '山不在高，有仙则名',
          '水不在深，有龙则灵',
          '春眠不觉晓，处处闻啼鸟',
        ];
        return classicalPoems[random.nextInt(classicalPoems.length)];

      case PoetryStyle.humorousPlayful:
        final playfulPoems = [
          '太阳下班了，我也挺饿的，海鲜面能不能多加个蛋？',
          '今天也要加油鸭！',
          '生活就像巧克力，你永远不知道下一颗是什么味道',
          '开心最重要，其他都是浮云',
          '每天都要开心鸭！',
          '生活需要一点甜',
          '今天也要元气满满！',
          '快乐就是这么简单',
          '生活很苦，但你要甜',
          '今天也要努力鸭！',
        ];
        return playfulPoems[random.nextInt(playfulPoems.length)];

      case PoetryStyle.warmLiterary:
        final warmPoems = [
          '把一天的烦恼，都丢进海里喂鱼',
          '你是我心中的诗',
          '爱如春风，温柔如水',
          '与你相遇，如诗如画',
          '时光不老，我们不散',
          '你是我最美的意外',
          '爱是永恒的主题',
          '与你共度，便是诗',
          '心之所向，皆是美好',
          '爱让平凡变得特别',
        ];
        return warmPoems[random.nextInt(warmPoems.length)];

      case PoetryStyle.minimalTags:
        final tagOptions = [
          '#落日 #海岸 #黄昏',
          '#生活 #美好 #瞬间',
          '#诗意 #时光 #记忆',
          '#温暖 #治愈 #日常',
          '#自然 #宁静 #思考',
        ];
        return tagOptions[random.nextInt(tagOptions.length)];

      case PoetryStyle.sciFiImagination:
        final sciFiPoems = [
          '恒星为这片海域提供了今日最后一次能源灌注',
          '神秘是生活的调味剂',
          '未知中藏着惊喜',
          '神秘让世界更精彩',
          '探索未知的乐趣',
          '神秘是诗意的源泉',
          '未知中充满可能',
          '神秘让想象飞翔',
          '探索是心灵的冒险',
          '神秘是生活的魅力',
        ];
        return sciFiPoems[random.nextInt(sciFiPoems.length)];

      case PoetryStyle.deepPhilosophical:
        final philosophicalPoems = [
          '思考是灵魂的对话',
          '智慧在静默中生长',
          '人生如棋，步步为营',
          '真理在简单中显现',
          '思考让生命更有意义',
          '智慧源于内心的平静',
          '人生如书，每页都是故事',
          '思考是通往智慧的桥梁',
          '真理往往藏在平凡中',
          '智慧是时间的馈赠',
        ];
        return philosophicalPoems[random.nextInt(philosophicalPoems.length)];

      case PoetryStyle.blindBox:
        // 盲盒模式：随机选择所有风格中的一句
        final allPoems = [
          '落日熔金，潮汐私语，世界沉入温柔的尾声',
          '碧海衔落日，余晖镀金波。孤云随雁远，心共晚风和',
          '太阳下班了，我也挺饿的，海鲜面能不能多加个蛋？',
          '把一天的烦恼，都丢进海里喂鱼',
          '#落日 #海岸 #黄昏',
          '恒星为这片海域提供了今日最后一次能源灌注',
          '思考是灵魂的对话',
          '时光如诗，岁月如歌',
          '山重水复疑无路，柳暗花明又一村',
          '今天也要加油鸭！',
        ];
        return allPoems[random.nextInt(allPoems.length)];
    }
  }
}
