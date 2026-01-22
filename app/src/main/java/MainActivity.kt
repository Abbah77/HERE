class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            MaterialTheme {
                Surface {
                    HEREApp() // Use new navigation setup
                }
            }
        }
    }
}

// HEREApp.kt (new file)
@Composable
fun HEREApp() {
    val navController = rememberNavController()
    
    NavHost(navController = navController, startDestination = "splash") {
        composable("splash") {
            SplashScreen(
                onSplashEnd = {
                    navController.navigate("map") {
                        popUpTo("splash") { inclusive = true }
                    }
                }
            )
        }
        composable("map") {
            MapScreen(
                onChatClick = { navController.navigate("chat") },
                onProfileClick = { navController.navigate("profile") }
            )
        }
        composable("chat") {
            ChatScreen(onBack = { navController.popBackStack() })
        }
        composable("profile") {
            ProfileScreen(onBack = { navController.popBackStack() })
        }
    }
}