import 'package:adams_county_scheduler/logical_interface/bloc/students/students_bloc.dart';
import 'package:adams_county_scheduler/user_interface/widgets/colored_container.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_excel/excel.dart';

class BulkStudentUploadPage extends StatefulWidget {
  const BulkStudentUploadPage({super.key});

  @override
  State<BulkStudentUploadPage> createState() => _BulkStudentUploadPageState();
}

class _BulkStudentUploadPageState extends State<BulkStudentUploadPage> {
  Sheet? uploadedSheet;

  int maxSize = 0;

  String error = '';

  final List<String> cells = [
    'first name',
    'last name',
    'school',
    '1 priority',
    '2 priority',
    '3 priority',
    '4 priority',
    '5 priority',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulk Student Creation'),
      ),
      body: BlocBuilder<StudentsBloc, StudentsState>(
        builder: (context, state) {
          return AnimatedCrossFade(
            firstChild: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 4,
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ColoredContainer(
                          onTap: () async {
                            firebase_storage.Reference ref = firebase_storage
                                .FirebaseStorage.instance
                                .ref('templates/TestData.xlsx');

                            // Get the download URL
                            String url = await ref.getDownloadURL();
                            html.AnchorElement(href: url)
                              ..setAttribute('download', 'TestData.xlsx')
                              ..click();
                            html.Url.revokeObjectUrl(url);
                          },
                          backgroundColor:
                          Theme.of(context).colorScheme.primary,
                          child: Text(
                            'Download Template File',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 4,
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ColoredContainer(
                          onTap: () async {
                            FilePickerResult? result =
                            await FilePicker.platform.pickFiles(
                              type: FileType.custom,
                              allowedExtensions: ['xlsx'],
                              allowMultiple: false,
                            );

                            if (result != null) {
                              List<int>? bytes =
                              result.files.single.bytes?.toList();
                              if (bytes != null) {
                                Excel excel = Excel.decodeBytes(bytes);

                                Sheet sheet =
                                excel.tables[excel.tables.keys.first]!;

                                List<Data?> headers = sheet.row(0);

                                List<String> headerValues = headers
                                    .map<String>(
                                      (e) =>
                                  e?.value.toString().toLowerCase() ??
                                      '',
                                )
                                    .toList();
                                headerValues.sort((a, b) => a.compareTo(b));
                                cells.sort((a, b) => a.compareTo(b));

                                if (headerValues.toString() ==
                                    cells.toString()) {
                                  setState(() {
                                    maxSize = sheet.maxRows;
                                    uploadedSheet = sheet;
                                  });
                                } else {
                                  setState(() {
                                    error =
                                    'This excel does not have valid headers';
                                  });
                                }
                              }
                            }
                          },
                          backgroundColor:
                          Theme.of(context).colorScheme.primary,
                          child: Text(
                            'Select File',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.surface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: error.isEmpty
                      ? const Text(
                    'Please select an excel file with column headers "First Name", "Last Name", "School", "n priorty" with values 1-5 for n',
                  )
                      : Text(
                    error,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
                uploadedSheet == null
                    ? Container()
                    : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'You have uploaded a valid excel with $maxSize students. Proceed to upload?',
                    style: const TextStyle(color: Colors.green),
                  ),
                ),
                uploadedSheet == null
                    ? Container()
                    : Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width / 4,
                      ),
                      child: MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: ColoredContainer(
                          onTap: () async {
                            context.read<StudentsBloc>().add(
                              BulkUploadStudents(
                                sheet: uploadedSheet!,
                              ),
                            );
                          },
                          backgroundColor:
                          Theme.of(context).colorScheme.secondary,
                          child: Text(
                            'Upload $maxSize Students',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .surface,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            secondChild: state is BulkUploadStarted
                ? const Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(),
                  ),
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'We are rolling the students into the cloud.. This may take a moment',
                    ),
                  ),
                ],
              ),
            )
                : state is UploadFinished
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: MediaQuery.of(context).size.width / 6,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Your upload has been finished!'),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ElevatedButton(
                      onPressed: () => context
                          .read<StudentsBloc>()
                          .add(ResetBulkUpload()),
                      child: const Text('Upload More'),),
                  ),
                  state.errors.isEmpty
                      ? Container()
                      : const Text(
                    'We ran into errors with the following students...',
                  ),
                  state.errors.isEmpty
                      ? Container()
                      : Expanded(
                    child: Center(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: state.errors.length,
                        itemBuilder: (context, index) =>
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                state.errors.elementAt(index),
                              ),
                            ),
                      ),
                    ),
                  ),
                ],
              ),
            )
                : Container(),
            crossFadeState:
            (state is BulkUploadStarted || state is UploadFinished)
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(seconds: 1),
          );
        },
      ),
    );
  }
}
