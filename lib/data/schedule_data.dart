import '../models/lesson.dart';

class ScheduleData {
  static List<Lesson> getLessons() {
    return [
      Lesson(
        dayName: 'Monday',
        dayIndex: 0,
        videoTitle: 'What is a Supply Chain and How it Works',
        videoUrl: 'https://www.youtube.com/watch?v=rdMhJiNVTRc',
        readingTask: '2 articles on Medium (Tag: Logistics)',
        promptText:
            'Привет! Сегодня понедельник. Я посмотрел короткое видео про Supply Chain и прочитал статью на Medium. Проведи со мной микро-урок на 10 минут: дай мне 2-3 термина из логистики на английском, объясни их простыми словами и попроси меня составить с ними одно простое предложение.',
      ),
      Lesson(
        dayName: 'Tuesday',
        dayIndex: 1,
        videoTitle: null,
        videoUrl: null,
        readingTask: '2 articles on Medium (Tag: B2B E-commerce)',
        promptText:
            'Привет! Сегодня вторник. Я прочитал статьи про B2B. Вот абзац, который мне показался сложным: [ВСТАВЬТЕ СЮДА ТЕКСТ]. Помоги мне перевести его с сохранением бизнес-смысла и подскажи полезные фразы.',
      ),
      Lesson(
        dayName: 'Wednesday',
        dayIndex: 2,
        videoTitle:
            'The COMPLETE Guide to Starting a Multi-Vendor Marketplace',
        videoUrl: 'https://www.youtube.com/watch?v=EcTuK7GcX2s',
        readingTask: '1 article on Medium (Tag: Marketplace)',
        promptText:
            'Привет! Сегодня среда. Давай разыграем мини-диалог: как будто я ставлю задачу разработчику. Помоги мне правильно сказать на английском, что \'Продавец должен иметь возможность загружать товары через API\'.',
      ),
      Lesson(
        dayName: 'Thursday',
        dayIndex: 3,
        videoTitle: null,
        videoUrl: null,
        readingTask: '2 articles on Medium (Tag: Web Development)',
        promptText:
            'Привет! Сегодня четверг. Вот текст, который я изучал: [ВСТАВЬТЕ СЮДА АБЗАЦ]. Задай мне по этому тексту один простой вопрос на английском, чтобы я ответил на него своими словами.',
      ),
      Lesson(
        dayName: 'Friday',
        dayIndex: 4,
        videoTitle:
            'EVERYTHING you need to know to build a Dashboard UI in 8 minutes',
        videoUrl: 'https://www.youtube.com/watch?v=B7k5rOgmOGY',
        readingTask: '1 article on Medium (Tag: UI/UX Dashboards)',
        promptText:
            'Привет! Сегодня пятница. Мне нужно написать зарубежному дизайнеру, что \'Интерфейс должен быть чистым, а графики — понятными для пользователя\'. Помоги составить письмо.',
      ),
    ];
  }
}
