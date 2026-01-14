import Supabase
import Foundation

enum SupabaseConfig {
    static let url = "https://eqxtkhmwoeeotxfvrcgz.supabase.co"
    static let anonKey = "sb_publishable_L9v4cApVmG0sO-x6_yW3OA_zdJPTKWy"
}

final class SupabaseService {

    static let shared = SupabaseService()

    let client: SupabaseClient

    private init() {
        guard let url = URL(string: SupabaseConfig.url) else {
            fatalError("Invalid Supabase URL")
        }

        // ✅ Supabase handles session storage automatically (Keychain)
        client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: SupabaseConfig.anonKey
        )
    }

    // MARK: - Auth helpers

    var isLoggedIn: Bool {
        client.auth.currentSession != nil
    }

    var userId: UUID? {
        client.auth.currentUser?.id
    }

    var userIdString: String? {
        client.auth.currentUser?.id.uuidString
    }

    func signOut() async throws {
        try await client.auth.signOut()
    }
}
