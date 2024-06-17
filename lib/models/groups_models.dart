import 'package:unityspace/models/spaces_models.dart';
import 'package:unityspace/service/exceptions/data_exceptions.dart';
import 'package:unityspace/utils/helpers.dart';

class GroupResponse {
  final int id;
  final String name;
  final String order;
  final bool isOpen;

  const GroupResponse({
    required this.id,
    required this.name,
    required this.order,
    required this.isOpen,
  });

  factory GroupResponse.fromJson(Map<String, dynamic> json) {
    try {
      return GroupResponse(
        id: json['id'] as int,
        name: json['name'] as String,
        order: json['order'] as String,
        isOpen: json['isOpen'] as bool,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class Group {
  final int id;
  final String name;
  final double order;
  final bool isOpen;

  const Group({
    required this.id,
    required this.name,
    required this.order,
    required this.isOpen,
  });

  factory Group.fromResponse(GroupResponse data) {
    return Group(
      id: data.id,
      name: data.name,
      order: convertFromOrderResponse(int.parse(data.order)),
      isOpen: data.isOpen,
    );
  }
}

class GroupOrder {
  final int id;
  final double order;

  const GroupOrder({
    required this.id,
    required this.order,
  });
}

class GroupWithSpaces {
  final int? groupId;
  final double groupOrder;
  final String name;
  final List<Space> spaces;
  final bool isOpen;

  const GroupWithSpaces({
    required this.groupId,
    required this.groupOrder,
    required this.name,
    required this.spaces,
    required this.isOpen,
  });
}
