// supabase/functions/update-live-match/index.ts
// Used by: Admin/Backend to push live match updates
// This triggers Realtime subscriptions for connected clients

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
        // Use SERVICE_ROLE_KEY for write operations
        const supabase = createClient(
            Deno.env.get("SUPABASE_URL") ?? "",
            Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") ?? ""
        );

        const { match_id, home_score, away_score, minute, status, event } = await req.json();

        if (!match_id) {
            return new Response(JSON.stringify({ error: "match_id is required" }), {
                status: 400,
                headers: { ...corsHeaders, "Content-Type": "application/json" },
            });
        }

        // Update match score/minute
        const updateData: Record<string, unknown> = { updated_at: new Date().toISOString() };
        if (home_score !== undefined) updateData.home_score = home_score;
        if (away_score !== undefined) updateData.away_score = away_score;
        if (minute !== undefined) updateData.minute = minute;
        if (status !== undefined) updateData.status = status;

        const { error: matchError } = await supabase
            .from("matches")
            .update(updateData)
            .eq("id", match_id);

        if (matchError) throw matchError;

        // Insert event if provided
        if (event) {
            const { error: eventError } = await supabase.from("match_events").insert({
                match_id,
                minute: event.minute,
                event_type: event.event_type,
                player_name: event.player_name,
                team_id: event.team_id,
                description: event.description ?? "",
            });
            if (eventError) throw eventError;
        }

        return new Response(
            JSON.stringify({ success: true, message: "Match updated" }),
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
