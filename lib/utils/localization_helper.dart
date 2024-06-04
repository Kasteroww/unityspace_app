import 'package:flutter/material.dart';
import 'package:unityspace/resources/l10n/app_localizations.dart';

/// Класс, содержащий в себе методы поддержки локализации в приложении
class LocalizationHelper {
  const LocalizationHelper();

  ///Проверка локализации на инициализацию
  ///
  ///В случае, если локализация не найдена, выдает exception
  static AppLocalizations getLocalizations(BuildContext context) {
    final localization = AppLocalizations.of(context);
    if (localization == null) {
      throw Exception(
        'Localizations not found. Ensure localization is initialized properly.',
      );
    }
    return localization;
  }
}

String getColorName(String color, AppLocalizations localization) {
  final Map<String, String> colors = {
    '#D5D5D5': localization.abdel_kerim_beard_color,
    '#D8EFF4': localization.light_blue,
    '#F3E2D9': localization.orange,
    '#F1DBF2': localization.purple,
    '#D9DDF3': localization.blue,
    '#E5F5DD': localization.lettuce_green,
    '#CAECD8': localization.green,
    '#ECDECA': localization.brown,
    '#F4F5F7': localization.crayola_periwinkle_1,
    '#D8F0F4': localization.dusty_blue_1,
    '#F3E2DA': localization.crayola_almond_1,
    '#D9DDEF': localization.crayola_periwinkle_2,
    '#E5F4DD': localization.beige,
    '#CBECD9': localization.dusty_blue_2,
    '#E3EBFF': localization.alice_blue,
    '#E2FAFD': localization.pang,
    '#E8FFFA': localization.celestial_azure,
    '#FFF6E5': localization.cosmic_cream,
    '#FFE5E9': localization.dim_pink_1,
    '#FFEEE4': localization.sea_foam,
    '#E8E1FF': localization.light_lilac_pink,
    '#FBEAE3': localization.scared_nymph_thighs_1,
    '#F7F4EF': localization.pearl_white_1,
    '#EDECEA': localization.forest_wolf_1,
    '#EDDFDE': localization.dim_amaranth_pink_1,
    '#FBEFE1': localization.scared_nymph_thighs_2,
    '#F8F6F7': localization.smoky_white_1,
    '#E9E7E6': localization.gainsboro,
    '#F9E8E2': localization.linen_1,
    '#FAF3EB': localization.linen_2,
    '#EAEEE0': localization.very_pale_green_1,
    '#F9F9F9': localization.smoky_white_2,
    '#ECF7FB': localization.lavender,
    '#D9E6EC': localization.crayola_periwinkle_3,
    '#E2FFFE': localization.light_cyan_1,
    '#EFEFEF': localization.smoky_white_3,
    '#ECDCDC': localization.dim_amaranth_pink_2,
    '#E9CCC4': localization.very_pale_purple,
    '#E7E7DB': localization.forest_wolf_2,
    '#DFD8AA': localization.very_pale_green_2,
    '#E5ECF2': localization.crayola_periwinkle_4,
    '#DEC8BB': localization.pale_sandy,
    '#F1FFDB': localization.light_green_1,
    '#E5FFCF': localization.light_lettuce,
    '#D7FFCD': localization.light_green_2,
    '#D2FFEB': localization.light_cyan_2,
    '#BEF1F5': localization.pale_blue,
    '#FFDBDB': localization.dim_pink_2,
    '#FFEDE1': localization.sea_shell_color,
    '#F2BFCA': localization.light_pink,
    '#F9D5C6': localization.purplish_white,
    '#FFEDD6': localization.papaya_escape,
    '#BDD4D1': localization.very_light_blue_green,
    '#B0C2D4': localization.very_light_blue,
    '#CFCBC9': localization.crayola_silver,
    '#ECE8DB': localization.pearl_white_2,
    '#EDDECB': localization.crayola_almond_2,
    '#CDB4DB': localization.wisteria,
    '#FFC8DD': localization.pale_pink,
    '#FFAFCC': localization.pink_carnation,
    '#BDE0FE': localization.blue_blue_frost_1,
    '#A2D2FF': localization.blue_blue_frost_2,
    '#D9A1C8': localization.light_plum,
    '#F5ECCF': localization.greenish_white,
    '#EBECE6': localization.forest_wolf_3,
    '#E1FAFF': localization.light_cyan_3,
    '#7BF1A7': localization.light_green_3,
    '#C1FBA4': localization.pale_green,
    '#FFEF9F': localization.canary,
    '#91F1EF': localization.crayola_blue,
    '#FFB5B5': localization.light_pink_2,
    '#F9EEDA': localization.creamy,
    '#D8F8FF': localization.light_cyan_4,
    '#D8FFF7': localization.light_cyan_5,
    '#F3DDFF': localization.lavender_2,
    '#FFAECC': localization.pink_carnation_2,
    '#FCE7CA': localization.refined_almond,
    '#FFF5C2': localization.lemon_cream,
    '#C3F8F1': localization.pang_2,
    '#FFC8D4': localization.pale_pink_2,
    '#FDE2D3': localization.purplish_white_2,
    '#CAECDE': localization.dusty_blue_3,
    '#E1E6FF': localization.lavender_blue,
    '#E7E0FF': localization.light_mauve,
    '#FCC6B7': localization.crayola_cantaloupe,
    '#FAD5C0': localization.biscuit,
    '#E7E7E7': localization.platinum,
  };
  return colors[color] ?? color;
}
