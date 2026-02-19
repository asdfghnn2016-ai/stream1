// supabase/functions/get-league-details/index.ts
// Used by: LeagueDetailsScreen (Standings, Scorers, Assists, Matches tabs)

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

        const { league_id } = await req.json();

        if (!league_id) {
            return new Response(JSON.stringify({ error: "league_id is required" }), {
                status: 400,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Parallel queries
        const [standingsRes, scorersRes, assistsRes, matchesRes] = await Promise.all([
            // Standings with team names
            supabase
                .from("standings")
                .select("*, teams(name, short_name, logo_url)")
                .eq("league_id", league_id)
                .order("position", { ascending: true }),

            // Top scorers
            supabase
                .from("player_stats")
                .select("*, teams(name, logo_url)")
                .eq("league_id", league_id)
                .order("goals", { ascending: false })
                .limit(20),

            // Top assists
            supabase
                .from("player_stats")
                .select("*, teams(name, logo_url)")
                .eq("league_id", league_id)
                .order("assists", { ascending: false })
                .limit(20),

            // Recent matches
            supabase
                .from("matches")
                .select("*, home_team:teams!home_team_id(name, logo_url), away_team:teams!away_team_id(name, logo_url)")
                .eq("league_id", league_id)
                .order("start_time", { ascending: false })
                .limit(20),
        ]);

        return new Response(
            JSON.stringify({
                standings: standingsRes.data ?? [],
                top_scorers: scorersRes.data ?? [],
                top_assists: assistsRes.data ?? [],
                recent_matches: matchesRes.data ?? [],
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
