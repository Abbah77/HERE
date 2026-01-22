package com.yourname.here

import androidx.compose.animation.*
import androidx.compose.animation.core.*
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Chat
import androidx.compose.material.icons.filled.Person
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.model.CameraPosition
import com.google.android.gms.maps.model.LatLng
import com.google.maps.android.compose.*
import kotlinx.coroutines.delay

@Composable
fun MapScreen(
    onChatClick: () -> Unit,
    onProfileClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    // State management
    var mapLoaded by remember { mutableStateOf(false) }
    var showFallback by remember { mutableStateOf(false) }
    
    // Default location (Singapore)
    val defaultLocation = LatLng(1.3521, 103.8198)
    
    // Camera state with default position
    val cameraPositionState = rememberCameraPositionState {
        position = CameraPosition.fromLatLngZoom(defaultLocation, 10f)
    }
    
    // Simulate map loading (replace with actual map loading logic)
    LaunchedEffect(Unit) {
        // Initial delay to show transition effect
        delay(300)
        
        // In production, this would be replaced by actual map loading callback
        // For now, simulate a map load after 1.5s
        delay(1500)
        
        if (mapLoaded) {
            showFallback = false
        } else {
            // If map hasn't loaded, show fallback
            showFallback = true
        }
    }
    
    Box(
        modifier = modifier.fillMaxSize()
    ) {
        // ========== MAP CONTAINER ==========
        AnimatedVisibility(
            visible = !showFallback,
            enter = fadeIn(animationSpec = tween(800)),
            exit = fadeOut(animationSpec = tween(300))
        ) {
            Box(modifier = Modifier.fillMaxSize()) {
                GoogleMap(
                    modifier = Modifier.fillMaxSize(),
                    cameraPositionState = cameraPositionState,
                    properties = MapProperties(
                        mapType = MapType.NORMAL,
                        isMyLocationEnabled = true, // Request location permission separately
                        isIndoorEnabled = true,
                        isTrafficEnabled = false,
                        isBuildingsEnabled = true
                    ),
                    uiSettings = MapUiSettings(
                        zoomControlsEnabled = true,
                        compassEnabled = true,
                        myLocationButtonEnabled = true,
                        zoomGesturesEnabled = true,
                        scrollGesturesEnabled = true,
                        rotationGesturesEnabled = true,
                        tiltGesturesEnabled = true,
                        mapToolbarEnabled = false // Custom toolbar not needed
                    ),
                    onMapLoaded = {
                        mapLoaded = true
                        showFallback = false
                    },
                    onMapClick = { latLng ->
                        // Future: Handle map clicks for AI content
                    }
                )
                
                // ========== PLACEHOLDER MARKERS ==========
                // Future: Replace with dynamic AI content markers
                MapMarker(
                    position = defaultLocation,
                    title = "Sample Location",
                    snippet = "Future AI content will appear here"
                )
                
                // Additional sample markers
                MapMarker(
                    position = LatLng(1.2903, 103.8515), // Marina Bay
                    title = "Marina Bay",
                    snippet = "Popular destination"
                )
            }
        }
        
        // ========== OFFLINE FALLBACK ==========
        AnimatedVisibility(
            visible = showFallback,
            enter = fadeIn() + scaleIn(initialScale = 0.9f),
            exit = fadeOut()
        ) {
            OfflineFallbackView(
                onRetry = {
                    // Retry logic would go here
                    showFallback = false
                    mapLoaded = false
                }
            )
        }
        
        // ========== BRANDING OVERLAY ==========
        // Always visible (even during fallback)
        BrandingOverlay()
        
        // ========== FLOATING NAVIGATION BUTTONS ==========
        // Always visible (even during fallback)
        FloatingActionButtons(
            onChatClick = onChatClick,
            onProfileClick = onProfileClick,
            modifier = Modifier
                .align(Alignment.BottomEnd)
                .padding(16.dp)
        )
    }
}

@Composable
fun OfflineFallbackView(
    onRetry: () -> Unit
) {
    Column(
        modifier = Modifier
            .fillMaxSize()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        Color(0xFF1E88E5), // Brand primary
                        Color(0xFF0D47A1)   // Brand secondary
                    )
                )
            )
            .padding(32.dp),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.Center
    ) {
        // Optional: Add Lottie animation here
        // LottieAnimation(...)
        
        // Simple icon placeholder
        Text(
            text = "🗺️",
            style = MaterialTheme.typography.displayLarge
        )
        
        Spacer(modifier = Modifier.height(32.dp))
        
        Text(
            text = "Loading map...",
            style = MaterialTheme.typography.headlineMedium,
            color = Color.White
        )
        
        Spacer(modifier = Modifier.height(16.dp))
        
        Text(
            text = "Please check your connection or try again",
            style = MaterialTheme.typography.bodyMedium,
            color = Color.White.copy(alpha = 0.8f)
        )
        
        Spacer(modifier = Modifier.height(32.dp))
        
        // Retry button
        FilledTonalButton(
            onClick = onRetry,
            colors = ButtonDefaults.filledTonalButtonColors(
                containerColor = Color.White,
                contentColor = Color(0xFF1E88E5)
            )
        ) {
            Text("Try Again")
        }
        
        Spacer(modifier = Modifier.height(16.dp))
        
        // Micro-copy for reassurance
        Text(
            text = "You can still use Chat and Profile features",
            style = MaterialTheme.typography.labelSmall,
            color = Color.White.copy(alpha = 0.6f)
        )
    }
}

@Composable
fun BrandingOverlay() {
    Box(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        contentAlignment = Alignment.TopStart
    ) {
        Surface(
            color = Color.White.copy(alpha = 0.9f),
            shape = MaterialTheme.shapes.small,
            shadowElevation = 1.dp
        ) {
            Text(
                text = "HERE",
                style = MaterialTheme.typography.labelLarge,
                color = Color(0xFF0D47A1),
                modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp)
            )
        }
    }
}

@Composable
fun FloatingActionButtons(
    onChatClick: () -> Unit,
    onProfileClick: () -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier,
        verticalArrangement = Arrangement.spacedBy(12.dp)
    ) {
        // CHAT BUTTON (Primary color)
        FloatingActionButton(
            onClick = onChatClick,
            containerColor = MaterialTheme.colorScheme.primary,
            contentColor = Color.White,
            elevation = FloatingActionButtonDefaults.elevation(
                defaultElevation = 4.dp,
                pressedElevation = 8.dp
            )
        ) {
            Icon(
                Icons.Filled.Chat,
                contentDescription = "Open Chat",
                modifier = Modifier.size(24.dp)
            )
        }
        
        // PROFILE BUTTON (Secondary color)
        FloatingActionButton(
            onClick = onProfileClick,
            containerColor = MaterialTheme.colorScheme.secondary,
            contentColor = Color.White,
            elevation = FloatingActionButtonDefaults.elevation(
                defaultElevation = 4.dp,
                pressedElevation = 8.dp
            )
        ) {
            Icon(
                Icons.Filled.Person,
                contentDescription = "Open Profile",
                modifier = Modifier.size(24.dp)
            )
        }
    }
}

@Composable
fun MapMarker(
    position: LatLng,
    title: String,
    snippet: String
) {
    Marker(
        state = MarkerState(position = position),
        title = title,
        snippet = snippet,
        icon = BitmapDescriptorFactory.defaultMarker(
            BitmapDescriptorFactory.HUE_RED
        )
    )
}