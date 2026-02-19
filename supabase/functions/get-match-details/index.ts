// supabase/functions/get-match-details/index.ts
// Used by: MatchDetailsScreen (Details, Events, Lineups, Streams)

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const corsHeaders = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
};

serve(async (req) => {
    if (req.method === "OPTIONS") {
        return new Response("ok", { headers: corsHeaders });
    }

    try {
        const supabase = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_ANON_KEY") ?? "",
            { global: { headers: { Authorization: req.headers.get("Authorization")! } } }
        );

        const { match_id } = await req.json();

        if (!match_id) {
            return new Response(JSON.stringify({ error: "match_id is required" }), {
                status: 400,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Parallel queries
        const [matchRes, eventsRes, lineupsRes, streamsRes] = await Promise.all([
            // Match with team details
            supabase
                .from("matches")
                .select("*, home_team:teams!home_team_id(*), away_team:teams!away_team_id(*), leagues(name)")
                .eq("id", match_id)
                .single(),

            // Events
            supabase
                .from("match_events")
                .select("*, teams(name)")
                .eq("match_id", match_id)
                .order("minute", { ascending: true }),

            // Lineups
            supabase
                .from("match_lineups")
                .select("*, teams(name)")
                .eq("match_id", match_id)
                .order("position"),

            // Streams (sorted by priority)
            supabase
                .from("streaming_servers")
                .select("*")
                .eq("match_id", match_id)
                .order("priority", { ascending: true }),
        ]);

        return new Response(
            JSON.stringify({
                match: matchRes.data,
                events: eventsRes.data ?? [],
                lineups: lineupsRes.data ?? [],
                streams: streamsRes.data ?? [],
            }),
            {
                headers: { ...corsHeaders, "Content-Type": "application/json" },
                status: 200,
            }
        );
    } catch (error) {
        return new Response(JSON.stringify({ error: error.message }), {
            headers: { ...corsHeaders, "Content-Type": "application/json" },
            status: 500,
        });
    }
});
