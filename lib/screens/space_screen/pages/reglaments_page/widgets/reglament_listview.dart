import 'package:flutter/material.dart';
import 'package:unityspace/models/reglament_models.dart';
import 'package:unityspace/screens/space_screen/pages/reglaments_page/widgets/pop_up_reglament_button.dart';

class ReglamentListView extends StatelessWidget {
  final List<Reglament> columnReglaments;

  const ReglamentListView({
    required this.columnReglaments,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: ListView.builder(
          itemCount: columnReglaments.length,
          itemBuilder: (BuildContext context, int index) {
            final columnReglament = columnReglaments[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ColoredBox(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          columnReglament.name,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      PopUpReglamentButton(
                        reglament: columnReglament,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
