package in.pravidh.pushpachit.shared.data

import io.github.jan.supabase.auth.Auth
import io.github.jan.supabase.createSupabaseClient
import io.github.jan.supabase.functions.Functions
import io.github.jan.supabase.postgrest.Postgrest
import io.github.jan.supabase.realtime.Realtime
import io.github.jan.supabase.storage.Storage

object SupabaseProvider {
    fun create(config: SupabaseConfig) = createSupabaseClient(
        supabaseUrl = config.url,
        supabaseKey = config.publishableKey,
    ) {
        install(Auth)
        install(Postgrest)
        install(Storage)
        install(Realtime)
        install(Functions)
    }
}
