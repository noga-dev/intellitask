import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intellitask/core/consts.dart';
import 'package:intellitask/core/env.dart';
import 'package:intellitask/models/task.dto.dart';
import 'package:intellitask/providers/task.pod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  {
    // ignore: missing_provider_scope
    runApp(
      const Material(
        color: Colors.black,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Center(
            child: CircularProgressIndicator.adaptive(),
          ),
        ),
      ),
    );
  }
  {
    await _init();
  }
  {
    runApp(const ProviderScope(child: IntelliTaskApp()));
  }
}

// workaround for https://github.com/supabase/gotrue/issues/68
Future<void> _init() async {
  // we want these to run concurrently
  final futureList = await Future.wait([
    // alternatively could use fcm but it's too long
    getDeviceId(),
    Supabase.initialize(
      url: Consts.supabaseUrl,
      anonKey: Consts.supabaseAnonKey,
    ),
  ]);

  final deviceId = futureList[0].toString().trim().replaceAll('-', '');
  final email = '$deviceId${Env.anonEmailSuffix}';
  final password = deviceId;

  if (Supabase.instance.client.auth.currentSession != null) {
    return;
  }

  try {
    await Supabase.instance.client.auth.signUp(
      email: email,
      password: password,
    );
  } on AuthException catch (e, s) {
    Consts.logger.e('', e, s);
    // TODO(agon): this will need to be taken out from here and tested
    // with a unit test in case server/sdk ever changes these details
    if (e.statusCode != '400' && e.message != 'User already registered') {
      rethrow;
    }
    try {
      await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (_) {
      rethrow;
    }
  } catch (e, s) {
    Consts.logger.e('', e, s);
  }
}

// https://github.com/BestBurning/platform_device_id/issues/21#issuecomment-1133934641
Future<String> getDeviceId() async {
  String biosID = '';

  final process = await Process.start(
    'wmic',
    ['csproduct', 'get', 'uuid'],
    mode: ProcessStartMode.detachedWithStdio,
  );

  final result = await process.stdout.transform(utf8.decoder).toList();

  for (final element in result) {
    final item = element.replaceAll(RegExp('\r|\n|\\s|UUID|uuid'), '');
    if (item.isNotEmpty) {
      biosID = item;
    }
  }

  return biosID;
}

class IntelliTaskApp extends ConsumerWidget {
  const IntelliTaskApp({super.key});

  @override
  Widget build(BuildContext context, ref) {
    final taskListPod = ref.watch(taskListNotifierProvider);

    return MaterialApp(
      title: Consts.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(useMaterial3: true),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: PointerDeviceKind.values.toSet(),
      ),
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
              child: AnimatedList(
                key: GlobalKey<AnimatedListState>(),
                initialItemCount: taskListPod.valueOrNull?.length ?? 0,
                itemBuilder: (context, index, animation) => taskListPod.when(
                  loading: () => const Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                  error: (error, stack) => const SizedBox(),
                  data: (taskList) => taskList.reversed
                      .map(
                        (e) => Dismissible(
                          key: ValueKey(e.id),
                          onDismissed: (direction) {},
                          confirmDismiss: (direction) => Future.value(false),
                          background: const Align(
                            alignment: Alignment(-.9, 0),
                            child: Text(
                              'delete',
                            ),
                          ),
                          secondaryBackground: const Align(
                            alignment: Alignment(0.9, 0),
                            child: Text(
                              'complete',
                              textAlign: TextAlign.right,
                            ),
                          ),
                          child: Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(e.data),
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList()[index],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HookBuilder(builder: (context) {
                final textController = useTextEditingController();
                final onSubmit = useCallback(
                  () async {
                    final scaffoldMessengerOfContext =
                        ScaffoldMessenger.of(context);

                    final result = await ref
                        .read(taskListNotifierProvider.notifier)
                        .addTask(
                          TaskDto(
                            id: Random().nextInt(9999).toString(),
                            data: textController.text,
                            priority: Random().nextInt(9999),
                            isComplete: Random().nextBool(),
                            createdAt: DateTime.now(),
                          ),
                        );
                    if (result) {
                      textController.clear();
                    } else {
                      scaffoldMessengerOfContext.showSnackBar(
                        const SnackBar(
                          content: Text('Error adding task'),
                        ),
                      );
                    }
                  },
                  [textController.text],
                );

                return TextField(
                  controller: textController,
                  onSubmitted: (value) => onSubmit(),
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: IconButton(
                        onPressed: () => onSubmit(),
                        icon: const Icon(Icons.add),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
