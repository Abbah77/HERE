package com.yourname.here

import androidx.compose.foundation.layout.*
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@Composable
fun AppNav() {
    // Current screen state
    var currentScreen by remember { mutableStateOf("splash") }

    when (currentScreen) {
        "splash" -> SplashScreen(onContinue = { currentScreen = "map" })
        "map" -> MapScreen(
            onChatClick = { currentScreen = "chat" },
            onProfileClick = { currentScreen = "profile" }
        )
        "chat" -> ChatScreen(onBack = { currentScreen = "map" })
        "profile" -> ProfileScreen(onBack = { currentScreen = "map" })
    }
}
