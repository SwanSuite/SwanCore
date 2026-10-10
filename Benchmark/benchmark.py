#!/usr/bin/env python3
import os
import sys
import subprocess
import re
import argparse
from collections import defaultdict
import math

def parse_arguments():
    """Настройка интерфейса аргументов командной строки."""
    parser = argparse.ArgumentParser(
        description="Автоматизированный движок сбора и анализа бенчмарков SwanCore через Test Plan.",
        formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )
    parser.add_argument(
        "-n", "--iterations",
        type=int,
        default=200,
        help="Количество итераций прогона тестового набора для сбора чистой статистики."
    )
    return parser.parse_args()

# Регулярные выражения для парсинга вывода
LOG_PATTERNS = [
    re.compile(r"([a-zA-Z0-9_<>\(\)]+):\s+.*Duration.*:\s+([0-9.]+)\s+seconds", re.IGNORECASE),
    re.compile(r"([a-zA-Z0-9_<>\(\)]+)\s+Append\s+Duration:\s+([0-9.]+)\s+seconds", re.IGNORECASE),
    re.compile(r"([a-zA-Z0-9_<>\(\)]+):\s+O\(1\)\s+Excision\s+Duration.*:\s+([0-9.]+)\s+seconds", re.IGNORECASE),
    re.compile(r"([a-zA-Z0-9_<>\(\)]+):\s+Mixed\s+Contentions\s+Duration.*:\s+([0-9.]+)\s+seconds", re.IGNORECASE)
]

def выявить_категорию(line):
    if "Append" in line: return "1. Однопоточное добавление (Sequential Write)"
    elif "Concurrent Read" in line: return "2. Параллельное чтение (Concurrent Read)"
    elif "Concurrent Write" in line: return "3. Параллельная запись (Concurrent Write)"
    elif "Mixed Contentions" in line: return "4. Смешанная нагрузка (Mixed Read-Write)"
    elif "Excision" in line: return "5. Точечное вырезание узлов (List Node Excision)"
    return "Другое"

def main():
    args = parse_arguments()
    
    # Команда xcodebuild для запуска конкретного тест-плана нативно под macOS
    xcodebuild_command = [
        "xcodebuild", "test",
        "-scheme", "SwanCore",
        "-destination", "platform=macOS", # Запуск нативно под архитектуру Mac
        "-testPlan", "SwanCorePerformance" # Явно указываем ваш перформанс тест-план
    ]
    
    print(f"🚀 Запуск автоматического замера SwanCore (Итераций: {args.iterations})...")
    print("📋 Используется тест-план: .swiftpm/SwanCorePerformance.xctestplan")
    print("⚠️  Пожалуйста, закройте Xcode и оставьте компьютер в покое до окончания теста.")
    
    raw_data = defaultdict(lambda: defaultdict(list))
    
    # Предварительный холостой прогон (warm-up) для сборки артефактов
    print("📦 Предварительная сборка пакета нативно под macOS...")
    subprocess.run(xcodebuild_command, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)
    
    for iteration in range(1, args.iterations + 1):
        sys.stdout.write(f"\rПрогресс выполнения: Итерация {iteration}/{args.iterations}")
        sys.stdout.flush()
        
        # Запускаем xcodebuild и перехватываем вывод
        result = subprocess.run(xcodebuild_command, capture_output=True, text=True)
        
        all_output = str(result.stdout) + "\n" + str(result.stderr)
        for line in all_output.splitlines():
            for pattern in LOG_PATTERNS:
                match = pattern.search(line)
                if match:
                    lock_type = match.group(1).strip()
                    lock_type = lock_type.replace("<()>", "").replace("<VoidVersionStage>", "")
                    
                    try:
                        duration = float(match.group(2))
                        category = выявить_категорию(line)
                        if category != "Другое":
                            raw_data[category][lock_type].append(duration)
                    except ValueError:
                        continue

    print("\n\n📊 Сбор данных завершен. Обработка статистической матрицы...")
    
    if not raw_data:
        print("❌ Ошибка: Не удалось распарсить логи бенчмарков. Проверьте вывод команды в Терминале.")
        return

    report = []
    report.append(f"# Нативный профиль производительности SwanCore под macOS ({args.iterations} итераций)")
    report.append("Данные собраны в монопольном режиме выполнения процессора на архитектуре хоста с использованием тест-плана.\n")
    
    for category in sorted(raw_data.keys()):
        report.append(f"### {category}")
        report.append("| Примитив синхронизации | Min | Max | Average | StdDev |")
        report.append("| :--- | :--- | :--- | :--- | :--- |")
        
        # Сортировка: x[1] — это список таймингов, сортируем по их среднему значению
        sorted_locks = sorted(raw_data[category].items(), key=lambda x: sum(x[1])/len(x[1]) if x[1] else 0)
        
        for lock_type, timings in sorted_locks:
            if not timings: continue
            
            minimum = min(timings)
            maximum = max(timings)
            average = sum(timings) / len(timings)
            
            variance = sum((x - average) ** 2 for x in timings) / len(timings)
            std_dev = math.sqrt(variance)
            
            report.append(f"| `{lock_type}` | {minimum:.6f}s | {maximum:.6f}s | **{average:.6f}s** | ±{std_dev:.6f}s |")
        
        report.append("")
        
    output_path = "BENCHMARK_REPORT.md"
    with open(output_path, "w", encoding="utf-8") as f:
        f.write("\n".join(report))
        
    print(f"🎉 Отчет успешно сформирован и сохранен в файл: {os.path.abspath(output_path)}")
    print("\nВывод таблиц в консоль:\n")
    print("\n".join(report))

if __name__ == "__main__":
    main()
