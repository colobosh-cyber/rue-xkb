#!/usr/bin/env bash
set -euo pipefail

XKB_DIR="/usr/share/X11/xkb"
RULES_DIR="$XKB_DIR/rules"

DST_SYMBOLS="$XKB_DIR/symbols/rue"
EVDEV_LST="$RULES_DIR/evdev.lst"
EVDEV_XML="$RULES_DIR/evdev.xml"

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

RUE_LAYOUT_LINE="rue             Rusyn"
RUSYN_VARIANT_LINE="  rusyn         rue: Rusyn (Carpathian phonetic)"

require_root() {
    if [[ "$EUID" -ne 0 ]]; then
        echo "Помилка: запусти скрипт через sudo."
        exit 1
    fi
}

check_inputs() {
    [[ -f "$EVDEV_LST" ]] || { echo "Не знайдено файл: $EVDEV_LST"; exit 1; }
    [[ -f "$EVDEV_XML" ]] || { echo "Не знайдено файл: $EVDEV_XML"; exit 1; }
}

backup_file() {
    local file="$1"
    local backup="${file}.bak-rue-remove-$(date +%Y%m%d-%H%M%S)"
    cp -a "$file" "$backup"
    echo "Backup: $backup"
}

remove_symbols_file() {
    if [[ -f "$DST_SYMBOLS" ]]; then
        echo "Видаляю symbols/rue ..."
        rm -f "$DST_SYMBOLS"
    else
        echo "symbols/rue уже відсутній."
    fi
}

patch_evdev_lst_remove() {
    echo "Очищаю evdev.lst ..."

    awk -v line1="$RUE_LAYOUT_LINE" -v line2="$RUSYN_VARIANT_LINE" '
    $0 == line1 { next }
    $0 == line2 { next }
    { print }
    ' "$EVDEV_LST" > "$TMP_DIR/evdev.lst.new"

    cp "$TMP_DIR/evdev.lst.new" "$EVDEV_LST"
    echo "Записи Rue/Rusyn видалено з evdev.lst"
}

patch_evdev_xml_remove() {
    echo "Очищаю evdev.xml ..."

    awk '
    BEGIN {
        inblock = 0
        removed = 0
    }

    /<layout>/ {
        block = $0 "\n"
        inblock = 1
        next
    }

    inblock {
        block = block $0 "\n"
        if ($0 ~ /<\/layout>/) {
            is_target = 0

            if (block ~ /<shortDescription>rue<\/shortDescription>/ &&
                block ~ /<name>rusyn<\/name>/ &&
                block ~ /Rusyn \(Carpathian phonetic\)/) {
                is_target = 1
            }

            if (is_target == 1) {
                removed = 1
            } else {
                printf "%s", block
            }

            block = ""
            inblock = 0
        }
        next
    }

    { print }

    END {
        if (removed == 0)
            exit 3
    }
    ' "$EVDEV_XML" > "$TMP_DIR/evdev.xml.new" || status=$?

    status="${status:-0}"

    if [[ "$status" -eq 3 ]]; then
        echo "Окремий layout Rue/Rusyn не знайдено в evdev.xml"
        return
    elif [[ "$status" -ne 0 ]]; then
        echo "Помилка під час обробки evdev.xml"
        return 1
    fi

    cp "$TMP_DIR/evdev.xml.new" "$EVDEV_XML"
    echo "Окремий layout Rue/Rusyn видалено з evdev.xml"
}

reconfigure_xkb() {
    echo "Оновлюю XKB через dpkg-reconfigure xkb-data ..."
    dpkg-reconfigure xkb-data >/dev/null 2>&1 || true
}

show_final_notes() {
    echo
    echo "Готово."
    echo
    echo "Що далі:"
    echo "1. Виконай:"
    echo "   sudo dpkg-reconfigure xkb-data"
    echo "2. Якщо зміни не підхопились одразу:"
    echo "   - перезавантаж ПК, або"
    echo "   - вийди з сеансу і зайди знову."
    echo "3. Якщо Rue/Rusyn ще видно в GNOME Settings, прибери її вручну."
    echo "4. Старий варіант rs(rue) = Pannonian Rusyn лишається недоторканим."
}

main() {
    require_root
    check_inputs

    backup_file "$EVDEV_LST"
    backup_file "$EVDEV_XML"

    remove_symbols_file
    patch_evdev_lst_remove
    patch_evdev_xml_remove
    reconfigure_xkb
    show_final_notes
}

main "$@"
