import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:savedatabase/providers/dog_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DogProvider>(context, listen: true);
    Future<void> saveDog() async {
      try {
        var provider = Provider.of<DogProvider>(context, listen: false);

        await provider.saveDog(provider.newDog);
        Fluttertoast.showToast(
            msg: "Doggy info saved",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: CupertinoColors.systemIndigo,
            textColor: CupertinoColors.white,
            fontSize: 16.0);

        HapticFeedback.vibrate();
      } catch (e) {
        print(e);
      }
    }

    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text(
          'Add Dog Info',
          style: TextStyle(color: CupertinoColors.white),
        ),
        backgroundColor: CupertinoColors.systemIndigo,
      ),
      child: Form(
        key: formKey,
        child: CupertinoListSection.insetGrouped(
          decoration: const BoxDecoration(
            color: CupertinoColors.white,
          ),
          clipBehavior: Clip.antiAlias,
          children: [
            CupertinoFormRow(
              prefix: const Text('Name'),
              child: CupertinoTextFormFieldRow(
                placeholder: 'Name',
                onSaved: (newValue) {
                  provider.name = newValue.toString();
                },
              ),
            ),
            CupertinoFormRow(
              prefix: const Text('Age'),
              child: CupertinoTextFormFieldRow(
                keyboardType: TextInputType.number,
                placeholder: 'Age',
                onSaved: (newValue) {
                  provider.age = int.parse(newValue.toString());
                },
              ),
            ),
            CupertinoFormRow(
              child: CupertinoButton(
                child: const Text('Save'),
                onPressed: () {
                  final form = formKey.currentState!;

                  if (form.validate()) {
                    provider.id = 1;
                    form.save();
                    saveDog();
                  }

                  form.reset();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
