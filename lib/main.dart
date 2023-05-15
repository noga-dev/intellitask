import 'dart:convert';
import 'dart:io';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intellitask/core/consts.dart';
import 'package:intellitask/core/env.dart';
import 'package:intellitask/views/app.dart';
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
    runApp(
      ProviderScope(
        observers: [_ProviderErrorObserver()],
        child: const IntelliTaskApp(),
      ),
    );
  }
}

class _ProviderErrorObserver extends ProviderObserver {
  @override
  void providerDidFail(
    ProviderBase<Object?> provider,
    Object error,
    StackTrace stackTrace,
    ProviderContainer container,
  ) {
    Consts.logger.e(provider, error, stackTrace);
    BotToast.showText(text: error.toString());
  }
}

// workaround for https://github.com/supabase/gotrue/issues/68
Future<void> _init() async {
  WidgetsFlutterBinding.ensureInitialized();

  Paint.enableDithering = true;

  // we want these to run concurrently
  final futureList = await Future.wait([
    // alternatively could use fcm but it's too long
    _getDeviceId(),
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
Future<String> _getDeviceId() async {
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
