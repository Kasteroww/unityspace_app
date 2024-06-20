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

  Group copyWith({
    int? id,
    String? name,
    double? order,
    bool? isOpen,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      order: order ?? this.order,
      isOpen: isOpen ?? this.isOpen,
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

  GroupWithSpaces copyWith({
    int? groupId,
    double? groupOrder,
    String? name,
    List<Space>? spaces,
    bool? isOpen,
  }) {
    return GroupWithSpaces(
      groupId: groupId ?? this.groupId,
      groupOrder: groupOrder ?? this.groupOrder,
      name: name ?? this.name,
      spaces: spaces ?? this.spaces,
      isOpen: isOpen ?? this.isOpen,
    );
  }
}

class UpdateGroupOrderResponse {
  final int id;
  final String order;

  UpdateGroupOrderResponse({
    required this.id,
    required this.order,
  });

  factory UpdateGroupOrderResponse.fromJson(Map<String, dynamic> json) {
    try {
      return UpdateGroupOrderResponse(
        id: json['id'] as int,
        order: json['order'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class UpdateGroupOrder {
  final int id;
  final double order;

  UpdateGroupOrder({
    required this.id,
    required this.order,
  });

  factory UpdateGroupOrder.fromResponse(UpdateGroupOrderResponse data) {
    return UpdateGroupOrder(
      id: data.id,
      order: convertFromOrderResponse(int.parse(data.order)),
    );
  }
}

class UpdateGroupNameResponse {
  final int id;
  final String name;

  UpdateGroupNameResponse({
    required this.id,
    required this.name,
  });

  factory UpdateGroupNameResponse.fromJson(Map<String, dynamic> json) {
    try {
      return UpdateGroupNameResponse(
        id: json['id'] as int,
        name: json['name'] as String,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class UpdateGroupName {
  final int id;
  final String name;

  UpdateGroupName({
    required this.id,
    required this.name,
  });

  factory UpdateGroupName.fromResponse(UpdateGroupNameResponse data) {
    return UpdateGroupName(
      id: data.id,
      name: data.name,
    );
  }
}

class UpdateGroupOpenResponse {
  final int id;
  final bool isOpen;

  UpdateGroupOpenResponse({
    required this.id,
    required this.isOpen,
  });

  factory UpdateGroupOpenResponse.fromJson(Map<String, dynamic> data) {
    try {
      return UpdateGroupOpenResponse(
        id: data['id'] as int,
        isOpen: data['isOpen'] as bool,
      );
    } catch (e, stack) {
      throw JsonParsingException('Error parsing Model', e, stack);
    }
  }
}

class UpdateGroupOpen {
  final int id;
  final bool isOpen;

  UpdateGroupOpen({
    required this.id,
    required this.isOpen,
  });

  factory UpdateGroupOpen.fromResponse(UpdateGroupOpenResponse data) {
    return UpdateGroupOpen(
      id: data.id,
      isOpen: data.isOpen,
    );
  }
}
