import 'package:get/get.dart';

/// Tarjimalar. Kalit — o'zbekcha matnning o'zi, shuning uchun o'zbek tili uchun
/// alohida lug'at shart emas (kalit o'zi ko'rsatiladi). Yangi matn qo'shsangiz,
/// `'Matn'.tr` deb yozing va bu yerga ruscha tarjimasini qo'shing.
class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {'ru_RU': _ru};
}

const Map<String, String> _ru = {
  // Navigatsiya
  "Bosh sahifa": "Главная",
  "Epizodlar": "Эпизоды",
  "Sevimlilar": "Избранное",
  "Profil": "Профиль",

  // Login
  "XUSH KELIBSIZ": "ДОБРО ПОЖАЛОВАТЬ",
  "Sevimli tarixiy serial va durdona filmlaringizni yuqori sifatda tomosha qilish uchun hisobingizga kiring":
      "Войдите в аккаунт, чтобы смотреть любимые исторические сериалы и фильмы в высоком качестве",
  "Google orqali davom etish": "Продолжить с Google",
  "Davom etish orqali siz bizning ": "Продолжая, вы соглашаетесь с нашими ",
  "Foydalanish shartlari": "Условиями использования",
  " va ": " и ",
  "Maxfiylik siyosatiga": "Политикой конфиденциальности",
  " rozilik bildirasiz.": ".",
  "Google token olishda xatolik": "Ошибка получения токена Google",
  "Kirish amalga oshmadi": "Не удалось войти",
  "Sessiya tugadi": "Сеанс завершён",
  "Iltimos, qaytadan kiring": "Пожалуйста, войдите снова",

  // Bosh sahifa
  "Bildirishnomalar": "Уведомления",
  "Hammasini o'qish": "Прочитать все",
  "Hozircha yangi bildirishnoma yo'q": "Новых уведомлений пока нет",
  "Tomosha qilish": "Смотреть",
  "Ko'rishni davom etish": "Продолжить просмотр",
  "@n-qism • @t qoldi": "@n серия • осталось @t",
  "@n ta serial": "Сериалов: @n",
  "Barcha seriallar": "Все сериалы",
  "Janrlar": "Жанры",
  "Kategoriyalar bo'yicha izlash": "Поиск по категориям",
  "Barchasi": "Все",
  "Tarixiy serial": "Исторический сериал",
  "BEPUL": "БЕСПЛАТНО",
  "Xatolik": "Ошибка",
  "Xato": "Ошибка",
  "Qayta urinish": "Повторить",
  "Kirish": "Войти",
  "Kirish talab qilinadi": "Требуется вход",
  "Seriallarni ko'rish uchun tizimga kiring": "Войдите, чтобы смотреть сериалы",
  "Serverdan javob kelmadi": "Сервер не ответил",
  "Ma'lumotlarni yuklab bo'lmadi.": "Не удалось загрузить данные.",
  "Ma'lumotlarni yuklab bo'lmadi. Internetni tekshiring.": "Не удалось загрузить данные. Проверьте интернет.",

  // Katalog / Sevimlilar
  "Seriallar": "Сериалы",
  "Serial nomini qidiring...": "Поиск по названию...",
  "Hech narsa topilmadi": "Ничего не найдено",
  "Sevimlilar ro'yxati bo'sh": "Список избранного пуст",
  "Serial sahifasida 👍 tugmasini bosing, u shu yerda paydo bo'ladi.":
      "Нажмите 👍 на странице сериала, и он появится здесь.",

  // Serial sahifasi
  "@n fasl": "Сезонов: @n",
  "@n qism": "Серий: @n",
  "Dastlabki @n ta qism BEPUL": "Первые @n серий БЕСПЛАТНО",
  "Barcha qismlarga kirish": "Доступ ко всем сериям",
  "Qismlar": "Серии",
  "Hozircha qismlar yo'q": "Серий пока нет",
  "@n-qism": "@n серия",
  "@s-fasl": "@s сезон",
  "Bepul": "Бесплатно",
  "Serial ma'lumotlarini yuklab bo'lmadi": "Не удалось загрузить сериал",

  // Pleyer
  "@s-FASL • @e-QISM": "СЕЗОН @s • СЕРИЯ @e",
  "Barcha qism": "Все серии",
  "Ko'rilganlar": "Просмотренные",
  "Yuklanganlar": "Загруженные",
  "Qism yopiq": "Серия закрыта",
  "Bu qismni ko'rish uchun obuna bo'ling": "Оформите подписку, чтобы смотреть эту серию",
  "Qismlarni yuklashda xatolik": "Ошибка загрузки серий",
  "Video havolasi mavjud emas": "Ссылка на видео недоступна",
  "Muvaffaqiyatli": "Готово",
  "Qism yuklab olindi! Oflayn ko'rishingiz mumkin.": "Серия загружена! Можно смотреть офлайн.",
  "Yuklab olishda xatolik yuz berdi": "Ошибка при загрузке",
  "Video sifati": "Качество видео",
  "Bu video uchun sifat tanlab bo'lmaydi": "Для этого видео нельзя выбрать качество",
  "Avto": "Авто",
  "Internet tezligiga qarab avtomatik": "Автоматически по скорости интернета",
  "@h soat @m daq": "@h ч @m мин",
  "@m daq": "@m мин",

  // Obuna / to'lov
  "Obuna": "Подписка",
  "Premium obuna": "Премиум подписка",
  "Barcha seriallarni cheklovsiz ko'ring": "Смотрите все сериалы без ограничений",
  "Obuna tarifidagi barcha seriallarni cheklovsiz ko'ring": "Смотрите все сериалы тарифа без ограничений",
  "Ulanish": "Подключить",
  "Obuna bo'lish": "Оформить подписку",
  "1 oylik": "1 месяц",
  "3 oylik": "3 месяца",
  "Muddatni tanlang": "Выберите срок",
  "Davom etish": "Продолжить",
  "Narx": "Цена",
  "Komissiya (4%)": "Комиссия (4%)",
  "Jami": "Итого",
  "To'lash": "Оплатить",
  "To'lov": "Оплата",
  "@n so'm": "@n сум",
  "To'lovni yaratib bo'lmadi": "Не удалось создать платёж",
  "To'lov sahifasini ochib bo'lmadi": "Не удалось открыть страницу оплаты",
  "To'lovdan so'ng ilovaga qayting va sahifani yangilang": "После оплаты вернитесь в приложение и обновите страницу",
  "Tariflarni yuklab bo'lmadi": "Не удалось загрузить тарифы",
  "Hozircha tariflar yo'q": "Тарифов пока нет",
  "To'lov Pixy orqali amalga oshiriladi. Narxga 4% komissiya qo'shiladi.":
      "Оплата проходит через Pixy. К цене добавляется комиссия 4%.",

  // Profil
  "PROFIL": "ПРОФИЛЬ",
  "Mehmon": "Гость",
  "Hisob ma'lumotlari": "Данные аккаунта",
  "Ilova sozlamalari": "Настройки",
  "Til": "Язык",
  "Tilni tanlang": "Выберите язык",
  "Yuklanmalar": "Загрузки",
  "YORDAM": "ПОМОЩЬ",
  "Qo'llab-quvvatlash": "Поддержка",
  "Tizimdan chiqish": "Выйти из аккаунта",
  "Haqiqatan ham chiqmoqchimisiz?": "Вы действительно хотите выйти?",
  "Bekor qilish": "Отмена",
  "Chiqish": "Выйти",
  "Versiya": "Версия",

  "Keyingi qism": "Следующая серия",
  "Joy yetarli emas": "Недостаточно места",
  "@need kerak, telefonda @free bo'sh": "Нужно @need, свободно @free",
  "Mobil internet": "Мобильный интернет",
  "Wi-Fi ulanmagan. Yuklash ~@size mobil trafik sarflaydi. Davom etasizmi?":
      "Wi-Fi не подключён. Загрузка израсходует ~@size мобильного трафика. Продолжить?",
  "To'lov qabul qilindi": "Оплата получена",
  "Barcha qismlar ochildi. Yoqimli tomosha!": "Все серии открыты. Приятного просмотра!",
  "Premium obuna faol": "Премиум подписка активна",
  "@kun kun qoldi • @sana gacha": "Осталось @kun дн. • до @sana",
  "Uzaytirish": "Продлить",
  "SOTIB OLINGAN SERIALLAR": "КУПЛЕННЫЕ СЕРИАЛЫ",
  "Serial topilmadi": "Сериал не найден",
  // Hisob
  "Ism": "Имя",
  "Foydalanuvchi ID": "ID пользователя",
  "Kirish usuli": "Способ входа",
  "Nusxa olindi": "Скопировано",
  "Xavfli hudud": "Опасная зона",
  "Akkauntni o'chirish": "Удалить аккаунт",
  "Akkaunt o'chirilsa, obunalar va ko'rish tarixi qayta tiklanmaydi.":
      "После удаления аккаунта подписки и история просмотров не восстанавливаются.",
  "Rostdan ham akkauntingizni butunlay o'chirmoqchimisiz? Bu amalni ortga qaytarib bo'lmaydi.":
      "Вы действительно хотите навсегда удалить аккаунт? Это действие нельзя отменить.",
  "O'chirish": "Удалить",
  "Akkaunt o'chirildi": "Аккаунт удалён",
  "Ma'lumotlaringiz o'chirildi": "Ваши данные удалены",
  "Akkauntni o'chirib bo'lmadi. Keyinroq urinib ko'ring.": "Не удалось удалить аккаунт. Попробуйте позже.",

  // Sozlamalar / Yuklanmalar
  "Rasmlar keshini tozalash": "Очистить кэш изображений",
  "Tayyor": "Готово",
  "Kesh tozalandi": "Кэш очищен",
  "Barcha yuklanmalarni o'chirish": "Удалить все загрузки",
  "Yuklab olingan barcha qismlar telefondan o'chiriladi.": "Все загруженные серии будут удалены с телефона.",
  "Yuklanmalar yo'q": "Загрузок нет",
  "Yuklab olish sifati": "Качество загрузки",
  "Qism faqat shu ilova ichida ko'riladi, boshqa joyga ko'chirib bo'lmaydi.":
      "Серия доступна только внутри приложения, её нельзя скопировать.",
  "Yuklanmani o'chirish": "Удалить загрузку",
  "Bu qism telefondan o'chiriladi.": "Серия будет удалена с телефона.",
  "Yuklashni bekor qilish": "Отменить загрузку",
  "Yuklangan qismi o'chiriladi.": "Загруженная часть будет удалена.",
  "Davom ettirish": "Продолжить",
  "Internetni tekshiring": "Проверьте интернет",
  "Yopish": "Закрыть",
  "Yuklangan": "Загружено",
  "Yuklanmoqda": "Загружается",
  "To'xtatilgan": "Приостановлено",
  "Yuklash to'xtadi. Davom ettirish uchun qayta bosing.": "Загрузка остановлена. Нажмите ещё раз, чтобы продолжить.",
  "Qismni oflayn ko'rish uchun pleyer sahifasidagi yuklab olish tugmasini bosing.":
      "Чтобы смотреть офлайн, нажмите кнопку загрузки на странице плеера.",

  // FAQ
  "Obunani qanday sotib olaman?": "Как оформить подписку?",
  "Profil → Premium obuna → «Ulanish» tugmasini bosing, muddatni tanlang va Pixy orqali to'lang. To'lovdan so'ng ilovaga qaytib, sahifani yangilang.":
      "Профиль → Премиум подписка → нажмите «Подключить», выберите срок и оплатите через Pixy. После оплаты вернитесь в приложение и обновите страницу.",
  "Bepul qismlar bormi?": "Есть ли бесплатные серии?",
  "Ha. Ko'p seriallarning dastlabki qismlari bepul. Ular serial sahifasida «Bepul» belgisi bilan ko'rsatilgan.":
      "Да. Первые серии многих сериалов бесплатны. На странице сериала они отмечены как «Бесплатно».",
  "Qismni internetsiz ko'rsa bo'ladimi?": "Можно ли смотреть без интернета?",
  "Ha. Pleyer sahifasida qism yonidagi yuklab olish tugmasini bosing. Yuklangan qismlar faqat shu ilova ichida ko'rinadi.":
      "Да. Нажмите кнопку загрузки рядом с серией на странице плеера. Загруженные серии доступны только внутри приложения.",
  "Nega boshqa telefonda kira olmayapman?": "Почему я не могу войти с другого телефона?",
  "Xavfsizlik uchun bitta akkaunt bir vaqtda bitta qurilmada ishlaydi. Yangi qurilmada kirsangiz, eski qurilmadagi sessiya yopiladi.":
      "В целях безопасности аккаунт работает только на одном устройстве. При входе с нового устройства сеанс на старом завершается.",
  "To'lov qildim, lekin serial ochilmadi": "Я оплатил, но сериал не открылся",
  "Sahifani pastga tortib yangilang. Muammo davom etsa, Qo'llab-quvvatlash orqali foydalanuvchi ID raqamingizni yuboring.":
      "Потяните страницу вниз, чтобы обновить. Если проблема сохраняется, отправьте свой ID пользователя в поддержку.",
};
