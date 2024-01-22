import 'package:adams_county_scheduler/objects/career_priority.dart';
import 'package:adams_county_scheduler/user_interface/widgets/input_field.dart';
import 'package:flutter/cupertino.dart';

class CareerPriorityBuilder extends StatefulWidget {
  final Function(CareerPriority) onChanged;

  const CareerPriorityBuilder({super.key, required this.onChanged});

  @override
  State<CareerPriorityBuilder> createState() => _CareerPriorityBuilderState();
}

class _CareerPriorityBuilderState extends State<CareerPriorityBuilder> {
  List<TextEditingController> controllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: InputField(
            onChanged: (value) {
              widget.onChanged(
                CareerPriority(
                  firstChoice: int.parse(controllers[0].text.trim()),
                  secondChoice: int.parse(controllers[1].text.trim()),
                  thirdChoice: int.parse(controllers[2].text.trim()),
                  fourthChoice: int.parse(controllers[3].text.trim()),
                  fifthChoice: int.parse(controllers[4].text.trim()),
                ),
              );
            },
            hintText: 'Police, Fire fighter, etc.',
            controller: controllers[index],
          ),
        );
      },
    );
  }
}
