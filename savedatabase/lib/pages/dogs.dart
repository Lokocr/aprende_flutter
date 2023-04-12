import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:savedatabase/providers/dog_provider.dart';

class DogsPage extends StatefulWidget {
  const DogsPage({super.key});

  @override
  State<DogsPage> createState() => _DogsPageState();
}

class _DogsPageState extends State<DogsPage> {
  void _showActionSheet(BuildContext context, int id) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Cancel'),
        ),
        actions: <CupertinoActionSheetAction>[
          CupertinoActionSheetAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Edit Doggy'),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () {
              // show alert dialog
              Navigator.pop(context);
              _showAlertDialog(context, id);
            },
            child: const Text('Remove Doggy'),
          ),
        ],
      ),
    );
  }

  void _showAlertDialog(BuildContext context, int id) {
    showCupertinoModalPopup<void>(
      context: context,
      builder: (BuildContext context) => CupertinoAlertDialog(
        title: const Text('Caution'),
        content: const Text('Are you sure you want to remove the Doggy?'),
        actions: <CupertinoDialogAction>[
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('No'),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              Navigator.pop(context);
              _deleteDog(id);
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  // Create a method that call provider to delete a dog
  void _deleteDog(int id) {
    Provider.of<DogProvider>(context, listen: false).removeDog(id);
  }

  @override
  Widget build(BuildContext context) {
    var provider = Provider.of<DogProvider>(context, listen: true);
    provider.getDogs();
    var listOfDogs = provider.dogs;
    return CupertinoPageScaffold(
      backgroundColor: CupertinoColors.systemGrey6,
      child: CustomScrollView(
        slivers: <Widget>[
          const CupertinoSliverNavigationBar(
            largeTitle: Text(
              'List of pets',
              style: TextStyle(color: CupertinoColors.white),
            ),
            backgroundColor: CupertinoColors.systemIndigo,
          ),
          SliverFillRemaining(
            child: CupertinoListSection.insetGrouped(
              children: listOfDogs
                  .map(
                    (dog) => CupertinoListTile(
                      title: Text(dog.name!),
                      trailing: CupertinoButton(
                        padding: EdgeInsets.zero,
                        child: const Icon(
                          CupertinoIcons.ellipsis,
                          color: CupertinoColors.systemGrey,
                        ),
                        onPressed: () {
                          _showActionSheet(context, dog.id!);
                        },
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}
