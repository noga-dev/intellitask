// edge build supabase_functions --dev
// npx supabase functions deploy dart_edge
// npx supabase functions serve dart_edge --no-verify-jwt --env-file ./.env
// watcher doesn't work on windows... https://github.com/supabase/cli/issues/247
// edge build supabase_functions
// supabase functions deploy dart_edge
// project id vobmagvouahifxtwklqo

// Follow this setup guide to integrate the Deno language server with your editor:
// https://deno.land/manual/getting_started/setup_your_environment
// This enables autocomplete, go to definition, etc.

import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import * as postgres from 'https://deno.land/x/postgres@v0.14.2/mod.ts'

const openApiKey = Deno.env.get('OPENAI_API_KEY') ?? '';

console.log("init task prioritizer")
console.log('openApiKey---' + openApiKey.slice(0, 5) + openApiKey.slice(-5));

const pool = new postgres.Pool(Deno.env.get('SUPABASE_DB_URL'), 1, true)

const int2 = 32767;
const int4 = 2147483647;

// supabase functions deploy --no-verify-jwt openai
// supabase secrets set --env-file ./supabase/.env.local

serve(async (_req) => {
  if (openApiKey === '') {
    return new Response("Error: Missing OPENAI_API_KEY", { status: 400 });
  }
  
  try {
    const connection = await pool.connect()

    try {
      const getTasks = await connection.queryObject`SELECT * FROM tasks ORDER BY created_at DESC LIMIT 1`
      
      if (getTasks.rowCount === 0) {
        return new Response("Error: No tasks", { status: 400 });
      }

      const stringifiedTask = JSON.stringify(
        getTasks.rows,
        (_key, value) => (typeof value === 'bigint' ? value.toString() : value),
        2
      )

      const parsedTask = JSON.parse(stringifiedTask)[0];
      console.log('parsedTask-------'+parsedTask['data']);

      // return new Response(parsedTask, { status: 200 });

      const requestBody = JSON.stringify({
        'model': 'gpt-3.5-turbo',
        'messages': [
          {
            'role': 'system',
            'content':
                `You are a task prioritization machine. You will be provided with a task, and you will only return 2 numbers seperated by a single space character. The first number is an integer between 1 and ${int2}, where the lower the number the lower the priority and vice versa. For example, if ${int2} is life or death, such as a medical emergency, then staring at the wall for no reason is 1. The second number is how many minutes from now should the task be performed. For example, if the task should be performed in 15 minutes, then return 15, or if the task should be performed in 1 hour, then return 60. Minutes must be between 1 and ${int4}.`,
          },
          {
            'role': 'user',
            'content': 'Visit grandma before her surgery tomorrow.',
          },
          {
            'role': 'assistant',
            'content': '25000 14400',
          },
          {
            'role': 'user',
            'content': 'wash The dishes',
          },
          {
            'role': 'assistant',
            'content': '1000 600',
          },
          {
            'role': 'user',
            'content': parsedTask['data'],
          },
        ],
      });

      const resp = await fetch("https://api.openai.com/v1/chat/completions", {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
          'Authorization': `Bearer ${openApiKey}`,
        },
        body: requestBody,
      });

      const parsedResp = await resp.json();

      console.log('parsedResp-------' + JSON.stringify(parsedResp));

      const parsedRespContent = parsedResp['choices'][0]['message']['content'];

      console.log('parsedRespContent-------' + parsedRespContent);

      const parsedContent = parsedRespContent.split(' ');

      const parsedPriority = parseInt(parsedContent[0]);

      if (isNaN(parsedPriority) || parsedPriority < 1 || parsedPriority > int2) {
        const updateQuery = await connection.queryObject`UPDATE tasks SET is_valid = false WHERE id = ${parsedTask['id']}`
        console.log('updateQuery-------'+updateQuery);
        return new Response("Error: Invalid priority", { status: 400 });
      }

      const parsedMinutes = parseInt(parsedContent[1]);

      if (isNaN(parsedMinutes) || parsedMinutes < 1 || parsedMinutes > int4) {
        const updateQuery = await connection.queryObject`UPDATE tasks SET is_valid = false WHERE id = ${parsedTask['id']}`
        console.log('updateQuery-------'+updateQuery);
        return new Response("Error: Invalid seconds", { status: 400 });
      }

      const updateQuery = await connection.queryObject`UPDATE tasks SET priority = ${parsedPriority}, due_in = ${parsedMinutes} WHERE id = ${parsedTask['id']}`

      // Return the response with the correct content type header
      return new Response(JSON.stringify(updateQuery), {
        status: 200,
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
        },
      })
    } finally {
      connection.release()
    }
  } catch (err) {
    console.error(err)
    return new Response(String(err?.message ?? err), { status: 500 })
  } finally {
    console.log("init task prioritizer")
  }
})

// To invoke:
// curl -i --location --request POST 'http://localhost:54321/functions/v1/' \
//   --header 'Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0' \
//   --header 'Content-Type: application/json' \
//   --data '{"name":"Functions"}'
