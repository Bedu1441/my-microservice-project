# Мій власний мікросервісний проєкт  

Це репозиторій для навчального проєкту в межах курсу "DevOps CI/CD".  

# Linux Administration – DevOps Tools Installer

## Опис

Цей репозиторій містить Bash-скрипт **install_dev_tools.sh**, який автоматизує встановлення базових інструментів, необхідних для роботи **DevOps-інженера** у середовищі **Ubuntu / Debian**.

Скрипт створений у межах домашнього завдання до теми **«Linux адміністрування»** та відповідає вимогам курсу.

## Що встановлює скрипт

Скрипт автоматично перевіряє наявність і, за необхідності, встановлює:
* **Docker**
* **Docker Compose (v2)**
* **Python 3** (версія 3.9+)
* **Django**

> Для середовища **WSL (Windows Subsystem for Linux)** скрипт коректно враховує використання **Docker Desktop з WSL Integration**.

## Основні особливості

* **Ідемпотентність** — повторний запуск скрипта не призводить до повторного встановлення вже наявних інструментів
* **Сумісність з Ubuntu / Debian**
* Адаптація під особливості **Ubuntu 24.04 (PEP 668)**
* Коректний Bash-синтаксис

## Структура репозиторію

```text
my-microservice-project/
├── README.md
└── install_dev_tools.sh
```
## Як використовувати

### Клонувати репозиторій

```bash
git clone git@github.com:Bedu1441/my-microservice-project.git
cd my-microservice-project
```

### Перейти у гілку `lesson-3`

```bash
git checkout lesson-3
```

### Зробити скрипт виконуваним

```bash
chmod u+x install_dev_tools.sh
```

### Запустити скрипт

```bash
./install_dev_tools.sh
```

## Перевірка встановлення

Після виконання скрипта можна перевірити інструменти:

```bash
docker --version
docker compose version
python3 --version
python3 -m django --version
```

## Тестування

Скрипт протестований на:
* Ubuntu 24.04 (WSL2)
* Python 3.12

## Контекст

Домашнє завдання до теми **«Linux адміністрування»**:
* створення Bash-скриптів
* автоматизація встановлення інструментів
* базова робота з Git та GitHub
