import io.ktor.http.*
import io.ktor.server.application.*
import io.ktor.server.engine.*
import io.ktor.server.netty.*
import io.ktor.server.response.*
import io.ktor.server.routing.*
import java.util.UUID
import java.util.concurrent.ConcurrentHashMap

fun main() {
    // Thread-safe map taaki multiple users ek saath naye API keys generate kar sakein
    val validApiKeys = ConcurrentHashMap<String, String>().apply {
        put("sk-demo-99999", "Guest User")
    }

    // Questions aur Answers ka Database
    val qaDatabase = mapOf(
        "kotlin kya hai" to "Kotlin ek modern programming language hai jo Android aur Backend ke liye use hoti hai.",
        "backend kya hai" to "Backend kisi app ya website ka dimaag aur data system hota hai.",
        "tumhara naam kya hai" to "Main aapka Cloud AI Backend hoon!"
    )

    val port = System.getenv("PORT")?.toIntOrNull() ?: 8080

    embeddedServer(Netty, port = port) {
        routing {
            // 1. Home Route
            get("/") {
                call.respondText("Mera Kotlin AI API Server Live Hai! Nayi key ke liye /generate-key?name=ApnaNaam call karein.")
            }

            // 2. Nayi Unique API Key Generate karne ka Endpoint
            get("/generate-key") {
                val userName = call.request.queryParameters["name"]?.trim()

                if (userName.isNullOrEmpty()) {
                    call.respondText(
                        text = """{"error": "Kripya 'name' parameter mein apna naam bhejein. Example: /generate-key?name=Rahul"}""",
                        contentType = ContentType.Application.Json,
                        status = HttpStatusCode.BadRequest
                    )
                    return@get
                }

                // Unique API Key banana (e.g., sk-a1b2c3d4e5f6...)
                val randomCode = UUID.randomUUID().toString().replace("-", "").take(16)
                val newApiKey = "sk-$randomCode"

                // Key ko memory mein save karna
                validApiKeys[newApiKey] = userName

                val jsonResponse = """
                    {
                        "message": "Nayi API Key safaltapoorvak ban gayi hai!",
                        "user": "${userName.replace("\"", "")}",
                        "api_key": "$newApiKey"
                    }
                """.trimIndent()

                call.respondText(jsonResponse, ContentType.Application.Json)
            }

            // 3. Question Puchhne ka Main API Endpoint
            get("/ask") {
                val apiKey = call.request.queryParameters["key"]?.trim()
                val userQuestion = call.request.queryParameters["q"]?.lowercase()?.trim()

                if (apiKey.isNullOrEmpty() || !validApiKeys.containsKey(apiKey)) {
                    call.respondText(
                        text = """{"error": "Invalid ya Missing API Key! Pehle /generate-key se apni key banayein."}""",
                        contentType = ContentType.Application.Json,
                        status = HttpStatusCode.Unauthorized
                    )
                    return@get
                }

                val userName = validApiKeys[apiKey] ?: "User"

                if (userQuestion.isNullOrEmpty()) {
                    call.respondText(
                        text = """{"error": "Kripya 'q' parameter mein apna sawal bhejein."}""",
                        contentType = ContentType.Application.Json,
                        status = HttpStatusCode.BadRequest
                    )
                    return@get
                }

                val answer = qaDatabase[userQuestion] ?: "Maaf kijiye $userName, mujhe is sawal ka jawab nahi pata."

                val jsonResponse = """
                    {
                        "user": "${userName.replace("\"", "")}",
                        "question": "${userQuestion.replace("\"", "")}",
                        "answer": "${answer.replace("\"", "")}"
                    }
                """.trimIndent()

                call.respondText(jsonResponse, ContentType.Application.Json)
            }
        }
    }.start(wait = true)
}
