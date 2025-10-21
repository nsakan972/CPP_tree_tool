# CPP Tree Tool

Овај директоријум садржи три скрипте за брзо генерисање C++ стабла директоријума и почетних `.hpp/.cpp` датотека са чуварима заглавља, просторима имена (namespace), минималним шаблонима класа и ажурирањем [main](cci:7://file:///home/nsakan/Posao/Fizika/Teorija/C++_2025/Prebacivanje_starih_u_cpp/src/main:0:0-0:0) модула.

- [CPP_stablo_sr.sh](cci:7://file:///home/nsakan/Posao/Fizika/Teorija/C++_2025/CPP_tree_tool/CPP_stablo_sr.sh:0:0-0:0) — српски (ћирилица)
- [CPP_steblo_ru.sh](cci:7://file:///home/nsakan/Posao/Fizika/Teorija/C++_2025/CPP_tree_tool/CPP_steblo_ru.sh:0:0-0:0) — русский
- [CPP_tree_en.sh](cci:7://file:///home/nsakan/Posao/Fizika/Teorija/C++_2025/CPP_tree_tool/CPP_tree_en.sh:0:0-0:0) — English

---

## Српски (ћирилица)

- Покретање: из корена пројекта (где ће се креирати [src/](cci:7://file:///home/nsakan/Posao/Fizika/Teorija/C++_2025/Prebacivanje_starih_u_cpp/src:0:0-0:0))
- Захтеви: Bash и дозволе за извршавање (`chmod +x <скрипта>`)

Примери:
```bash
chmod +x CPP_stablo_sr.sh
# Креира само простор имена (namespace):
./CPP_stablo_sr.sh fizika
# Креира класу унутар простора имена и ажурира main:
./CPP_stablo_sr.sh fizika talasi
```

## Русский

Запускать из корня проекта (где будет создан каталог src/)
Требования: Bash и права на исполнение (chmod +x <скрипт>)
Примеры:
```bash
chmod +x CPP_steblo_ru.sh
# Создать только пространство имён (namespace):
./CPP_steblo_ru.sh fizika
# Создать класс внутри пространства имён и обновить main:
./CPP_steblo_ru.sh fizika volny
```

Скрипты:

- CPP_stablo_sr.sh — сербский (кириллица)
- CPP_steblo_ru.sh — русский
- CPP_tree_en.sh — английский

Этот каталог содержит три скрипта для быстрого создания дерева каталогов C++ и начальных файлов .hpp/.cpp с защитой заголовков, пространствами имён, минимальными шаблонами классов и обновлением модуля main.


## English

This directory contains three scripts for quickly creating a C++ directory tree and initial .hpp/.cpp files with header protection, namespaces, minimal class templates, and updating the main module.

Scripts:

- CPP_stablo_sr.sh — Serbian (Cyrillic)
- CPP_steblo_ru.sh — Russian
- CPP_tree_en.sh — English

Examples:
```bash
chmod +x CPP_stablo_sr.sh
# Create only namespace:
./CPP_stablo_sr.sh fizika
# Create class inside namespace and update main:
./CPP_stablo_sr.sh fizika talasi
```

## License

This repository is licensed under the BSD 2-Clause (FreeBSD) License. See the `LICENSE` file for details.
