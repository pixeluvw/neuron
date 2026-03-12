/// Templates for internationalization / localization setup
///
/// Provides full OS-level language switching: when the user picks a language,
/// the **entire app** re-renders in that locale (titles, buttons, messages,
/// dialogs — everything), just like switching the system language on
/// Linux / Windows / macOS.
class LanguageTemplates {
  // ─────────────────────────────────────────────────────────────────────
  //  l10n.yaml
  // ─────────────────────────────────────────────────────────────────────

  /// l10n.yaml configuration file
  static String l10nYaml() {
    return '''
arb-dir: lib/l10n
template-arb-file: app_en.arb
output-localization-file: app_localizations.dart
''';
  }

  // ─────────────────────────────────────────────────────────────────────
  //  ARB generation
  // ─────────────────────────────────────────────────────────────────────

  /// ARB file for a given locale
  static String arbFile({
    required String locale,
    required Map<String, String> translations,
  }) {
    final buffer = StringBuffer();
    buffer.writeln('{');
    buffer.writeln('  "@@locale": "$locale",');

    final entries = translations.entries.toList();
    for (var i = 0; i < entries.length; i++) {
      final entry = entries[i];
      final comma = i < entries.length - 1 ? ',' : '';
      if (entry.key.startsWith('@') && !entry.key.startsWith('@@')) {
        // Metadata entries must be JSON objects, not strings
        buffer.writeln(
            '  "${entry.key}": {"description": "${entry.value}"}$comma');
      } else {
        buffer.writeln('  "${entry.key}": "${entry.value}"$comma');
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  /// All translatable keys used across a Neuron app.
  ///
  /// These cover the most common UI strings so that switching the locale
  /// feels like a real system-language change.
  static const List<String> _allKeys = [
    'appTitle',
    // ── General ──
    'hello',
    'welcome',
    'goodbye',
    // ── Navigation / actions ──
    'settings',
    'language',
    'home',
    'back',
    'next',
    'cancel',
    'ok',
    'confirm',
    'save',
    'delete',
    'edit',
    'close',
    'done',
    'retry',
    'search',
    'loading',
    'refresh',
    // ── Auth ──
    'logIn',
    'logOut',
    'signUp',
    'email',
    'password',
    'forgotPassword',
    // ── Feedback ──
    'error',
    'success',
    'noResults',
    'noData',
    'noInternet',
    // ── Settings ──
    'darkMode',
    'lightMode',
    'changeLanguage',
    'about',
    'version',
    'profile',
  ];

  /// Default English ARB file with every key.
  static String defaultEnArb(String appName) {
    final t = _enTranslations(appName);
    final map = <String, String>{};
    for (final key in _allKeys) {
      map[key] = t[key]!;
      map['@$key'] = _keyDescription(key);
    }
    return arbFile(locale: 'en', translations: map);
  }

  // ─────────────────────────────────────────────────────────────────────
  //  Full translation tables
  // ─────────────────────────────────────────────────────────────────────

  /// English base translations (also the fallback for unknown locales).
  static Map<String, String> _enTranslations(String appName) => {
        'appTitle': appName,
        'hello': 'Hello',
        'welcome': 'Welcome',
        'goodbye': 'Goodbye',
        'settings': 'Settings',
        'language': 'Language',
        'home': 'Home',
        'back': 'Back',
        'next': 'Next',
        'cancel': 'Cancel',
        'ok': 'OK',
        'confirm': 'Confirm',
        'save': 'Save',
        'delete': 'Delete',
        'edit': 'Edit',
        'close': 'Close',
        'done': 'Done',
        'retry': 'Retry',
        'search': 'Search',
        'loading': 'Loading…',
        'refresh': 'Refresh',
        'logIn': 'Log in',
        'logOut': 'Log out',
        'signUp': 'Sign up',
        'email': 'Email',
        'password': 'Password',
        'forgotPassword': 'Forgot password?',
        'error': 'Error',
        'success': 'Success',
        'noResults': 'No results found',
        'noData': 'No data available',
        'noInternet': 'No internet connection',
        'darkMode': 'Dark mode',
        'lightMode': 'Light mode',
        'changeLanguage': 'Change language',
        'about': 'About',
        'version': 'Version',
        'profile': 'Profile',
      };

  /// Well-known translations for supported locales.
  ///
  /// Every entry covers **all** keys so that switching to this locale
  /// translates the entire UI — not just a handful of words.
  static Map<String, String> translationsForLocale(
      String locale, String appName) {
    return switch (locale) {
      'es' => {
          'appTitle': appName,
          'hello': 'Hola',
          'welcome': 'Bienvenido',
          'goodbye': 'Adiós',
          'settings': 'Configuración',
          'language': 'Idioma',
          'home': 'Inicio',
          'back': 'Atrás',
          'next': 'Siguiente',
          'cancel': 'Cancelar',
          'ok': 'Aceptar',
          'confirm': 'Confirmar',
          'save': 'Guardar',
          'delete': 'Eliminar',
          'edit': 'Editar',
          'close': 'Cerrar',
          'done': 'Listo',
          'retry': 'Reintentar',
          'search': 'Buscar',
          'loading': 'Cargando…',
          'refresh': 'Actualizar',
          'logIn': 'Iniciar sesión',
          'logOut': 'Cerrar sesión',
          'signUp': 'Registrarse',
          'email': 'Correo electrónico',
          'password': 'Contraseña',
          'forgotPassword': '¿Olvidaste tu contraseña?',
          'error': 'Error',
          'success': 'Éxito',
          'noResults': 'No se encontraron resultados',
          'noData': 'No hay datos disponibles',
          'noInternet': 'Sin conexión a internet',
          'darkMode': 'Modo oscuro',
          'lightMode': 'Modo claro',
          'changeLanguage': 'Cambiar idioma',
          'about': 'Acerca de',
          'version': 'Versión',
          'profile': 'Perfil',
        },
      'fr' => {
          'appTitle': appName,
          'hello': 'Bonjour',
          'welcome': 'Bienvenue',
          'goodbye': 'Au revoir',
          'settings': 'Paramètres',
          'language': 'Langue',
          'home': 'Accueil',
          'back': 'Retour',
          'next': 'Suivant',
          'cancel': 'Annuler',
          'ok': 'OK',
          'confirm': 'Confirmer',
          'save': 'Enregistrer',
          'delete': 'Supprimer',
          'edit': 'Modifier',
          'close': 'Fermer',
          'done': 'Terminé',
          'retry': 'Réessayer',
          'search': 'Rechercher',
          'loading': 'Chargement…',
          'refresh': 'Actualiser',
          'logIn': 'Se connecter',
          'logOut': 'Se déconnecter',
          'signUp': "S'inscrire",
          'email': 'E-mail',
          'password': 'Mot de passe',
          'forgotPassword': 'Mot de passe oublié ?',
          'error': 'Erreur',
          'success': 'Succès',
          'noResults': 'Aucun résultat trouvé',
          'noData': 'Aucune donnée disponible',
          'noInternet': 'Pas de connexion internet',
          'darkMode': 'Mode sombre',
          'lightMode': 'Mode clair',
          'changeLanguage': 'Changer de langue',
          'about': 'À propos',
          'version': 'Version',
          'profile': 'Profil',
        },
      'de' => {
          'appTitle': appName,
          'hello': 'Hallo',
          'welcome': 'Willkommen',
          'goodbye': 'Auf Wiedersehen',
          'settings': 'Einstellungen',
          'language': 'Sprache',
          'home': 'Startseite',
          'back': 'Zurück',
          'next': 'Weiter',
          'cancel': 'Abbrechen',
          'ok': 'OK',
          'confirm': 'Bestätigen',
          'save': 'Speichern',
          'delete': 'Löschen',
          'edit': 'Bearbeiten',
          'close': 'Schließen',
          'done': 'Fertig',
          'retry': 'Erneut versuchen',
          'search': 'Suchen',
          'loading': 'Wird geladen…',
          'refresh': 'Aktualisieren',
          'logIn': 'Anmelden',
          'logOut': 'Abmelden',
          'signUp': 'Registrieren',
          'email': 'E-Mail',
          'password': 'Passwort',
          'forgotPassword': 'Passwort vergessen?',
          'error': 'Fehler',
          'success': 'Erfolg',
          'noResults': 'Keine Ergebnisse gefunden',
          'noData': 'Keine Daten verfügbar',
          'noInternet': 'Keine Internetverbindung',
          'darkMode': 'Dunkler Modus',
          'lightMode': 'Heller Modus',
          'changeLanguage': 'Sprache ändern',
          'about': 'Über',
          'version': 'Version',
          'profile': 'Profil',
        },
      'pt' => {
          'appTitle': appName,
          'hello': 'Olá',
          'welcome': 'Bem-vindo',
          'goodbye': 'Adeus',
          'settings': 'Configurações',
          'language': 'Idioma',
          'home': 'Início',
          'back': 'Voltar',
          'next': 'Próximo',
          'cancel': 'Cancelar',
          'ok': 'OK',
          'confirm': 'Confirmar',
          'save': 'Salvar',
          'delete': 'Excluir',
          'edit': 'Editar',
          'close': 'Fechar',
          'done': 'Concluído',
          'retry': 'Tentar novamente',
          'search': 'Pesquisar',
          'loading': 'Carregando…',
          'refresh': 'Atualizar',
          'logIn': 'Entrar',
          'logOut': 'Sair',
          'signUp': 'Cadastrar-se',
          'email': 'E-mail',
          'password': 'Senha',
          'forgotPassword': 'Esqueceu a senha?',
          'error': 'Erro',
          'success': 'Sucesso',
          'noResults': 'Nenhum resultado encontrado',
          'noData': 'Nenhum dado disponível',
          'noInternet': 'Sem conexão com a internet',
          'darkMode': 'Modo escuro',
          'lightMode': 'Modo claro',
          'changeLanguage': 'Mudar idioma',
          'about': 'Sobre',
          'version': 'Versão',
          'profile': 'Perfil',
        },
      'it' => {
          'appTitle': appName,
          'hello': 'Ciao',
          'welcome': 'Benvenuto',
          'goodbye': 'Arrivederci',
          'settings': 'Impostazioni',
          'language': 'Lingua',
          'home': 'Home',
          'back': 'Indietro',
          'next': 'Avanti',
          'cancel': 'Annulla',
          'ok': 'OK',
          'confirm': 'Conferma',
          'save': 'Salva',
          'delete': 'Elimina',
          'edit': 'Modifica',
          'close': 'Chiudi',
          'done': 'Fatto',
          'retry': 'Riprova',
          'search': 'Cerca',
          'loading': 'Caricamento…',
          'refresh': 'Aggiorna',
          'logIn': 'Accedi',
          'logOut': 'Esci',
          'signUp': 'Registrati',
          'email': 'Email',
          'password': 'Password',
          'forgotPassword': 'Password dimenticata?',
          'error': 'Errore',
          'success': 'Successo',
          'noResults': 'Nessun risultato trovato',
          'noData': 'Nessun dato disponibile',
          'noInternet': 'Nessuna connessione internet',
          'darkMode': 'Modalità scura',
          'lightMode': 'Modalità chiara',
          'changeLanguage': 'Cambia lingua',
          'about': 'Informazioni',
          'version': 'Versione',
          'profile': 'Profilo',
        },
      'ja' => {
          'appTitle': appName,
          'hello': 'こんにちは',
          'welcome': 'ようこそ',
          'goodbye': 'さようなら',
          'settings': '設定',
          'language': '言語',
          'home': 'ホーム',
          'back': '戻る',
          'next': '次へ',
          'cancel': 'キャンセル',
          'ok': 'OK',
          'confirm': '確認',
          'save': '保存',
          'delete': '削除',
          'edit': '編集',
          'close': '閉じる',
          'done': '完了',
          'retry': '再試行',
          'search': '検索',
          'loading': '読み込み中…',
          'refresh': '更新',
          'logIn': 'ログイン',
          'logOut': 'ログアウト',
          'signUp': '新規登録',
          'email': 'メール',
          'password': 'パスワード',
          'forgotPassword': 'パスワードをお忘れですか？',
          'error': 'エラー',
          'success': '成功',
          'noResults': '結果が見つかりません',
          'noData': 'データがありません',
          'noInternet': 'インターネット接続がありません',
          'darkMode': 'ダークモード',
          'lightMode': 'ライトモード',
          'changeLanguage': '言語を変更',
          'about': '概要',
          'version': 'バージョン',
          'profile': 'プロフィール',
        },
      'ko' => {
          'appTitle': appName,
          'hello': '안녕하세요',
          'welcome': '환영합니다',
          'goodbye': '안녕히 가세요',
          'settings': '설정',
          'language': '언어',
          'home': '홈',
          'back': '뒤로',
          'next': '다음',
          'cancel': '취소',
          'ok': '확인',
          'confirm': '확인',
          'save': '저장',
          'delete': '삭제',
          'edit': '편집',
          'close': '닫기',
          'done': '완료',
          'retry': '재시도',
          'search': '검색',
          'loading': '로딩 중…',
          'refresh': '새로고침',
          'logIn': '로그인',
          'logOut': '로그아웃',
          'signUp': '회원가입',
          'email': '이메일',
          'password': '비밀번호',
          'forgotPassword': '비밀번호를 잊으셨나요?',
          'error': '오류',
          'success': '성공',
          'noResults': '결과를 찾을 수 없습니다',
          'noData': '데이터가 없습니다',
          'noInternet': '인터넷 연결 없음',
          'darkMode': '다크 모드',
          'lightMode': '라이트 모드',
          'changeLanguage': '언어 변경',
          'about': '정보',
          'version': '버전',
          'profile': '프로필',
        },
      'zh' => {
          'appTitle': appName,
          'hello': '你好',
          'welcome': '欢迎',
          'goodbye': '再见',
          'settings': '设置',
          'language': '语言',
          'home': '首页',
          'back': '返回',
          'next': '下一步',
          'cancel': '取消',
          'ok': '确定',
          'confirm': '确认',
          'save': '保存',
          'delete': '删除',
          'edit': '编辑',
          'close': '关闭',
          'done': '完成',
          'retry': '重试',
          'search': '搜索',
          'loading': '加载中…',
          'refresh': '刷新',
          'logIn': '登录',
          'logOut': '退出登录',
          'signUp': '注册',
          'email': '邮箱',
          'password': '密码',
          'forgotPassword': '忘记密码？',
          'error': '错误',
          'success': '成功',
          'noResults': '未找到结果',
          'noData': '暂无数据',
          'noInternet': '无网络连接',
          'darkMode': '深色模式',
          'lightMode': '浅色模式',
          'changeLanguage': '更改语言',
          'about': '关于',
          'version': '版本',
          'profile': '个人资料',
        },
      'ar' => {
          'appTitle': appName,
          'hello': 'مرحبا',
          'welcome': 'أهلا وسهلا',
          'goodbye': 'مع السلامة',
          'settings': 'الإعدادات',
          'language': 'اللغة',
          'home': 'الرئيسية',
          'back': 'رجوع',
          'next': 'التالي',
          'cancel': 'إلغاء',
          'ok': 'موافق',
          'confirm': 'تأكيد',
          'save': 'حفظ',
          'delete': 'حذف',
          'edit': 'تعديل',
          'close': 'إغلاق',
          'done': 'تم',
          'retry': 'إعادة المحاولة',
          'search': 'بحث',
          'loading': 'جاري التحميل…',
          'refresh': 'تحديث',
          'logIn': 'تسجيل الدخول',
          'logOut': 'تسجيل الخروج',
          'signUp': 'إنشاء حساب',
          'email': 'البريد الإلكتروني',
          'password': 'كلمة المرور',
          'forgotPassword': 'نسيت كلمة المرور؟',
          'error': 'خطأ',
          'success': 'نجاح',
          'noResults': 'لم يتم العثور على نتائج',
          'noData': 'لا توجد بيانات',
          'noInternet': 'لا يوجد اتصال بالإنترنت',
          'darkMode': 'الوضع الداكن',
          'lightMode': 'الوضع الفاتح',
          'changeLanguage': 'تغيير اللغة',
          'about': 'حول',
          'version': 'الإصدار',
          'profile': 'الملف الشخصي',
        },
      'ru' => {
          'appTitle': appName,
          'hello': 'Привет',
          'welcome': 'Добро пожаловать',
          'goodbye': 'До свидания',
          'settings': 'Настройки',
          'language': 'Язык',
          'home': 'Главная',
          'back': 'Назад',
          'next': 'Далее',
          'cancel': 'Отмена',
          'ok': 'ОК',
          'confirm': 'Подтвердить',
          'save': 'Сохранить',
          'delete': 'Удалить',
          'edit': 'Редактировать',
          'close': 'Закрыть',
          'done': 'Готово',
          'retry': 'Повторить',
          'search': 'Поиск',
          'loading': 'Загрузка…',
          'refresh': 'Обновить',
          'logIn': 'Войти',
          'logOut': 'Выйти',
          'signUp': 'Зарегистрироваться',
          'email': 'Электронная почта',
          'password': 'Пароль',
          'forgotPassword': 'Забыли пароль?',
          'error': 'Ошибка',
          'success': 'Успех',
          'noResults': 'Ничего не найдено',
          'noData': 'Нет данных',
          'noInternet': 'Нет подключения к интернету',
          'darkMode': 'Тёмная тема',
          'lightMode': 'Светлая тема',
          'changeLanguage': 'Изменить язык',
          'about': 'О приложении',
          'version': 'Версия',
          'profile': 'Профиль',
        },
      'hi' => {
          'appTitle': appName,
          'hello': 'नमस्ते',
          'welcome': 'स्वागत है',
          'goodbye': 'अलविदा',
          'settings': 'सेटिंग्स',
          'language': 'भाषा',
          'home': 'होम',
          'back': 'वापस',
          'next': 'अगला',
          'cancel': 'रद्द करें',
          'ok': 'ठीक है',
          'confirm': 'पुष्टि करें',
          'save': 'सहेजें',
          'delete': 'हटाएं',
          'edit': 'संपादित करें',
          'close': 'बंद करें',
          'done': 'हो गया',
          'retry': 'पुन: प्रयास करें',
          'search': 'खोजें',
          'loading': 'लोड हो रहा है…',
          'refresh': 'ताज़ा करें',
          'logIn': 'लॉग इन',
          'logOut': 'लॉग आउट',
          'signUp': 'साइन अप',
          'email': 'ईमेल',
          'password': 'पासवर्ड',
          'forgotPassword': 'पासवर्ड भूल गए?',
          'error': 'त्रुटि',
          'success': 'सफलता',
          'noResults': 'कोई परिणाम नहीं मिला',
          'noData': 'कोई डेटा उपलब्ध नहीं',
          'noInternet': 'इंटरनेट कनेक्शन नहीं है',
          'darkMode': 'डार्क मोड',
          'lightMode': 'लाइट मोड',
          'changeLanguage': 'भाषा बदलें',
          'about': 'बारे में',
          'version': 'संस्करण',
          'profile': 'प्रोफ़ाइल',
        },
      'tr' => {
          'appTitle': appName,
          'hello': 'Merhaba',
          'welcome': 'Hoş geldiniz',
          'goodbye': 'Hoşça kal',
          'settings': 'Ayarlar',
          'language': 'Dil',
          'home': 'Ana Sayfa',
          'back': 'Geri',
          'next': 'İleri',
          'cancel': 'İptal',
          'ok': 'Tamam',
          'confirm': 'Onayla',
          'save': 'Kaydet',
          'delete': 'Sil',
          'edit': 'Düzenle',
          'close': 'Kapat',
          'done': 'Bitti',
          'retry': 'Tekrar dene',
          'search': 'Ara',
          'loading': 'Yükleniyor…',
          'refresh': 'Yenile',
          'logIn': 'Giriş yap',
          'logOut': 'Çıkış yap',
          'signUp': 'Kayıt ol',
          'email': 'E-posta',
          'password': 'Şifre',
          'forgotPassword': 'Şifrenizi mi unuttunuz?',
          'error': 'Hata',
          'success': 'Başarılı',
          'noResults': 'Sonuç bulunamadı',
          'noData': 'Veri yok',
          'noInternet': 'İnternet bağlantısı yok',
          'darkMode': 'Karanlık mod',
          'lightMode': 'Aydınlık mod',
          'changeLanguage': 'Dili değiştir',
          'about': 'Hakkında',
          'version': 'Sürüm',
          'profile': 'Profil',
        },
      'nl' => {
          'appTitle': appName,
          'hello': 'Hallo',
          'welcome': 'Welkom',
          'goodbye': 'Tot ziens',
          'settings': 'Instellingen',
          'language': 'Taal',
          'home': 'Home',
          'back': 'Terug',
          'next': 'Volgende',
          'cancel': 'Annuleren',
          'ok': 'OK',
          'confirm': 'Bevestigen',
          'save': 'Opslaan',
          'delete': 'Verwijderen',
          'edit': 'Bewerken',
          'close': 'Sluiten',
          'done': 'Klaar',
          'retry': 'Opnieuw proberen',
          'search': 'Zoeken',
          'loading': 'Laden…',
          'refresh': 'Vernieuwen',
          'logIn': 'Inloggen',
          'logOut': 'Uitloggen',
          'signUp': 'Registreren',
          'email': 'E-mail',
          'password': 'Wachtwoord',
          'forgotPassword': 'Wachtwoord vergeten?',
          'error': 'Fout',
          'success': 'Succes',
          'noResults': 'Geen resultaten gevonden',
          'noData': 'Geen gegevens beschikbaar',
          'noInternet': 'Geen internetverbinding',
          'darkMode': 'Donkere modus',
          'lightMode': 'Lichte modus',
          'changeLanguage': 'Taal wijzigen',
          'about': 'Over',
          'version': 'Versie',
          'profile': 'Profiel',
        },
      'pl' => {
          'appTitle': appName,
          'hello': 'Cześć',
          'welcome': 'Witamy',
          'goodbye': 'Do widzenia',
          'settings': 'Ustawienia',
          'language': 'Język',
          'home': 'Strona główna',
          'back': 'Wstecz',
          'next': 'Dalej',
          'cancel': 'Anuluj',
          'ok': 'OK',
          'confirm': 'Potwierdź',
          'save': 'Zapisz',
          'delete': 'Usuń',
          'edit': 'Edytuj',
          'close': 'Zamknij',
          'done': 'Gotowe',
          'retry': 'Ponów',
          'search': 'Szukaj',
          'loading': 'Ładowanie…',
          'refresh': 'Odśwież',
          'logIn': 'Zaloguj się',
          'logOut': 'Wyloguj się',
          'signUp': 'Zarejestruj się',
          'email': 'E-mail',
          'password': 'Hasło',
          'forgotPassword': 'Zapomniałeś hasła?',
          'error': 'Błąd',
          'success': 'Sukces',
          'noResults': 'Nie znaleziono wyników',
          'noData': 'Brak danych',
          'noInternet': 'Brak połączenia z internetem',
          'darkMode': 'Tryb ciemny',
          'lightMode': 'Tryb jasny',
          'changeLanguage': 'Zmień język',
          'about': 'O aplikacji',
          'version': 'Wersja',
          'profile': 'Profil',
        },
      _ => _enTranslations(appName),
    };
  }

  /// Short description for each ARB key (used in @-metadata).
  static String _keyDescription(String key) {
    return switch (key) {
      'appTitle' => 'The title of the application',
      'hello' => 'Greeting',
      'welcome' => 'Welcome message',
      'goodbye' => 'Farewell message',
      'settings' => 'Settings screen title',
      'language' => 'Language label',
      'home' => 'Home screen title',
      'back' => 'Back navigation label',
      'next' => 'Next / continue action',
      'cancel' => 'Cancel action',
      'ok' => 'OK / accept action',
      'confirm' => 'Confirm action',
      'save' => 'Save action',
      'delete' => 'Delete action',
      'edit' => 'Edit action',
      'close' => 'Close action',
      'done' => 'Done action',
      'retry' => 'Retry action',
      'search' => 'Search action / placeholder',
      'loading' => 'Loading indicator text',
      'refresh' => 'Refresh action',
      'logIn' => 'Log in action',
      'logOut' => 'Log out action',
      'signUp' => 'Sign up action',
      'email' => 'Email field label',
      'password' => 'Password field label',
      'forgotPassword' => 'Forgot password link',
      'error' => 'Generic error title',
      'success' => 'Generic success title',
      'noResults' => 'Empty search results message',
      'noData' => 'Empty data message',
      'noInternet' => 'No internet connection message',
      'darkMode' => 'Dark mode toggle label',
      'lightMode' => 'Light mode toggle label',
      'changeLanguage' => 'Change language action',
      'about' => 'About screen / section label',
      'version' => 'Version label',
      'profile' => 'User profile label',
      _ => key,
    };
  }

  // ─────────────────────────────────────────────────────────────────────
  //  Language metadata
  // ─────────────────────────────────────────────────────────────────────

  /// Human-readable language name
  static String languageName(String locale) {
    return switch (locale) {
      'en' => 'English',
      'es' => 'Spanish',
      'fr' => 'French',
      'de' => 'German',
      'pt' => 'Portuguese',
      'it' => 'Italian',
      'ja' => 'Japanese',
      'ko' => 'Korean',
      'zh' => 'Chinese',
      'ar' => 'Arabic',
      'ru' => 'Russian',
      'hi' => 'Hindi',
      'tr' => 'Turkish',
      'nl' => 'Dutch',
      'pl' => 'Polish',
      _ => locale,
    };
  }

  /// Native language name (shown in the language picker)
  static String nativeLanguageName(String locale) {
    return switch (locale) {
      'en' => 'English',
      'es' => 'Español',
      'fr' => 'Français',
      'de' => 'Deutsch',
      'pt' => 'Português',
      'it' => 'Italiano',
      'ja' => '日本語',
      'ko' => '한국어',
      'zh' => '中文',
      'ar' => 'العربية',
      'ru' => 'Русский',
      'hi' => 'हिन्दी',
      'tr' => 'Türkçe',
      'nl' => 'Nederlands',
      'pl' => 'Polski',
      _ => locale,
    };
  }

  // ─────────────────────────────────────────────────────────────────────
  //  Code-gen templates
  // ─────────────────────────────────────────────────────────────────────

  /// Localization helper snippet (to add to main.dart)
  static String localizationImports() {
    return '''
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';''';
  }

  /// Localization delegates snippet
  static String localizationDelegates() {
    return '''
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],''';
  }

  // ─────────────────────────────────────────────────────────────────────
  //  LocaleController — runtime locale switching
  // ─────────────────────────────────────────────────────────────────────

  /// Generates `lib/shared/services/locale_controller.dart`.
  ///
  /// This controller holds a `Signal<Locale>` that drives the entire app.
  /// Changing it rebuilds the MaterialApp with the new locale — the same
  /// effect as changing the system language.
  static String localeControllerDart(List<String> locales) {
    final supportedList =
        locales.map((l) => "    const Locale('$l'),").join('\n');
    // Build native-name map entries
    final nameEntries = locales
        .map((l) => "    '$l': '${nativeLanguageName(l)}',")
        .join('\n');

    return '''
import 'package:flutter/material.dart';
import 'package:neuron/neuron.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Controls the app-wide locale (language).
///
/// Changing [locale] rebuilds every widget that depends on localizations —
/// the entire UI switches language instantly, like an OS-level change.
///
/// Usage:
/// ```dart
/// final lc = LocaleController.init;
/// lc.changeLocale(const Locale('es')); // switch to Spanish
/// ```
class LocaleController extends NeuronController {
  static LocaleController get init => Neuron.use<LocaleController>();

  static const _prefKey = 'neuron_app_locale';

  /// All locales the app supports.
  static const List<Locale> supportedLocales = [
$supportedList
  ];

  /// Human-readable native names for each locale.
  static const Map<String, String> localeNames = {
$nameEntries
  };

  /// The currently active locale.
  late final locale = Signal<Locale>(supportedLocales.first).bind(this);

  @override
  void onInit() {
    super.onInit();
    _loadSavedLocale();
  }

  /// Switch the entire app to [newLocale] and persist the choice.
  Future<void> changeLocale(Locale newLocale) async {
    locale.emit(newLocale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefKey, newLocale.languageCode);
  }

  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefKey);
    if (saved != null) {
      final match = supportedLocales
          .where((l) => l.languageCode == saved);
      if (match.isNotEmpty) {
        locale.emit(match.first);
      }
    }
  }
}
''';
  }

  // ─────────────────────────────────────────────────────────────────────
  //  Language picker screen
  // ─────────────────────────────────────────────────────────────────────

  /// Generates `lib/modules/language/language_view.dart`.
  ///
  /// A ready-to-use settings screen that lists every installed locale.
  /// Tapping one switches the entire app instantly.
  static String languageViewDart() {
    return '''
import 'package:flutter/material.dart';
import 'package:neuron/neuron.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../shared/services/locale_controller.dart';

/// Language picker screen — lets the user switch the app language.
///
/// Selecting a locale rebuilds the entire app in that language.
class LanguageView extends StatelessWidget {
  const LanguageView({super.key});

  @override
  Widget build(BuildContext context) {
    final lc = LocaleController.init;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.changeLanguage),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Neuron.back(),
              )
            : null,
      ),
      body: Slot<Locale>(
        connect: lc.locale,
        to: (context, currentLocale) {
          return ListView.builder(
            itemCount: LocaleController.supportedLocales.length,
            itemBuilder: (context, index) {
              final loc = LocaleController.supportedLocales[index];
              final code = loc.languageCode;
              final nativeName =
                  LocaleController.localeNames[code] ?? code;
              final isSelected =
                  currentLocale.languageCode == code;

              return ListTile(
                leading: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : null,
                ),
                title: Text(
                  nativeName,
                  style: TextStyle(
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(code.toUpperCase()),
                trailing: isSelected
                    ? Icon(Icons.check,
                        color: Theme.of(context).colorScheme.primary)
                    : null,
                onTap: () => lc.changeLocale(loc),
              );
            },
          );
        },
      ),
    );
  }
}
''';
  }

  /// Generates `lib/modules/language/language_controller.dart` (thin shell).
  static String languageControllerDart() {
    return '''
import 'package:neuron/neuron.dart';

/// Controller for the Language screen (delegates to LocaleController).
class LanguageController extends NeuronController {
  static LanguageController get init => Neuron.use<LanguageController>();
}
''';
  }

  // ─────────────────────────────────────────────────────────────────────
  //  main.dart rewrite — locale-aware
  // ─────────────────────────────────────────────────────────────────────

  /// Generates a locale-aware `main.dart` that wraps the app with
  /// a `Slot<Locale>` so a locale change rebuilds everything.
  static String localeAwareMainDart(
    String projectName,
    List<String> locales,
  ) {
    final localeEntries =
        locales.map((l) => "        const Locale('$l'),").join('\n');

    return '''
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:neuron/neuron.dart';

import 'di/injector.dart';
import 'routes/app_routes.dart';
import 'shared/services/locale_controller.dart';

void main() {
  setupDependencies();

  runApp(const _LocaleRoot());
}

/// Wraps the entire app in a Slot that reacts to locale changes.
/// When the user picks a different language, the whole app rebuilds
/// in the new locale — just like changing the OS system language.
class _LocaleRoot extends StatelessWidget {
  const _LocaleRoot();

  @override
  Widget build(BuildContext context) {
    final lc = LocaleController.init;

    return Slot<Locale>(
      connect: lc.locale,
      to: (context, locale) {
        return NeuronApp(
          title: '$projectName',
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
$localeEntries
          ],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          routes: appRoutes,
          initialRoute: '/',
        );
      },
    );
  }
}
''';
  }
}
