import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': {
      // Navigation
      'nav_discover': 'Discover',
      'nav_cart': 'Cart',
      'nav_saved': 'Saved',
      'nav_account': 'Account',

      // Settings
      'settings_title': 'Settings',
      'settings_general': 'General',
      'settings_preferences': 'Preferences',
      'settings_edit_profile': 'Edit Profile',
      'settings_change_password': 'Change Password',
      'settings_notifications': 'Notifications',
      'settings_security': 'Security',
      'settings_language': 'Language',
      'settings_theme': 'Appearance',
      'settings_dark_mode': 'Dark Mode',
      'settings_privacy': 'Privacy Policy',
      'settings_help': 'Help & Support',
      'settings_logout': 'Logout',
      'theme_light': 'Light',
      'theme_dark': 'Dark',
      'lang_en': 'English',
      'lang_ar': 'العربية (Arabic)',

      // Common actions
      'save': 'Save',
      'cancel': 'Cancel',
      'ok': 'OK',
      'delete': 'Delete',
      'close': 'Close',
      'search': 'Search products, brands...',
      'search_title': 'Search',
      'all': 'All',
      'new': 'New',
      'popular': 'Popular',
      'top_rated': 'Top Rated',
      'off': 'OFF',
      'featured': 'Featured Products',
      'categories': 'Categories',
      'suggested_categories': 'Suggested Categories',
      'browse_by_category': 'Browse by Category',
      'search_in_category': 'Search in category',
      'no_products_found': 'No matching products found',
      'no_products_in_cat': 'No products found in this category',
      'explore_categories_hint': 'Tap any category below to discover its products',
      'items_count': 'items',
      'matching_categories': 'Matching Categories',
      'matching_products': 'Matching Products',

      // Auth
      'login_title': 'Welcome back',
      'login_sub': 'Sign in to continue shopping your favorite items.',
      'email': 'Email',
      'email_hint': 'you@example.com',
      'password': 'Password',
      'password_hint': 'Enter your password',
      'forgot_password': 'Forgot Password?',
      'sign_in': 'Sign In',
      'dont_have_account': "Don't have an account?",
      'create_account': 'Create Account',
      'or_continue_with': 'OR CONTINUE WITH',
      'continue_google': 'Continue with Google',
      'continue_facebook': 'Continue with Facebook',
      'join_verve': 'Join Verve Store',
      'register_sub': 'Create your account to track orders and save favorites.',
      'username': 'Username',
      'username_hint': 'Your full name',
      'password_min_hint': 'At least 6 characters',
      'already_have_account': 'Already have an account?',
      'reset_password_title': 'Reset Password',
      'reset_password_sub': 'Enter your registered email',
      'send_link': 'Send Link',
      'reset_link_sent': 'Password reset link sent to your email',

      // Product Details
      'select_size': 'Select Size',
      'description': 'Description',
      'price': 'Price',
      'add_to_cart': 'Add to Cart',
      'item_added_to_cart': 'Product added to cart!',
      'default_product_desc': 'Crafted for daily comfort, clean styling, and lasting durability.',

      // Home & Discover
      'welcome_user': 'Welcome',
      'shopper': 'Shopper',
      'exclusive_catalog': 'Exclusive selections & live catalog',
      'trending_products': 'Trending Products',
      'refresh': 'Refresh',
      'view_all': 'View All',

      // Favorites
      'favorites_title': 'My Favorites',
      'favorites_empty': 'No favorite products yet',
      'favorites_empty_sub': 'Tap the heart icon on any product to save it here!',

      // Cart & Checkout
      'cart_title': 'My Cart',
      'cart_empty': 'Your cart is empty',
      'cart_empty_sub': 'Explore our catalog and find something you love!',
      'start_shopping': 'Start Shopping',
      'subtotal': 'Subtotal',
      'shipping': 'Shipping',
      'free': 'FREE',
      'total': 'Total',
      'checkout': 'Proceed to Checkout',
      'order_summary': 'Order Summary',
      'payment_methods': 'Payment Methods',
      'shipping_address': 'Shipping Address',
      'place_order': 'Place Order',
      'order_success': 'Order Placed Successfully!',
      'order_success_sub': 'Thank you! Your order has been placed and is being prepared.',
      'size_label': 'Size',
      'qty': 'Qty',
      'order_items': 'Order Items',
      'total_amount': 'Total Amount',
      'confirm_order_cod': 'Confirm Order (Cash on Delivery)',
      'cod_title': 'Cash on Delivery',
      'cod_sub': 'Pay in cash when your order arrives at your doorstep.',
      'credit_card_title': 'Credit / Debit Card',
      'add_payment_card': 'Add Payment Card',
      'add_shipping_address': 'Add Shipping Address',
      'edit': 'Edit',
      'retry': 'Retry',
      'order_placed_title': 'Order Placed!',
      'order_placed_sub': 'Your order has been confirmed and saved to your account.',
      'back_to_home': 'Back to Home',

      // Account & Profile
      'my_orders': 'My Orders',
      'addresses': 'Shipping Addresses',
      'cards': 'Payment Cards',
      'edit_username': 'Edit Username',
      'edit_email': 'Edit Email',
      'password_too_short': 'Password must be at least 6 characters',
      'passwords_dont_match': 'Passwords do not match',
      'profile_updated': 'Profile updated successfully',
      'change_photo': 'Change Profile Picture',
      'account_details': 'Account Details',
      'shortcuts': 'Shortcuts',
      'order_history_sub': 'View placed orders & delivery status',
      'payment_methods_sub': 'Manage saved cards & default payment',
      'saved_addresses_sub': 'Manage delivery locations',
      'tap_photo_to_add': 'Tap photo to add profile picture',
      'no_orders_yet': 'No orders placed yet.',
      'sign_in_provider': 'Sign-in Provider',
    },
    'ar': {
      // Navigation
      'nav_discover': 'استكشاف',
      'nav_cart': 'السلة',
      'nav_saved': 'المفضلة',
      'nav_account': 'حسابي',

      // Settings
      'settings_title': 'الإعدادات',
      'settings_general': 'عام',
      'settings_preferences': 'التفضيلات',
      'settings_edit_profile': 'تعديل الملف الشخصي',
      'settings_change_password': 'تغيير كلمة المرور',
      'settings_notifications': 'الإشعارات',
      'settings_security': 'الأمان والحساب',
      'settings_language': 'اللغة',
      'settings_theme': 'المظهر',
      'settings_dark_mode': 'الوضع الليلي (Dark Mode)',
      'settings_privacy': 'سياسة الخصوصية',
      'settings_help': 'المساعدة والدعم',
      'settings_logout': 'تسجيل الخروج',
      'theme_light': 'فاتح',
      'theme_dark': 'داكن',
      'lang_en': 'English (الإنجليزية)',
      'lang_ar': 'العربية',

      // Common actions
      'save': 'حفظ',
      'cancel': 'إلغاء',
      'ok': 'موافق',
      'delete': 'حذف',
      'close': 'إغلاق',
      'search': 'ابحث عن منتجات، ماركات...',
      'search_title': 'بحث',
      'all': 'الكل',
      'new': 'جديد',
      'popular': 'الأكثر شعبية',
      'top_rated': 'الأعلى تقييماً',
      'off': 'خصم',
      'featured': 'المنتجات المميزة',
      'categories': 'الفئات',
      'suggested_categories': 'الفئات المقترحة',
      'browse_by_category': 'تصفح حسب الفئات',
      'search_in_category': 'البحث في فئة',
      'no_products_found': 'لم يتم العثور على أي منتج مطابق',
      'no_products_in_cat': 'لا توجد منتجات في هذه الفئة حالياً',
      'explore_categories_hint': 'اضغط على أي فئة لاستعراض منتجاتها مباشرة',
      'items_count': 'منتجات',
      'matching_categories': 'فئات مطابقة',
      'matching_products': 'منتجات مطابقة',

      // Auth
      'login_title': 'مرحباً بعودتك',
      'login_sub': 'سجّل الدخول لمتابعة تسوق منتجاتك المفضلة.',
      'email': 'البريد الإلكتروني',
      'email_hint': 'example@email.com',
      'password': 'كلمة المرور',
      'password_hint': 'أدخل كلمة المرور',
      'forgot_password': 'نسيت كلمة المرور؟',
      'sign_in': 'تسجيل الدخول',
      'dont_have_account': 'ليس لديك حساب؟',
      'create_account': 'إنشاء حساب جديد',
      'or_continue_with': 'أو المتابعة باستخدام',
      'continue_google': 'المتابعة باستخدام Google',
      'continue_facebook': 'المتابعة باستخدام Facebook',
      'join_verve': 'انضم إلى متجر Verve',
      'register_sub': 'أنشئ حسابك لمتابعة طلباتك وحفظ منتجاتك المفضلة.',
      'username': 'اسم المستخدم',
      'username_hint': 'اسمك الكامل',
      'password_min_hint': '6 أحرف على الأقل',
      'already_have_account': 'لديك حساب بالفعل؟',
      'reset_password_title': 'إعادة تعيين كلمة المرور',
      'reset_password_sub': 'أدخل بريدك الإلكتروني المسجل',
      'send_link': 'إرسال الرابط',
      'reset_link_sent': 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك الإلكتروني',

      // Product Details
      'select_size': 'اختر المقاس',
      'description': 'الوصف والمواصفات',
      'price': 'السعر',
      'add_to_cart': 'إضافة إلى السلة',
      'item_added_to_cart': 'تمت إضافة المنتج إلى السلة بنجاح!',
      'default_product_desc': 'مصمم لراحة يومية، وأناقة عصرية، وجودة تدوم طويلاً.',

      // Home & Discover
      'welcome_user': 'مرحباً',
      'shopper': 'متسوق',
      'exclusive_catalog': 'مختارات حصرية وكتالوج مباشر',
      'trending_products': 'المنتجات الرائجة',
      'refresh': 'تحديث',
      'view_all': 'عرض الكل',

      // Favorites
      'favorites_title': 'المفضلة',
      'favorites_empty': 'قائمة المفضلة فارغة حالياً',
      'favorites_empty_sub': 'اضغط على رمز القلب في أي منتج لحفظه هنا!',

      // Cart & Checkout
      'cart_title': 'سلة المشتريات',
      'cart_empty': 'سلة التسوق فارغة',
      'cart_empty_sub': 'استكشف منتجاتنا وأضف ما يعجبك إلى سلتك!',
      'start_shopping': 'ابدأ التسوق',
      'subtotal': 'المجموع الفرعي',
      'shipping': 'الشحن',
      'free': 'مجاني',
      'total': 'الإجمالي',
      'checkout': 'متابعة الشراء',
      'order_summary': 'ملخص الطلب',
      'payment_methods': 'طرق الدفع',
      'shipping_address': 'عنوان التوصيل',
      'place_order': 'تأكيد الطلب الآن',
      'order_success': 'تم تقديم الطلب بنجاح!',
      'order_success_sub': 'شكراً لك! تم استلام طلبك وجاري تجهيزه.',
      'size_label': 'المقاس',
      'qty': 'الكمية',
      'order_items': 'منتجات الطلب',
      'total_amount': 'المبلغ الإجمالي',
      'confirm_order_cod': 'تأكيد الطلب (الدفع عند الاستلام)',
      'cod_title': 'الدفع عند الاستلام',
      'cod_sub': 'الدفع نقداً عند استلام طلبك عند باب منزلك.',
      'credit_card_title': 'بطاقة ائتمان / مدى',
      'add_payment_card': 'إضافة بطاقة دفع',
      'add_shipping_address': 'إضافة عنوان شحن',
      'edit': 'تعديل',
      'retry': 'إعادة المحاولة',
      'order_placed_title': 'تم تقديم الطلب!',
      'order_placed_sub': 'تم تأكيد طلبك وحفظه في حسابك بنجاح.',
      'back_to_home': 'العودة للرئيسية',

      // Account & Profile
      'my_orders': 'طلباتي',
      'addresses': 'عناوين الشحن والتوصيل',
      'cards': 'بطاقات الدفع المحفوظة',
      'edit_username': 'تعديل اسم المستخدم',
      'edit_email': 'تعديل البريد الإلكتروني',
      'password_too_short': 'يجب أن لا تقل كلمة المرور عن 6 أحرف',
      'passwords_dont_match': 'كلمتا المرور غير متطابقتين',
      'profile_updated': 'تم تحديث الملف الشخصي بنجاح',
      'change_photo': 'تغيير صورة الحساب',
      'account_details': 'تفاصيل الحساب',
      'shortcuts': 'اختصارات سريعة',
      'order_history_sub': 'عرض الطلبات السابقة وحالة الشحن',
      'payment_methods_sub': 'إدارة البطاقات ووسيلة الدفع الافتراضية',
      'saved_addresses_sub': 'إدارة مواقع التوصيل',
      'tap_photo_to_add': 'اضغط لإضافة صورة شخصية',
      'no_orders_yet': 'لا توجد طلبات سابقة حتى الآن',
      'sign_in_provider': 'طريقة تسجيل الدخول',
    },
  };

  String translate(String key) {
    final languageCode = locale.languageCode;
    return _localizedValues[languageCode]?[key] ??
        _localizedValues['en']?[key] ??
        key;
  }

  String translateError(String rawError) {
    if (locale.languageCode != 'ar') {
      return _cleanErrorMessage(rawError);
    }

    final lower = rawError.toLowerCase();

    // Firebase Auth errors
    if (lower.contains('invalid-credential') ||
        lower.contains('invalid credential')) {
      return 'البريد الإلكتروني أو كلمة المرور غير صحيحة';
    }
    if (lower.contains('user-not-found') || lower.contains('user not found')) {
      return 'لم يتم العثور على حساب مسجل بهذا البريد الإلكتروني';
    }
    if (lower.contains('wrong-password') || lower.contains('wrong password')) {
      return 'كلمة المرور غير صحيحة';
    }
    if (lower.contains('email-already-in-use') ||
        lower.contains('already in use')) {
      return 'البريد الإلكتروني مستخدم بالفعل في حساب آخر';
    }
    if (lower.contains('invalid-email') || lower.contains('invalid email')) {
      return 'صيغة البريد الإلكتروني غير صالحة';
    }
    if (lower.contains('weak-password') || lower.contains('weak password')) {
      return 'كلمة المرور ضعيفة، يجب أن تحتوي على 6 أحرف على الأقل';
    }
    if (lower.contains('network-request-failed') ||
        lower.contains('network_error') ||
        lower.contains('failed host lookup') ||
        lower.contains('socketexception')) {
      return 'تعذر الاتصال بالشبكة، يرجى التحقق من اتصال الإنترنت';
    }
    if (lower.contains('too-many-requests') ||
        lower.contains('too many requests')) {
      return 'تم حظر الطلبات مؤقتاً لكثرة المحاولات، يرجى المحاولة لاحقاً';
    }
    if (lower.contains('user-disabled')) {
      return 'تم تعطيل هذا الحساب من قِبل الإدارة';
    }
    if (lower.contains('operation-not-allowed')) {
      return 'طريقة تسجيل الدخول هذه غير مفعلة حالياً';
    }
    if (lower.contains('channel-error') ||
        lower.contains('please fill in all')) {
      return 'يرجى ملء جميع الحقول المطلوبة';
    }
    if (lower.contains('login failed')) {
      return 'فشل تسجيل الدخول، يرجى مراجعة البيانات والمحاولة مجدداً';
    }
    if (lower.contains('register failed')) {
      return 'فشل إنشاء الحساب، يرجى المحاولة مرة أخرى';
    }
    if (lower.contains('google auth') ||
        lower.contains('google authentication failed')) {
      return 'فشل تسجيل الدخول باستخدام حساب Google';
    }
    if (lower.contains('facebook auth') ||
        lower.contains('facebook authentication failed')) {
      return 'فشل تسجيل الدخول باستخدام حساب Facebook';
    }

    // Checkout & Cart
    if (lower.contains('your cart is empty')) {
      return 'سلة التسوق فارغة، يرجى إضافة منتجات أولاً';
    }
    if (lower.contains('please select a shipping address')) {
      return 'يرجى تحديد عنوان التوصيل أولاً';
    }
    if (lower.contains('please select a payment card') ||
        lower.contains('choose cash on delivery')) {
      return 'يرجى اختيار بطاقة الدفع أو تحديد الدفع عند الاستلام';
    }
    if (lower.contains('user is not logged in')) {
      return 'يجب تسجيل الدخول لمتابعة هذا الإجراء';
    }
    if (lower.contains('failed to place order')) {
      return 'تعذر إتمام الطلب، يرجى المحاولة مرة أخرى';
    }
    if (lower.contains('payment failed') ||
        lower.contains('failed to process payment')) {
      return 'فشلت عملية الدفع، يرجى مراجعة بيانات البطاقة';
    }

    // Profile & Password & Validation
    if (lower.contains('password must be at least 6')) {
      return 'يجب أن لا تقل كلمة المرور عن 6 أحرف';
    }
    if (lower.contains('passwords do not match') ||
        lower.contains("passwords don't match")) {
      return 'كلمتا المرور غير متطابقتين';
    }
    if (lower.contains('please enter your email')) {
      return 'يرجى إدخال البريد الإلكتروني';
    }
    if (lower.contains('password reset link sent')) {
      return 'تم إرسال رابط إعادة تعيين كلمة المرور إلى بريدك';
    }
    if (lower.contains('profile updated')) {
      return 'تم تحديث الملف الشخصي بنجاح';
    }
    if (lower.contains('profile updating failed')) {
      return 'فشل تحديث الملف الشخصي، يرجى المحاولة لاحقاً';
    }
    if (lower.contains('failed to add card')) {
      return 'فشل في حفظ بيانات البطاقة';
    }
    if (lower.contains('enter city-country')) {
      return 'يرجى إدخال المدينة والدولة أولاً';
    }
    if (lower.contains('default payment method saved')) {
      return 'تم حفظ طريقة الدفع الافتراضية بنجاح';
    }
    if (lower.contains('failed to load') || lower.contains('could not load')) {
      return 'فشل في تحميل البيانات، يرجى إعادة المحاولة';
    }

    // Cleaned message fallback
    final cleaned = _cleanErrorMessage(rawError);
    if (cleaned.contains('Exception') || cleaned.contains('Error:')) {
      return 'حدث خطأ غير متوقع، يرجى المحاولة لاحقاً';
    }
    return cleaned;
  }

  static String _cleanErrorMessage(String raw) {
    var s = raw.trim();
    if (s.startsWith('Exception: ')) {
      s = s.substring('Exception: '.length);
    }
    final regex = RegExp(r'^\[.*?\]\s*');
    s = s.replaceAll(regex, '');
    return s.trim();
  }

  String translateCategory(String categoryName) {
    if (locale.languageCode != 'ar') return categoryName;
    final lower = categoryName.trim().toLowerCase();
    switch (lower) {
      case 'all':
      case 'all products':
        return 'جميع المنتجات';
      case 'beauty':
        return 'الجمال والعناية';
      case 'fragrances':
        return 'العطور';
      case 'furniture':
        return 'الأثاث والديكور';
      case 'groceries':
        return 'البقالة والمؤن';
      case 'home decoration':
        return 'ديكور المنزل';
      case 'kitchen accessories':
        return 'مستلزمات المطبخ';
      case 'laptops':
        return 'أجهزة لابتوب';
      case 'mens shirts':
        return 'قمصان رجالية';
      case 'mens shoes':
        return 'أحذية رجالية';
      case 'mens watches':
        return 'ساعات رجالية';
      case 'mobile accessories':
        return 'إكسسوارات الموبايل';
      case 'motorcycle':
        return 'دراجات نارية';
      case 'skin care':
        return 'العناية بالبشرة';
      case 'smartphones':
        return 'هواتف ذكية';
      case 'sports accessories':
        return 'مستلزمات رياضية';
      case 'sunglasses':
        return 'نظارات شمسية';
      case 'tablets':
        return 'أجهزة لوحية';
      case 'tops':
        return 'ملابس علوية';
      case 'vehicle':
      case 'automotive':
        return 'مستلزمات سيارات';
      case 'womens bags':
        return 'حقائب نسائية';
      case 'womens dresses':
        return 'فساتين نسائية';
      case 'womens jewellery':
        return 'مجوهرات نسائية';
      case 'womens shoes':
        return 'أحذية نسائية';
      case 'womens watches':
        return 'ساعات نسائية';
      default:
        return categoryName;
    }
  }
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'ar'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(AppLocalizations(locale));
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

extension AppLocalizationExtension on BuildContext {
  String tr(String key) {
    return AppLocalizations.of(this)?.translate(key) ?? key;
  }

  String trError(dynamic rawError) {
    if (rawError == null) return '';
    return AppLocalizations.of(this)?.translateError(rawError.toString()) ??
        rawError.toString();
  }

  String trCategory(String categoryName) {
    return AppLocalizations.of(this)?.translateCategory(categoryName) ??
        categoryName;
  }

  bool get isArabic => Localizations.localeOf(this).languageCode == 'ar';
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;
}
