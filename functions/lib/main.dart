import 'dart:convert';
import 'dart:io';

import 'package:edge_http_client/edge_http_client.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_functions/supabase_functions.dart';
import 'package:universal_html/controller.dart';

// edge build supabase_functions --dev
// npx supabase functions deploy dart_edge
// npx supabase functions serve dart_edge --no-verify-jwt --env-file ./.env
// watcher doesn't work on windows... https://github.com/supabase/cli/issues/247
// edge build supabase_functions
// supabase functions deploy dart_edge
void main() {
  // ignore: unused_local_variable
  final openaiApiKey = Deno.env.get('OPENAI_API_KEY');
  // ignore: unused_local_variable
  final supaUrl = Deno.env.get('SUPABASE_URL') ?? '';
  // ignore: unused_local_variable
  final supaDbUrl = Deno.env.get('SUPABASE_DB_URL') ?? '';
  // ignore: unused_local_variable
  final supaAnonKey = Deno.env.get('SUPABASE_ANON_KEY') ?? '';
  // ignore: unused_local_variable
  final supaServiceRoleKey = Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? '';

  final httpClient = EdgeHttpClient();

  final supabaseClient = SupabaseClient(
    supaUrl,
    supaServiceRoleKey,
    httpClient: httpClient,
  );

  SupabaseFunctions(fetch: (request) async {
    final tasks = await supabaseClient
        .from('tasks')
        .select<List<Map<String, dynamic>>>()
        .order(
          'created_at',
          ascending: true,
        )
        .limit(1);

    if (tasks.isEmpty) {
      return Response('No tasks found.');
    }

    if (tasks.first['priority'] == 0) {
      // roles: system, user, assistant
      final controller = WindowController();

      await controller.openHttp(
        uri: Uri.parse('https://api.openai.com/v1/chat/completions'),
        contentType: ContentType.json,
        method: 'POST',
        onRequest: (request) {
          request.headers.set('Authorization', 'Bearer $openaiApiKey');
          request.add(
            utf8.encode(
              {
                'model': 'gpt-3.5-turbo',
                'messages': [
                  {
                    'role': 'system',
                    'content':
                        'You are a task prioritization machine. You will be provided with a task, and you will return an integer between 1 and 32000, where the lower the number the lower the priority and vice versa. If 32000 is life or death, such as a medical emergency, then staring at the wall for no reason is 1.',
                  },
                  {
                    'role': 'user',
                    'content': 'Visit grandma before her surgery tomorrow.',
                  },
                  {
                    'role': 'assistant',
                    'content': '25000',
                  },
                  {
                    'role': 'user',
                    'content': 'Wash The dishes.',
                  },
                  {
                    'role': 'assistant',
                    'content': '5000',
                  },
                  {
                    'role': 'user',
                    'content': tasks.first['data'],
                  },
                ],
              }.toString(),
            ),
          );
        },
        onResponse: (response) {
          print('XXXXXXXX');
          print(response);
          print('XXXXXXXX');
        },
      );

      // final openAiResponseTaskPriority =
      //     jsonDecode(openAiResponse.body)['choices']['message'];
    }

    final response = tasks.toString();

    return Response(response);
  });
}
