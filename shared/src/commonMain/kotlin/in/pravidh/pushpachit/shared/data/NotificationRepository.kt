package in.pravidh.pushpachit.shared.data

import kotlinx.serialization.Serializable

@Serializable
enum class NotificationType {
    PAYMENT_DUE,
    PAYMENT_OVERDUE,
    PAYMENT_VERIFIED,
    WINNER_ANNOUNCED,
    WINNER_COLLECTION_PENDING,
    AGENT_GUARANTEE_USED,
    CHAT_MESSAGE,
}

@Serializable
data class AppNotification(
    val id: String,
    val type: NotificationType,
    val title: String,
    val body: String,
    val deepLink: String? = null,
)

interface NotificationRepository {
    suspend fun notifications(): Result<List<AppNotification>>
    suspend fun registerPushToken(token: String): Result<Unit>
}

class DemoNotificationRepository : NotificationRepository {
    override suspend fun notifications(): Result<List<AppNotification>> = Result.success(emptyList())

    override suspend fun registerPushToken(token: String): Result<Unit> =
        if (token.isBlank()) Result.failure(IllegalArgumentException("Push token required")) else Result.success(Unit)
}
