# Optimizer App - Clean Architecture Structure

This Flutter app follows a clean architecture pattern with organized, maintainable code structure.

## 📁 Project Structure

```
lib/
├── core/                    # Global utilities and shared code
│   ├── constants/          # App-wide constants
│   │   ├── app_colors.dart      # Color definitions
│   │   ├── app_dimensions.dart  # Spacing, sizing constants
│   │   ├── app_routes.dart      # Route names
│   │   └── app_strings.dart     # Text strings
│   ├── themes/             # Theme configurations
│   │   └── app_theme.dart       # Light/Dark themes
│   ├── utils/              # Helper functions
│   │   ├── formatters.dart      # Data formatting utilities
│   │   └── validators.dart      # Form validation utilities
│   └── widgets/            # Reusable UI components
│       ├── custom_button.dart   # Custom button widget
│       ├── custom_text_field.dart # Custom text field widget
│       └── splash_screen.dart   # Animated splash screen
│
├── features/               # Feature-based modules
│   └── auth/              # Authentication feature
│       ├── data/          # Data layer (API calls, repositories)
│       ├── models/        # Data models (User, Token, etc.)
│       ├── view/          # UI layer (screens, widgets)
│       │   └── signup_screen.dart
│       └── viewmodel/     # State management (Bloc, Riverpod, Provider)
│
├── services/              # External services
│   ├── api_client.dart    # HTTP client
│   ├── storage_service.dart # Local storage
│   └── notification_service.dart # Push notifications
│
├── app.dart              # MaterialApp configuration
└── main.dart             # App entry point
```

## 🎯 Key Benefits

### **1. Separation of Concerns**
- **Core**: Shared utilities, constants, and widgets
- **Features**: Self-contained modules with their own data, UI, and logic
- **Services**: External dependencies and integrations

### **2. Maintainability**
- Easy to locate and modify specific functionality
- Consistent naming conventions and structure
- Clear dependencies between layers

### **3. Scalability**
- Easy to add new features without affecting existing code
- Modular architecture supports team development
- Clear boundaries between different concerns

### **4. Reusability**
- Core widgets and utilities can be used across features
- Consistent theming and styling throughout the app
- Shared validation and formatting logic

## 🚀 Getting Started

### **Running the App**
```bash
flutter pub get
flutter run
```

### **Adding New Features**
1. Create a new folder under `features/`
2. Add `data/`, `models/`, `view/`, and `viewmodel/` subfolders
3. Implement your feature following the established patterns

### **Using Core Components**
```dart
// Using custom button
CustomButton(
  text: 'Click Me',
  onPressed: () {},
  variant: ButtonVariant.primary,
  size: ButtonSize.large,
)

// Using custom text field
CustomTextField(
  label: 'Email',
  controller: emailController,
  validator: Validators.validateEmail,
  prefixIcon: Icons.email,
)

// Using app constants
Text(
  AppStrings.welcomeMessage,
  style: TextStyle(color: AppColors.primary),
)
```

## 🎨 Theming

The app supports both light and dark themes with consistent styling:

- **Colors**: Defined in `app_colors.dart`
- **Dimensions**: Spacing and sizing in `app_dimensions.dart`
- **Typography**: Text styles in `app_theme.dart`

## 📱 Current Features

- **Splash Screen**: Animated welcome screen with logo and branding
- **Signup Screen**: User registration with form validation
- **Navigation**: Clean routing between screens
- **Validation**: Email and password validation
- **Theming**: Consistent Material Design 3 theming

## 🔧 Architecture Principles

1. **Single Responsibility**: Each class has one clear purpose
2. **Dependency Inversion**: High-level modules don't depend on low-level modules
3. **Open/Closed**: Open for extension, closed for modification
4. **Interface Segregation**: Small, focused interfaces
5. **DRY**: Don't Repeat Yourself - reuse code through core utilities

## 📝 Code Standards

- Use meaningful variable and function names
- Add comprehensive documentation
- Follow Flutter/Dart conventions
- Use constants for magic numbers and strings
- Implement proper error handling
- Write clean, readable code

This structure provides a solid foundation for building scalable, maintainable Flutter applications.
