import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';
import 'chapter_content_screen.dart';

class StudyScreen extends StatelessWidget {
  const StudyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Вшитая база ПДД (Главы 1-5 перенесены слово в слово из документа)
    final List<Map<String, dynamic>> chapters = [
      {
        "title": "Глава 1. Общие положения",
        "time": "15 мин",
        "content": [
          {"type": "text", "content": "Настоящие Правила дорожного движения (далее - Правила) устанавливают единый порядок дорожного движения на всей территории Республики Казахстан."},
          {"type": "text", "content": "В настоящих Правилах используются следующие основные понятия:"},
          {"type": "text", "content": "1) автомагистраль - дорога, специально построенная или реконструированная в соответствии с проектом для движения транспортных средств, которая не обслуживает придорожные владения."},
          {"type": "text", "content": "2) автобус - автомобиль, предназначенный для перевозки пассажиров и багажа, имеющий более восьми мест для сидения, не включая место водителя;"},
          {"type": "text", "content": "3) автомобиль - механическое транспортное средство, предназначенное для движения по дорогам и перевозки по ним людей, грузов или оборудования..."},
          {"type": "text", "content": "4) автопоезд - механическое транспортное средство, сцепленное с прицепом (прицепами);"},
          {"type": "text", "content": "5) преимущество (приоритет) - первоочередность движения в намеченном направлении по отношению к другим участникам движения;"},
          {"type": "text", "content": "Участники дорожного движения обязаны:\n1) знать и соблюдать настоящие Правила, требования Закона «О дорожном движении»;\n2) выполнять требования сигналов регулировщика и светофора, дорожных знаков, дорожной разметки..."},
        ]
      },
      {
        "title": "Глава 2. Общие обязанности водителей",
        "time": "10 мин",
        "content": [
          {"type": "text", "content": "Водитель механического транспортного средства обязан:\n1) иметь при себе и по требованию уполномоченных на то должностных лиц передавать им для проверки:\n- водительское удостоверение на право управления транспортным средством...\n- свидетельство о государственной регистрации транспортного средства..."},
          {"type": "text", "content": "2) остановить транспортное средство по требованию сотрудника органов внутренних дел, транспортного контроля в форменной одежде об остановке транспортного средства путем подачи сигнала..."},
          {"type": "text", "content": "8) при дорожно-транспортном происшествии водитель, причастный к нему, обязан:\n- немедленно остановить (не трогать с места) транспортное средство, включить аварийную световую сигнализацию и выставить знак аварийной остановки..."},
          // Место для картинки знака аварийной остановки
          {"type": "image", "content": "emergency_sign.png"},
          {"type": "text", "content": "Водителю запрещается:\n1) управлять транспортным средством без водительского удостоверения...\n2) управлять транспортным средством в состоянии опьянения (алкогольного, наркотического и (или) токсикоманического)..."},
        ]
      },
      {
        "title": "Глава 3. Обязанности пешеходов",
        "time": "5 мин",
        "content": [
          {"type": "text", "content": "Пешеходы двигаются по тротуарам или пешеходным дорожкам, а при их отсутствии - по обочинам, а также в соответствии с требованиями пунктов 121 и 124 главы 17 настоящих Правил."},
          {"type": "text", "content": "Вне населенных пунктов при движении по проезжей части дороги пешеходы идут навстречу движению транспортных средств."},
          {"type": "text", "content": "Пешеходы пересекают проезжую часть дороги по пешеходным переходам, в том числе по подземным и надземным, а при их отсутствии в пределах видимости - на перекрестках по линии тротуаров или обочин."},
          {"type": "image", "content": "pedestrian_crossing.png"},
          {"type": "text", "content": "Выйдя на проезжую часть дороги, пешеходы не задерживаются и не останавливаются, если это не связано с обеспечением безопасности движения."},
        ]
      },
      {
        "title": "Глава 4. Обязанности пассажиров",
        "time": "5 мин",
        "content": [
          {"type": "text", "content": "Пассажиры обязаны:\n1) при поездке на транспортном средстве, оборудованном ремнями безопасности, быть пристегнутыми ими, а при поездке на мотоцикле или мопеде - быть в застегнутом мотошлеме;"},
          {"type": "text", "content": "2) посадку и высадку производить со стороны тротуара или обочины и только после полной остановки транспортного средства."},
          {"type": "text", "content": "Пассажирам запрещается:\n1) отвлекать водителя от управления транспортным средством во время его движения;\n2) при поездке на грузовом автомобиле с бортовой платформой стоять, сидеть на бортах или на грузе выше бортов;\n3) открывать двери, а также высовываться в оконные проемы и люки транспортного средства во время его движения;"},
        ]
      },
      {
        "title": "Глава 5. Сигналы светофора и регулировщика",
        "time": "12 мин",
        "content": [
          {"type": "text", "content": "Для регулирования дорожного движения применяются светофоры, имеющие вертикальное или горизонтальное расположение. В светофорах применяются световые сигналы зеленого, желтого, красного и бело-лунного цвета."},
          {"type": "image", "content": "traffic_lights_vertical.png"},
          {"type": "text", "content": "Круглые сигналы светофора имеют следующие значения:\n1) зеленый сигнал разрешает движение;\n2) зеленый мигающий сигнал разрешает движение и информирует, что время его действия истекает;\n3) желтый сигнал запрещает движение;\n4) красный сигнал, в том числе мигающий, запрещает движение."},
          {"type": "text", "content": "Сигналами регулировщика служат положения его корпуса и жесты руками, в том числе с жезлом, которые имеют следующие значения:"},
          {"type": "image", "content": "police_signals.png"},
          {"type": "text", "content": "1) руки вытянуты в стороны или опущены: со стороны левого и правого бока - разрешено движение трамваю прямо, безрельсовым транспортным средствам прямо и направо, пешеходам разрешено переходить проезжую часть дороги; со стороны груди и спины - движение всех транспортных средств и пешеходов запрещено."},
        ]
      },
    ];

    const Color studyColor = Color(0xFFFF5252);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            height: 120,
            decoration: const BoxDecoration(
              color: studyColor,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
                      onPressed: () => Navigator.pop(context),
                    ),
                    Text(
                      "Обучение",
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: chapters.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        // ПЕРЕХОД НА ЭКРАН ЧТЕНИЯ ГЛАВЫ
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChapterContentScreen(
                              chapterTitle: chapters[index]["title"],
                              contentBlocks: chapters[index]["content"],
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 60,
                              decoration: BoxDecoration(
                                color: studyColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.menu_book, color: studyColor, size: 30),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    chapters[index]["title"]!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textMain,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    chapters[index]["time"]!,
                                    style: GoogleFonts.poppins(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}