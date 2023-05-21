import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(
    varName: 'ANON_EMAIL_KEY',
    obfuscate: true,
  )
  static final anonEmailSuffix = _Env.anonEmailSuffix;
}
