import 'package:adams_county_scheduler/logical_interface/bloc/schools/schools_bloc.dart';
import 'package:adams_county_scheduler/user_interface/widgets/colored_container.dart';
import 'package:adams_county_scheduler/user_interface/widgets/input_field.dart';
import 'package:adams_county_scheduler/utilities/colors/ac_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

class SchoolCreationPage extends StatefulWidget {
  const SchoolCreationPage({super.key});

  @override
  State<SchoolCreationPage> createState() => _SchoolCreationPageState();
}

class _SchoolCreationPageState extends State<SchoolCreationPage> {
  final TextEditingController _shortNameController = TextEditingController();
  final List<String> categories = [
    'High School',
    'Junior High School',
    'Middle School',
    'Elementary School',
    'K - 8',
    'Pre - K',
    'Other',
  ];
  String time = 'PM';

  List<String> times = ['AM', 'PM'];
  late String category;
  XFile? image;

  double uploadProgress = 0;

  @override
  void initState() {
    category = categories.first;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<SchoolsBloc, SchoolsState>(
      listener: (context, state) {
        if (state is ImageUploadProgressUpdated) {
          setState(() {
            uploadProgress = state.progress;
          });
        } else if (state is SchoolCreated) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add a school'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width / 2,
                        height: MediaQuery.of(context).size.width / 3.5,
                        child: image == null
                            ? ColoredContainer(
                          onTap: () async {
                            XFile? selectedImage = await ImagePicker()
                                .pickImage(source: ImageSource.gallery);

                            if (selectedImage != null) {
                              setState(() {
                                image = selectedImage;
                              });
                            }
                          },
                          backgroundColor: ACColors.primaryColor,
                          child: Icon(
                            Icons.image_outlined,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface,
                            size: MediaQuery.of(context).size.width / 20,
                          ),
                        )
                            : GestureDetector(
                          onTap: () async {
                            if (uploadProgress == 0) {
                              XFile? selectedImage = await ImagePicker()
                                  .pickImage(source: ImageSource.gallery);

                              if (selectedImage != null) {
                                setState(() {
                                  image = selectedImage;
                                });
                              }
                            }
                          },
                          child: Stack(
                            children: [
                              Positioned.fill(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20),
                                  child: FutureBuilder(
                                    future: image!.readAsBytes(),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Image.memory(
                                          snapshot.requireData,
                                          fit: BoxFit.cover,
                                        );
                                      }

                                      return const Center(
                                        child:
                                        CircularProgressIndicator(),
                                      );
                                    },
                                  ),
                                ),
                              ),
                              uploadProgress > 0
                                  ? Center(
                                child: CircularProgressIndicator(
                                  value: uploadProgress,
                                ),
                              )
                                  : Container(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: SizedBox(
                          height: MediaQuery.of(context).size.width / 3.5,
                          child: Column(
                            children: [
                              InputField(
                                hintText: 'GAHS',
                                controller: _shortNameController,
                                maxCharacters: 6,
                                label: 'School Short Name',
                                validator: (value) {
                                  if (value?.trim().isEmpty ?? true) {
                                    return 'Short Name may not be empty';
                                  }
                                  return null;
                                },
                              ),
                              DropdownButton(
                                items: times.map<DropdownMenuItem<String>>(
                                        (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                onChanged: (value) => setState(() {
                                  time = value!;
                                }),
                                value: time,),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: ColoredContainer(
                                    backgroundColor: ACColors.primaryColor,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: DropdownButton<String>(
                                        isExpanded: true,
                                        underline: Container(),
                                        value: category,
                                        items: categories
                                            .map<DropdownMenuItem<String>>(
                                              (e) => DropdownMenuItem<String>(
                                            value: e,
                                            child: Text('Session: $e'),
                                          ),
                                        )
                                            .toList(),
                                        onChanged: (value) {
                                          if (value != null) {
                                            setState(() {
                                              category = value;
                                            });
                                          }
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: MouseRegion(
                  cursor: uploadProgress > 0
                      ? MouseCursor.defer
                      : SystemMouseCursors.click,
                  child: ColoredContainer(
                    onTap: () {
                      if (uploadProgress == 0) {
                        context.read<SchoolsBloc>().add(
                          CreateSchool(
                            schoolShortName:
                            _shortNameController.text.trim(),
                            schoolName: _shortNameController.text.trim(),
                            category: category,
                            image: image,
                            time: time,
                          ),
                        );
                      }
                    },
                    backgroundColor: ACColors.secondaryColor
                        .withOpacity(uploadProgress > 0 ? .4 : 1),
                    child: Text(
                      uploadProgress > 0 ? 'Uploading Image' : 'Create School',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
