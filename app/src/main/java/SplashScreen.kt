package com.yourname.here

import androidx.compose.animation.core.*
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material3.Text
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.alpha
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import kotlinx.coroutines.delay

@Composable
fun SplashScreen(
    onSplashEnd: () -> Unit,
    splashDurationMs: Int = 2500 // Default duration of 2.5 seconds
) {
    // State for animation
    var animationTrigger by remember { mutableStateOf(false) }

    // Auto-redirect logic
    LaunchedEffect(Unit) {
        delay(splashDurationMs.toLong())
        onSplashEnd()
    }

    // Trigger fade-in animation after a brief delay
    LaunchedEffect(Unit) {
        delay(300) // Small delay before animation starts
        animationTrigger = true
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFF1E88E5), // Brand color
                        Color(0xFF0D47A1)  // Darker shade
                    )
                )
            ),
        contentAlignment = Alignment.Center
    ) {
        SplashContent(animationTrigger)
    }
}

@Composable
private fun SplashContent(animationTrigger: Boolean) {
    Column(
        horizontalAlignment = Alignment.CenterHorizontally,
        modifier = Modifier.padding(horizontal = 32.dp)
    ) {
        // Logo with fade-in and scale animation
        val alpha by animateFloatAsState(
            targetValue = if (animationTrigger) 1f else 0f,
            animationSpec = tween(durationMillis = 800)
        )

        val scale by animateFloatAsState(
            targetValue = if (animationTrigger) 1f else 0.8f,
            animationSpec = spring(
                dampingRatio = Spring.DampingRatioLowBouncy,
                stiffness = Spring.StiffnessLow
            )
        )

        // Logo - replace R.drawable.logo with your actual resource
        Image(
            painter = painterResource(id = R.drawable.logo), // TODO: Add your logo asset
            contentDescription = "HERE App Logo",
            modifier = Modifier
                .size(150.dp)
                .alpha(alpha)
                .scale(scale)
        )

        Spacer(modifier = Modifier.height(24.dp))

        // App name with fade-in animation
        Text(
            text = "HERE",
            fontSize = 36.sp,
            fontWeight = FontWeight.Bold,
            color = Color.White,
            modifier = Modifier.alpha(alpha)
        )

        Spacer(modifier = Modifier.height(16.dp))

        // Optional loading micro-copy with fade-in
        Text(
            text = "Loading your world...",
            fontSize = 14.sp,
            color = Color.White.copy(alpha = 0.8f),
            modifier = Modifier.alpha(alpha)
        )

        Spacer(modifier = Modifier.height(32.dp))

        // Optional subtle loading indicator
        LoadingIndicator(isVisible = animationTrigger)
    }
}

@Composable
fun LoadingIndicator(isVisible: Boolean) {
    // Pulsing dot animation
    val infiniteTransition = rememberInfiniteTransition()
    val pulseAlpha by infiniteTransition.animateFloat(
        initialValue = 0.3f,
        targetValue = 1f,
        animationSpec = infiniteRepeatable(
            animation = tween(1000, easing = LinearEasing),
            repeatMode = RepeatMode.Reverse
        )
    )

    if (isVisible) {
        Box(
            modifier = Modifier
                .size(8.dp)
                .alpha(pulseAlpha)
                .background(Color.White, shape = androidx.compose.foundation.shape.CircleShape)
        )
    }
}
