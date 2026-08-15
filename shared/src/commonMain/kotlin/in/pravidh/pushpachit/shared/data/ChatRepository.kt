package in.pravidh.pushpachit.shared.data

import kotlinx.serialization.Serializable

@Serializable
data class ChatMessage(
    val id: String,
    val senderName: String,
    val body: String,
    val attachmentPath: String? = null,
    val createdAt: String,
)

interface ChatRepository {
    suspend fun messages(limit: Int = 50): Result<List<ChatMessage>>
    suspend fun sendMessage(body: String, attachmentPath: String? = null): Result<Unit>
}

class DemoChatRepository : ChatRepository {
    override suspend fun messages(limit: Int): Result<List<ChatMessage>> = Result.success(
        listOf(
            ChatMessage("1", "Agent", "Welcome to Pushpa Family Chit 👋", createdAt = "demo"),
            ChatMessage("2", "Member 01", "Month 1 payment submitted.", createdAt = "demo"),
        ),
    )

    override suspend fun sendMessage(body: String, attachmentPath: String?): Result<Unit> =
        if (body.isBlank() && attachmentPath == null) Result.failure(IllegalArgumentException("Message or attachment required"))
        else Result.success(Unit)
}
